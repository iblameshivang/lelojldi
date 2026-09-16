"""
Evaluation-only script for PlantVillage MobileNetV3-Large (21-class).
- Loads best_model.weights.h5  (NO retraining, NO weight modification)
- Uses EXACT same architecture and preprocessing as train_mobilenetv3.py
- Evaluates held-out test.csv only
- Saves evaluation_results.json, class_labels.json, test_confusion_matrix.png
"""

import os, json, csv, time
import numpy as np
import tensorflow as tf
from tensorflow import keras
from tensorflow.keras import layers, Model
from tensorflow.keras.applications import MobileNetV3Large
from sklearn.metrics import classification_report, confusion_matrix
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import seaborn as sns

# ── Paths (identical to training script) ─────────────────────────────────────
BASE_DIR   = r'c:\Users\Shivang\Desktop\sih\ml_models'
COLOR_DIR  = r'c:\Users\Shivang\Desktop\sih\ml_models\data\PlantVillage-Dataset-master\raw\color'
SPLITS_DIR = os.path.join(BASE_DIR, 'data', 'dataset_splits')
MODEL_DIR  = os.path.join(BASE_DIR, 'models', 'plant_disease_v1')
META_JSON  = os.path.join(SPLITS_DIR, 'dataset_meta.json')
TEST_CSV   = os.path.join(SPLITS_DIR, 'test.csv')
WEIGHTS    = os.path.join(MODEL_DIR, 'best_model.weights.h5')

IMG_SIZE   = 224
BATCH_SIZE = 32
NUM_CLASSES = 21

# ── Step 1: Verify weights file untouched ────────────────────────────────────
print("=" * 65)
print("EVALUATION — MobileNetV3-Large PlantVillage 21-class")
print("=" * 65)

w_stat = os.stat(WEIGHTS)
w_size_mb = w_stat.st_size / (1024 * 1024)
w_mtime   = time.strftime('%Y-%m-%d %H:%M:%S', time.localtime(w_stat.st_mtime))
print(f"\n[CHECK] best_model.weights.h5")
print(f"        Size      : {w_size_mb:.2f} MB")
print(f"        Last write: {w_mtime}")
assert w_stat.st_size > 0, "Weights file is empty!"

# ── Step 2: Load class labels in EXACT training order ────────────────────────
# Training script: CLASS_NAMES = sorted(meta['class_index'].keys())
with open(META_JSON) as f:
    meta = json.load(f)

CLASS_NAMES  = sorted(meta['class_index'].keys())   # alphabetical — same as training
CLASS_TO_IDX = {c: i for i, c in enumerate(CLASS_NAMES)}
IDX_TO_CLASS = {i: c for c, i in CLASS_TO_IDX.items()}

print(f"\n[CHECK] Class order (must match training):")
for i, c in enumerate(CLASS_NAMES):
    print(f"        {i:2d}  {c}")

assert len(CLASS_NAMES) == NUM_CLASSES, f"Expected 21 classes, got {len(CLASS_NAMES)}"

# ── Step 3: Build EXACT same architecture ────────────────────────────────────
def build_model():
    base = MobileNetV3Large(
        input_shape=(IMG_SIZE, IMG_SIZE, 3),
        include_top=False,
        weights=None,               # weights loaded manually below
        include_preprocessing=False,
    )
    base.trainable = False

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
    outputs = layers.Dense(NUM_CLASSES, activation='softmax')(x)
    return Model(inputs, outputs, name='PlantDisease_MobileNetV3L')

print("\n[BUILD] Reconstructing architecture...")
model = build_model()
model.load_weights(WEIGHTS)
print(f"[BUILD] Weights loaded from: {WEIGHTS}")

# ── Step 4: Load test CSV ─────────────────────────────────────────────────────
def load_csv(path):
    rows = []
    with open(path, newline='', encoding='utf-8') as f:
        for row in csv.DictReader(f):
            full_path = os.path.join(COLOR_DIR, row['image_path'])
            label     = CLASS_TO_IDX[row['class']]
            rows.append((full_path, label))
    return rows

test_data = load_csv(TEST_CSV)
print(f"\n[DATA]  Test images: {len(test_data):,}")

# ── Step 5: Build tf.data pipeline (EXACT same preprocessing) ────────────────
AUTOTUNE = tf.data.AUTOTUNE

def make_test_dataset(data):
    paths  = [p for p, _ in data]
    labels = [l for _, l in data]
    ds = tf.data.Dataset.zip((
        tf.data.Dataset.from_tensor_slices(paths),
        tf.data.Dataset.from_tensor_slices(labels),
    ))
    def load_image(path, label):
        raw = tf.io.read_file(path)
        img = tf.image.decode_image(raw, channels=3, expand_animations=False)
        img = tf.cast(img, tf.float32)
        img = tf.image.resize(img, [IMG_SIZE, IMG_SIZE])
        img = (img / 127.5) - 1.0   # EXACT training preprocessing
        return img, label
    return ds.map(load_image, num_parallel_calls=AUTOTUNE).batch(BATCH_SIZE).prefetch(AUTOTUNE)

test_ds = make_test_dataset(test_data)

# ── Step 6: Evaluate ──────────────────────────────────────────────────────────
print("\n[EVAL]  Running test set evaluation (no training)...")
t0 = time.time()

# Keras built-in loss + accuracy
model.compile(
    optimizer='adam',
    loss='sparse_categorical_crossentropy',
    metrics=['accuracy', tf.keras.metrics.SparseTopKCategoricalAccuracy(k=3, name='top3_accuracy')]
)
results = model.evaluate(test_ds, verbose=1)
test_loss, test_acc, top3_acc = results[0], results[1], results[2]

# Collect predictions for per-class metrics
y_true, y_pred_probs = [], []
for imgs, labels in test_ds:
    probs = model.predict(imgs, verbose=0)
    y_pred_probs.extend(probs)
    y_true.extend(labels.numpy())

y_true       = np.array(y_true)
y_pred_probs = np.array(y_pred_probs)
y_pred       = np.argmax(y_pred_probs, axis=1)
eval_time    = time.time() - t0

print(f"\n[RESULT] Test Loss    : {test_loss:.4f}")
print(f"[RESULT] Test Accuracy: {test_acc*100:.2f}%")
print(f"[RESULT] Top-3 Accuracy: {top3_acc*100:.2f}%")
print(f"[RESULT] Eval time    : {eval_time:.1f}s")

# ── Step 7: Per-class report ──────────────────────────────────────────────────
print("\n[REPORT] Per-class classification report:")
report_str  = classification_report(y_true, y_pred, target_names=CLASS_NAMES, digits=4)
report_dict = classification_report(y_true, y_pred, target_names=CLASS_NAMES,
                                    output_dict=True, digits=4)
print(report_str)

# ── Step 8: Confusion matrix ──────────────────────────────────────────────────
cm = confusion_matrix(y_true, y_pred)
short_names = [c.split('___')[-1][:25] for c in CLASS_NAMES]

fig, ax = plt.subplots(figsize=(18, 15))
sns.heatmap(cm, annot=True, fmt='d', cmap='Blues',
            xticklabels=short_names, yticklabels=short_names,
            linewidths=0.5, ax=ax)
ax.set_xlabel('Predicted', fontsize=12)
ax.set_ylabel('True', fontsize=12)
ax.set_title('Test Confusion Matrix - PlantVillage 21-class (MobileNetV3-Large)', fontsize=13)
plt.xticks(rotation=45, ha='right', fontsize=8)
plt.yticks(rotation=0, fontsize=8)
plt.tight_layout()
cm_path = os.path.join(MODEL_DIR, 'test_confusion_matrix.png')
plt.savefig(cm_path, dpi=150)
plt.close()
print(f"[SAVE]  Confusion matrix: {cm_path}")

# ── Step 9: Top-3 sample prediction ──────────────────────────────────────────
sample_path, sample_true = test_data[0]
raw = tf.io.read_file(sample_path)
img = tf.image.decode_image(raw, channels=3, expand_animations=False)
img = tf.cast(img, tf.float32)
img = tf.image.resize(img, [IMG_SIZE, IMG_SIZE])
img = (img / 127.5) - 1.0
img = tf.expand_dims(img, 0)
sample_probs = model.predict(img, verbose=0)[0]
top3_idx     = np.argsort(sample_probs)[::-1][:3]

print("\n[SAMPLE] Top-3 predictions for test_data[0]:")
print(f"         True class: {CLASS_NAMES[sample_true]}")
for rank, idx in enumerate(top3_idx, 1):
    print(f"         #{rank}: {CLASS_NAMES[idx]:<50s}  {sample_probs[idx]*100:.2f}%")

# ── Step 10: Save evaluation_results.json ────────────────────────────────────
eval_data = {
    'note': 'Evaluated on held-out test set only. 98.83% is val_accuracy on PlantVillage dataset, NOT real-world farmer-photo accuracy.',
    'test_accuracy'        : float(test_acc),
    'test_loss'            : float(test_loss),
    'top3_accuracy'        : float(top3_acc),
    'best_val_accuracy_p1' : 0.9669967293739319,   # from phase1_history.csv epoch 14
    'best_val_accuracy_p2' : 0.9882655143737793,   # from phase2_history.csv epoch 35
    'test_images_evaluated': len(y_true),
    'num_classes'          : NUM_CLASSES,
    'classification_report': report_dict,
    'confusion_matrix'     : cm.tolist(),
    'sample_top3': [
        {'rank': i+1, 'class': CLASS_NAMES[idx], 'confidence': float(sample_probs[idx])}
        for i, idx in enumerate(top3_idx)
    ],
}
eval_path = os.path.join(MODEL_DIR, 'evaluation_results.json')
with open(eval_path, 'w') as f:
    json.dump(eval_data, f, indent=2)
print(f"[SAVE]  evaluation_results.json: {eval_path}")

# ── Step 11: Save class_labels.json ──────────────────────────────────────────
labels_data = {
    'class_names' : CLASS_NAMES,
    'class_to_idx': CLASS_TO_IDX,
    'idx_to_class': {str(k): v for k, v in IDX_TO_CLASS.items()},
}
labels_path = os.path.join(MODEL_DIR, 'class_labels.json')
with open(labels_path, 'w') as f:
    json.dump(labels_data, f, indent=2)
print(f"[SAVE]  class_labels.json: {labels_path}")

# ── Step 12: Verify weights file is untouched ─────────────────────────────────
w_stat_after = os.stat(WEIGHTS)
assert w_stat_after.st_size == w_stat.st_size,  "ERROR: weights file size changed!"
assert w_stat_after.st_mtime == w_stat.st_mtime, "ERROR: weights file was modified!"
print(f"\n[CHECK] best_model.weights.h5 UNTOUCHED OK ({w_size_mb:.2f} MB, {w_mtime})")

# ── Final Summary ─────────────────────────────────────────────────────────────
print()
print("=" * 65)
print("EVALUATION COMPLETE — FINAL SUMMARY")
print("=" * 65)
print(f"  Model loaded successfully    : YES")
print(f"  Test images evaluated        : {len(y_true):,}")
print(f"  Test accuracy                : {test_acc*100:.2f}%")
print(f"  Top-3 accuracy               : {top3_acc*100:.2f}%")
print(f"  Best val accuracy (Phase 2)  : 98.83%  (epoch 35)")
print(f"  Number of classes            : {NUM_CLASSES}")
print(f"  evaluation_results.json      : {eval_path}")
print(f"  class_labels.json            : {labels_path}")
print(f"  test_confusion_matrix.png    : {cm_path}")
print(f"  best_model.weights.h5 intact : YES (untouched)")
print("=" * 65)
