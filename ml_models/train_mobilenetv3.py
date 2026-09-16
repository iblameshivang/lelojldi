"""
PlantVillage — MobileNetV3-Large Disease Classifier
=====================================================
21-class crop disease classifier for SIH Round-1.

Architecture : MobileNetV3-Large (ImageNet pretrained)
Input        : 224x224 RGB
Classes      : 21 (Apple/Maize/Potato/Tomato diseases)
Strategy     : Phase-1 (head only) → Phase-2 (fine-tune upper layers)
"""

import os, sys, json, time, random, csv, warnings
warnings.filterwarnings('ignore')
os.environ['TF_CPP_MIN_LOG_LEVEL'] = '2'

import numpy as np
import tensorflow as tf
from tensorflow import keras
from tensorflow.keras import layers, Model
from tensorflow.keras.applications import MobileNetV3Large
from tensorflow.keras.callbacks import (
    EarlyStopping, ModelCheckpoint, ReduceLROnPlateau, CSVLogger
)
from sklearn.metrics import (
    classification_report, confusion_matrix
)
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import seaborn as sns

# ── Reproducibility ──────────────────────────────────────────────────────────
SEED = 42
os.environ['PYTHONHASHSEED'] = str(SEED)
random.seed(SEED)
np.random.seed(SEED)
tf.random.set_seed(SEED)
tf.config.experimental.enable_op_determinism()

# ── Paths ────────────────────────────────────────────────────────────────────
BASE_DIR     = r'c:\Users\Shivang\Desktop\sih\ml_models'
COLOR_DIR    = r'c:\Users\Shivang\Desktop\sih\ml_models\data\PlantVillage-Dataset-master\raw\color'
SPLITS_DIR   = os.path.join(BASE_DIR, 'data', 'dataset_splits')
MODEL_DIR    = os.path.join(BASE_DIR, 'models', 'plant_disease_v1')

os.makedirs(MODEL_DIR, exist_ok=True)

TRAIN_CSV = os.path.join(SPLITS_DIR, 'train.csv')
VAL_CSV   = os.path.join(SPLITS_DIR, 'val.csv')
TEST_CSV  = os.path.join(SPLITS_DIR, 'test.csv')
META_JSON = os.path.join(SPLITS_DIR, 'dataset_meta.json')

# ── Hyperparameters ──────────────────────────────────────────────────────────
IMG_SIZE      = 224
BATCH_SIZE    = 32
NUM_CLASSES   = 21

# Phase 1 — train head only
P1_EPOCHS     = 15
P1_LR         = 1e-3

# Phase 2 — fine-tune upper backbone
P2_EPOCHS     = 40
P2_LR         = 1e-5
UNFREEZE_FROM = 100   # unfreeze layers from this index onward

EARLY_STOP_PATIENCE = 10
REDUCE_LR_PATIENCE  = 4

print("=" * 65)
print("MobileNetV3-Large  —  PlantVillage 21-class Classifier")
print("=" * 65)
print(f"TensorFlow : {tf.__version__}")
print(f"GPU devices: {tf.config.list_physical_devices('GPU')}")
print(f"Model dir  : {MODEL_DIR}")
print()

# ── Load metadata & build class maps ────────────────────────────────────────
with open(META_JSON) as f:
    meta = json.load(f)

# Sorted alphabetically → stable integer labels (same as prepare_splits.py)
CLASS_NAMES  = sorted(meta['class_index'].keys())
CLASS_TO_IDX = {c: i for i, c in enumerate(CLASS_NAMES)}
IDX_TO_CLASS = {i: c for c, i in CLASS_TO_IDX.items()}

print(f"Classes ({NUM_CLASSES}):")
for i, c in enumerate(CLASS_NAMES):
    print(f"  {i:2d}  {c}")
print()

# ── Load CSVs ────────────────────────────────────────────────────────────────
def load_csv(path):
    rows = []
    with open(path, newline='', encoding='utf-8') as f:
        for row in csv.DictReader(f):
            full_path = os.path.join(COLOR_DIR, row['image_path'])
            label     = CLASS_TO_IDX[row['class']]
            rows.append((full_path, label))
    return rows

train_data = load_csv(TRAIN_CSV)
val_data   = load_csv(VAL_CSV)
test_data  = load_csv(TEST_CSV)

print(f"Loaded  train={len(train_data):,}  val={len(val_data):,}  test={len(test_data):,}")
print()

# ── Class weights for imbalance ───────────────────────────────────────────────
print("Class weights: disabled for the initial training run.\n")

# ── tf.data pipeline ─────────────────────────────────────────────────────────
AUTOTUNE = tf.data.AUTOTUNE

def make_dataset(data, training=False):
    paths  = [p for p, _ in data]
    labels = [l for _, l in data]

    path_ds  = tf.data.Dataset.from_tensor_slices(paths)
    label_ds = tf.data.Dataset.from_tensor_slices(labels)
    ds = tf.data.Dataset.zip((path_ds, label_ds))

    def load_image(path, label):
        raw = tf.io.read_file(path)
        img = tf.image.decode_image(raw, channels=3, expand_animations=False)
        img = tf.cast(img, tf.float32)
        img = tf.image.resize(img, [IMG_SIZE, IMG_SIZE])
        # MobileNetV3 expects inputs in [-1, 1]; scale exactly once here.
        img = (img / 127.5) - 1.0
        return img, label

    random_rot = tf.keras.layers.RandomRotation(0.05, fill_mode='reflect')
    random_zoom = tf.keras.layers.RandomZoom(0.1, fill_mode='reflect')

    def augment(img, label):
        img = tf.image.random_flip_left_right(img)
        img = tf.image.random_brightness(img, max_delta=0.2)
        img = tf.image.random_contrast(img, 0.8, 1.2)
        # Random rotation ±15° via crop-and-resize trick
        img = random_rot(tf.expand_dims(img, 0), training=True)[0]
        # Random zoom
        img = random_zoom(tf.expand_dims(img, 0), training=True)[0]
        img = tf.clip_by_value(img, -1.0, 1.0)
        return img, label

    if training:
        ds = ds.shuffle(buffer_size=len(data), seed=SEED, reshuffle_each_iteration=True)

    ds = ds.map(load_image, num_parallel_calls=AUTOTUNE)

    if training:
        ds = ds.map(augment, num_parallel_calls=AUTOTUNE)

    ds = ds.batch(BATCH_SIZE).prefetch(AUTOTUNE)
    return ds

print("Building tf.data pipelines...")
train_ds = make_dataset(train_data, training=True)
val_ds   = make_dataset(val_data,   training=False)
test_ds  = make_dataset(test_data,  training=False)
print("Pipelines ready.\n")

# ── Model definition ──────────────────────────────────────────────────────────
def build_model(num_classes, trainable_base=False, unfreeze_from=None):
    base = MobileNetV3Large(
        input_shape=(IMG_SIZE, IMG_SIZE, 3),
        include_top=False,
        weights='imagenet',
        include_preprocessing=False,   # we do it ourselves
    )

    if not trainable_base:
        base.trainable = False
    else:
        base.trainable = True
        if unfreeze_from is not None:
            for layer in base.layers[:unfreeze_from]:
                layer.trainable = False

    inputs = keras.Input(shape=(IMG_SIZE, IMG_SIZE, 3))
    x = base(inputs, training=False)
    x = layers.GlobalAveragePooling2D()(x)
    x = layers.BatchNormalization()(x)
    x = layers.Dense(512, activation='relu',
                     kernel_regularizer=tf.keras.regularizers.l2(1e-4))(x)
    x = layers.Dropout(0.4)(x)
    x = layers.Dense(256, activation='relu',
                     kernel_regularizer=tf.keras.regularizers.l2(1e-4))(x)
    x = layers.Dropout(0.3)(x)
    outputs = layers.Dense(num_classes, activation='softmax')(x)

    model = Model(inputs, outputs, name='PlantDisease_MobileNetV3L')
    return model, base

# ── PHASE 1: Train classification head ───────────────────────────────────────
print("=" * 65)
print("PHASE 1 — Training classification head (backbone frozen)")
print(f"          LR={P1_LR}  max_epochs={P1_EPOCHS}")
print("=" * 65)

model, base_model = build_model(NUM_CLASSES, trainable_base=False)
model.compile(
    optimizer=keras.optimizers.Adam(P1_LR),
    loss='sparse_categorical_crossentropy',
    metrics=['accuracy']
)

total_params    = model.count_params()
trainable_params = sum(tf.size(v).numpy() for v in model.trainable_variables)
print(f"Total params    : {total_params:,}")
print(f"Trainable params: {trainable_params:,}")
print()

best_p1_path  = os.path.join(MODEL_DIR, 'phase1_best.weights.h5')
p1_csv_log    = os.path.join(MODEL_DIR, 'phase1_history.csv')

callbacks_p1 = [
    CSVLogger(p1_csv_log),
    ModelCheckpoint(best_p1_path, monitor='val_accuracy',
                    save_best_only=True, save_weights_only=True, verbose=1),
    EarlyStopping(monitor='val_accuracy', patience=EARLY_STOP_PATIENCE,
                  restore_best_weights=True, verbose=1),
    ReduceLROnPlateau(monitor='val_loss', factor=0.5,
                      patience=REDUCE_LR_PATIENCE, min_lr=1e-7, verbose=1),
]

t0 = time.time()
hist_p1 = model.fit(
    train_ds,
    validation_data=val_ds,
    epochs=P1_EPOCHS,
    callbacks=callbacks_p1,
    verbose=1,
)
p1_time = time.time() - t0
p1_epochs_run = len(hist_p1.history['val_accuracy'])
p1_best_val   = max(hist_p1.history['val_accuracy'])
print(f"\nPhase 1 done: {p1_epochs_run} epochs | best val_acc={p1_best_val:.4f} | time={p1_time/60:.1f}m\n")

# ── PHASE 2: Fine-tune upper backbone layers ──────────────────────────────────
print("=" * 65)
print("PHASE 2 — Fine-tuning upper backbone layers")
print(f"          LR={P2_LR}  max_epochs={P2_EPOCHS}  unfreeze_from=layer[{UNFREEZE_FROM}]")
print("=" * 65)

# Load best phase-1 weights, then unfreeze
model.load_weights(best_p1_path)

base_model.trainable = True
for layer in base_model.layers[:UNFREEZE_FROM]:
    layer.trainable = False

trainable_p2 = sum(tf.size(v).numpy() for v in model.trainable_variables)
print(f"Trainable params after unfreeze: {trainable_p2:,}")

model.compile(
    optimizer=keras.optimizers.Adam(P2_LR),
    loss='sparse_categorical_crossentropy',
    metrics=['accuracy']
)

best_model_path = os.path.join(MODEL_DIR, 'best_model.weights.h5')
p2_csv_log      = os.path.join(MODEL_DIR, 'phase2_history.csv')

callbacks_p2 = [
    CSVLogger(p2_csv_log),
    ModelCheckpoint(best_model_path, monitor='val_accuracy',
                    save_best_only=True, save_weights_only=True, verbose=1),
    EarlyStopping(monitor='val_accuracy', patience=EARLY_STOP_PATIENCE,
                  restore_best_weights=True, verbose=1),
    ReduceLROnPlateau(monitor='val_loss', factor=0.5,
                      patience=REDUCE_LR_PATIENCE, min_lr=1e-8, verbose=1),
]

t1 = time.time()
hist_p2 = model.fit(
    train_ds,
    validation_data=val_ds,
    epochs=P2_EPOCHS,
    callbacks=callbacks_p2,
    verbose=1,
)
p2_time = time.time() - t1
p2_epochs_run = len(hist_p2.history['val_accuracy'])
p2_best_val   = max(hist_p2.history['val_accuracy'])
print(f"\nPhase 2 done: {p2_epochs_run} epochs | best val_acc={p2_best_val:.4f} | time={p2_time/60:.1f}m\n")

# ── Load best model & evaluate on test set ───────────────────────────────────
print("=" * 65)
print("EVALUATION — Test set (untouched)")
print("=" * 65)

best_model = model
best_model.load_weights(best_model_path)

# Collect true labels and predictions
y_true, y_pred_probs = [], []
for imgs, labels in test_ds:
    probs = best_model.predict(imgs, verbose=0)
    y_pred_probs.extend(probs)
    y_true.extend(labels.numpy())

y_true       = np.array(y_true)
y_pred_probs = np.array(y_pred_probs)
y_pred       = np.argmax(y_pred_probs, axis=1)

test_acc = np.mean(y_pred == y_true)
print(f"Test Accuracy: {test_acc*100:.2f}%\n")

# Classification report
report_str = classification_report(
    y_true, y_pred,
    target_names=CLASS_NAMES,
    digits=4
)
print(report_str)

report_dict = classification_report(
    y_true, y_pred,
    target_names=CLASS_NAMES,
    output_dict=True
)

# Confusion matrix
cm = confusion_matrix(y_true, y_pred)

# ── Top-3 predictions for a sample test image ─────────────────────────────────
sample_img_path, sample_true_label = test_data[0]
sample_img_raw = tf.io.read_file(sample_img_path)
sample_img = tf.image.decode_image(sample_img_raw, channels=3, expand_animations=False)
sample_img = tf.cast(sample_img, tf.float32)
sample_img = tf.image.resize(sample_img, [IMG_SIZE, IMG_SIZE])
sample_img = (sample_img / 127.5) - 1.0
sample_img = tf.expand_dims(sample_img, 0)

sample_probs = best_model.predict(sample_img, verbose=0)[0]
top3_idx     = np.argsort(sample_probs)[::-1][:3]

print("\nTop-3 predictions for sample test image:")
print(f"  True class: {CLASS_NAMES[sample_true_label]}")
for rank, idx in enumerate(top3_idx, 1):
    print(f"  #{rank}: {CLASS_NAMES[idx]:<50s}  {sample_probs[idx]*100:.2f}%")

# ── Save confusion matrix plot ────────────────────────────────────────────────
short_names = [c.split('___')[-1][:25] for c in CLASS_NAMES]
fig, ax = plt.subplots(figsize=(18, 15))
sns.heatmap(cm, annot=True, fmt='d', cmap='Blues',
            xticklabels=short_names, yticklabels=short_names,
            linewidths=0.5, ax=ax)
ax.set_xlabel('Predicted', fontsize=12)
ax.set_ylabel('True', fontsize=12)
ax.set_title('Confusion Matrix — PlantVillage 21-class (MobileNetV3-Large)', fontsize=13)
plt.xticks(rotation=45, ha='right', fontsize=8)
plt.yticks(rotation=0, fontsize=8)
plt.tight_layout()
cm_path = os.path.join(MODEL_DIR, 'confusion_matrix.png')
plt.savefig(cm_path, dpi=150)
plt.close()
print(f"\nConfusion matrix saved → {cm_path}")

# ── Save training history plot ────────────────────────────────────────────────
all_val_acc = hist_p1.history['val_accuracy'] + hist_p2.history['val_accuracy']
all_trn_acc = hist_p1.history['accuracy'] + hist_p2.history['accuracy']
all_val_los = hist_p1.history['val_loss'] + hist_p2.history['val_loss']
all_trn_los = hist_p1.history['loss'] + hist_p2.history['loss']
epochs_axis = list(range(1, len(all_val_acc) + 1))
p2_start    = p1_epochs_run + 0.5

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))
ax1.plot(epochs_axis, all_trn_acc, label='Train Acc')
ax1.plot(epochs_axis, all_val_acc, label='Val Acc')
ax1.axvline(p2_start, color='red', linestyle='--', alpha=0.6, label='Fine-tune start')
ax1.set_title('Accuracy'); ax1.legend(); ax1.set_xlabel('Epoch')
ax2.plot(epochs_axis, all_trn_los, label='Train Loss')
ax2.plot(epochs_axis, all_val_los, label='Val Loss')
ax2.axvline(p2_start, color='red', linestyle='--', alpha=0.6, label='Fine-tune start')
ax2.set_title('Loss'); ax2.legend(); ax2.set_xlabel('Epoch')
plt.suptitle('Training History — MobileNetV3-Large', fontsize=13)
plt.tight_layout()
hist_plot_path = os.path.join(MODEL_DIR, 'training_history.png')
plt.savefig(hist_plot_path, dpi=150)
plt.close()
print(f"Training history plot saved → {hist_plot_path}")

# ── Save JSON artifacts ───────────────────────────────────────────────────────
# Class labels
class_labels_path = os.path.join(MODEL_DIR, 'class_labels.json')
with open(class_labels_path, 'w') as f:
    json.dump({'class_names': CLASS_NAMES,
               'class_to_idx': CLASS_TO_IDX,
               'idx_to_class': {str(k): v for k, v in IDX_TO_CLASS.items()}}, f, indent=2)

# Training history
history_path = os.path.join(MODEL_DIR, 'training_history.json')
history_data = {
    'phase1': {k: [float(x) for x in v] for k, v in hist_p1.history.items()},
    'phase2': {k: [float(x) for x in v] for k, v in hist_p2.history.items()},
}
with open(history_path, 'w') as f:
    json.dump(history_data, f, indent=2)

# Evaluation results
eval_path = os.path.join(MODEL_DIR, 'evaluation_results.json')
eval_data = {
    'test_accuracy'       : float(test_acc),
    'best_val_accuracy_p1': float(p1_best_val),
    'best_val_accuracy_p2': float(p2_best_val),
    'classification_report': report_dict,
    'confusion_matrix'    : cm.tolist(),
    'sample_top3': [
        {'rank': i+1, 'class': CLASS_NAMES[idx], 'confidence': float(sample_probs[idx])}
        for i, idx in enumerate(top3_idx)
    ],
}
with open(eval_path, 'w') as f:
    json.dump(eval_data, f, indent=2)

# Training config
total_time = p1_time + p2_time
model_size_mb = os.path.getsize(best_model_path) / (1024 * 1024)

config_path = os.path.join(MODEL_DIR, 'training_config.json')
config_data = {
    'architecture'   : 'MobileNetV3-Large',
    'image_size'     : IMG_SIZE,
    'num_classes'    : NUM_CLASSES,
    'random_seed'    : SEED,
    'batch_size'     : BATCH_SIZE,
    'phase1': {
        'epochs_max': P1_EPOCHS, 'epochs_run': p1_epochs_run,
        'learning_rate': P1_LR, 'time_minutes': round(p1_time/60, 2),
        'best_val_accuracy': float(p1_best_val),
    },
    'phase2': {
        'epochs_max': P2_EPOCHS, 'epochs_run': p2_epochs_run,
        'learning_rate': P2_LR, 'unfreeze_from_layer': UNFREEZE_FROM,
        'time_minutes': round(p2_time/60, 2),
        'best_val_accuracy': float(p2_best_val),
    },
    'total_epochs'        : p1_epochs_run + p2_epochs_run,
    'total_time_minutes'  : round(total_time/60, 2),
    'model_size_mb'       : round(model_size_mb, 2),
    'best_model_path'     : best_model_path,
    'class_labels_path'   : class_labels_path,
    'training_history_path': history_path,
    'evaluation_path'     : eval_path,
}
with open(config_path, 'w') as f:
    json.dump(config_data, f, indent=2)

# ── Final Summary ─────────────────────────────────────────────────────────────
print()
print("=" * 65)
print("TRAINING COMPLETE — FINAL SUMMARY")
print("=" * 65)
print(f"  Architecture       : MobileNetV3-Large (ImageNet pretrained)")
print(f"  Total epochs       : {p1_epochs_run + p2_epochs_run}  (P1={p1_epochs_run}  P2={p2_epochs_run})")
print(f"  Total training time: {total_time/60:.1f} minutes")
print(f"  Best val accuracy  : {max(p1_best_val, p2_best_val)*100:.2f}%")
print(f"  Test accuracy      : {test_acc*100:.2f}%")
print(f"  Model size         : {model_size_mb:.1f} MB")
print()
print("  Files saved:")
print(f"    Model       → {best_model_path}")
print(f"    Class labels→ {class_labels_path}")
print(f"    History JSON→ {history_path}")
print(f"    History plot→ {hist_plot_path}")
print(f"    Eval results→ {eval_path}")
print(f"    Confusion   → {cm_path}")
print(f"    Config      → {config_path}")
print("=" * 65)
print()
print("Training complete. Awaiting next instruction.")

