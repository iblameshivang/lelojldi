import os, json, csv, random, numpy as np, tensorflow as tf
from sklearn.utils.class_weight import compute_class_weight

print("=== PRE-TRAINING AUDIT START ===")

BASE_DIR = r'c:\Users\Shivang\Desktop\sih\ml_models'
COLOR_DIR = os.path.join(BASE_DIR, 'data', 'PlantVillage-Dataset-master', 'raw', 'color')
SPLITS_DIR = os.path.join(BASE_DIR, 'data', 'dataset_splits')

def load_csv(name):
    with open(os.path.join(SPLITS_DIR, name), 'r') as f:
        return list(csv.DictReader(f))

train_data = load_csv('train.csv')
val_data = load_csv('val.csv')
test_data = load_csv('test.csv')

with open(os.path.join(SPLITS_DIR, 'dataset_meta.json'), 'r') as f:
    meta = json.load(f)

class_index = meta['class_index']

print("\n1. DATASET")
classes_in_train = set([r['class'] for r in train_data])
classes_in_val = set([r['class'] for r in val_data])
classes_in_test = set([r['class'] for r in test_data])
print(f"Train classes: {len(classes_in_train)}, Val: {len(classes_in_val)}, Test: {len(classes_in_test)}")
print(f"Total Images: {meta['total_images']} (Train: {len(train_data)}, Val: {len(val_data)}, Test: {len(test_data)})")

train_paths = set([r['image_path'] for r in train_data])
val_paths = set([r['image_path'] for r in val_data])
test_paths = set([r['image_path'] for r in test_data])
intersections = len(train_paths & val_paths) + len(train_paths & test_paths) + len(val_paths & test_paths)
print(f"Duplicate paths across splits: {intersections}")

print("\n2. LABELS")
sample = random.choice(train_data)
path = sample['image_path']
csv_class = sample['class']
num_label = class_index[csv_class]
folder = path.replace('\\', '/').split('/')[0]
print(f"Sample - Folder: {folder} | CSV Class: {csv_class} | Numeric: {num_label}")

print("\n3. & 4. PREPROCESSING & PIPELINE")
def build_pipeline(data, training=False):
    paths = [os.path.join(COLOR_DIR, r['image_path']) for r in data]
    labels = [class_index[r['class']] for r in data]
    ds = tf.data.Dataset.zip((tf.data.Dataset.from_tensor_slices(paths), tf.data.Dataset.from_tensor_slices(labels)))
    
    random_rot = tf.keras.layers.RandomRotation(0.05, fill_mode='reflect')
    random_zoom = tf.keras.layers.RandomZoom(0.1, fill_mode='reflect')
    
    def process(path, label):
        raw = tf.io.read_file(path)
        img = tf.image.decode_image(raw, channels=3, expand_animations=False)
        img = tf.cast(img, tf.float32)
        img = tf.image.resize(img, [224, 224])
        # CORRECT SCALING
        img = (img / 127.5) - 1.0
        
        if training:
            img = tf.image.random_flip_left_right(img)
            img = tf.image.random_brightness(img, max_delta=0.2)
            img = tf.image.random_contrast(img, 0.8, 1.2)
            img = random_rot(tf.expand_dims(img, 0), training=True)[0]
            img = random_zoom(tf.expand_dims(img, 0), training=True)[0]
            img = tf.clip_by_value(img, -1.0, 1.0)
        return img, label
    
    if training: ds = ds.shuffle(100)
    return ds.map(process).batch(32)

val_ds = build_pipeline(val_data, training=False)
val_batch = next(iter(val_ds))[0]
print(f"Val batch shape: {val_batch.shape}, Min: {tf.reduce_min(val_batch):.3f}, Max: {tf.reduce_max(val_batch):.3f}")

train_ds = build_pipeline(train_data, training=True)
train_batch = next(iter(train_ds))[0]
print(f"Train batch shape: {train_batch.shape}, Min: {tf.reduce_min(train_batch):.3f}, Max: {tf.reduce_max(train_batch):.3f}")
has_nan = tf.reduce_any(tf.math.is_nan(train_batch))
print(f"Contains NaNs: {has_nan.numpy()}")

print("\n5. MODEL")
base = tf.keras.applications.MobileNetV3Large(include_preprocessing=False, input_shape=(224,224,3), weights='imagenet', include_top=False)
inputs = tf.keras.Input(shape=(224, 224, 3))
x = base(inputs, training=False)
x = tf.keras.layers.GlobalAveragePooling2D()(x)
x = tf.keras.layers.Dense(512, activation='relu')(x)
outputs = tf.keras.layers.Dense(21, activation='softmax')(x)
model = tf.keras.Model(inputs, outputs)
print(f"Output shape: {model.output_shape}, Activation: softmax, Loss: sparse_categorical_crossentropy")

print("\n6. CLASS IMBALANCE")
y_train = [class_index[r['class']] for r in train_data]
cw = compute_class_weight('balanced', classes=np.arange(21), y=y_train)
print(f"Min weight: {np.min(cw):.3f}, Max weight: {np.max(cw):.3f}, Ratio: {np.max(cw)/np.min(cw):.1f}x")

print("\n8. SANITY TEST (200 images, EXACT setup)")
random.seed(42)
tf.random.set_seed(42)
np.random.set_seed(42)
sanity_data = random.sample(train_data, 200)
sanity_ds = build_pipeline(sanity_data, training=True)

model.trainable = True # train everything for fast overfitting
model.compile(optimizer=tf.keras.optimizers.Adam(1e-3), loss='sparse_categorical_crossentropy', metrics=['accuracy'])
history = model.fit(sanity_ds, epochs=15, verbose=0)
print(f"Sanity Test Final Accuracy: {history.history['accuracy'][-1]:.3f}")

print("=== PRE-TRAINING AUDIT END ===")

