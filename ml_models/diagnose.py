import os
import json
import csv
import random
import numpy as np
import tensorflow as tf
import matplotlib.pyplot as plt

print("=== DIAGNOSIS SCRIPT START ===")

BASE_DIR     = r'c:\Users\Shivang\Desktop\sih\ml_models'
COLOR_DIR    = r'c:\Users\Shivang\Desktop\sih\ml_models\data\PlantVillage-Dataset-master\raw\color'
SPLITS_DIR   = os.path.join(BASE_DIR, 'data', 'dataset_splits')
TRAIN_CSV    = os.path.join(SPLITS_DIR, 'train.csv')
META_JSON    = os.path.join(SPLITS_DIR, 'dataset_meta.json')
SCRATCH_DIR  = r'c:\Users\Shivang\.gemini\antigravity\brain\78c98803-569a-49d1-ae54-d4e4df034509\scratch'
os.makedirs(SCRATCH_DIR, exist_ok=True)

# 1. & 2. CSV Paths and Labels Check
print("\n--- 1 & 2. CSV Path and Label Check ---")
with open(TRAIN_CSV, 'r') as f:
    reader = list(csv.DictReader(f))
    
random.seed(42)
sample_rows = random.sample(reader, 20)
mismatch_count = 0
for row in sample_rows:
    path = row['image_path']
    lbl = row['class']
    # The path should start with the class folder name
    expected_prefix = lbl + os.sep
    if os.name != 'nt':
        expected_prefix = lbl + '/'
    folder_in_path = path.replace('\\', '/').split('/')[0]
    is_correct = folder_in_path == lbl
    if not is_correct:
        mismatch_count += 1
    print(f"Path: {path[:40]:<40} | Label: {lbl[:25]:<25} | Match: {is_correct}")

print(f"Total mismatches in sample: {mismatch_count}")

# 3. Verify Mapping
print("\n--- 3. Label-to-Index Mapping ---")
with open(META_JSON, 'r') as f:
    meta = json.load(f)
class_index = meta['class_index']
print(f"Loaded {len(class_index)} classes from meta JSON.")
print("First 3 map entries:", list(class_index.items())[:3])

# 4. MobileNetV3 Preprocessing Check
print("\n--- 4. MobileNetV3 Preprocessing Check ---")
# Check how preprocess_input modifies a dummy image (0-255)
dummy_img = np.array([[[0.0, 127.5, 255.0]]], dtype=np.float32)
preprocessed = tf.keras.applications.mobilenet_v3.preprocess_input(dummy_img.copy())
print(f"Raw dummy input: {dummy_img.flatten()}")
print(f"After preprocess_input: {preprocessed.numpy().flatten()}")

# Check if base model has built-in Rescaling
base = tf.keras.applications.MobileNetV3Large(include_preprocessing=False, input_shape=(224, 224, 3))
rescaling_layers = [l for l in base.layers if 'rescaling' in l.name.lower()]
print(f"Number of internal Rescaling layers in base model: {len(rescaling_layers)}")
if len(rescaling_layers) > 0:
    print("WARNING: MobileNetV3 includes built-in rescaling even with include_preprocessing=False!")
    print(f"Layer details: {rescaling_layers[0].name} - {rescaling_layers[0].get_config()}")

# 6. Augmentation Check
print("\n--- 6. Augmentation Corruption Check ---")
random_rot = tf.keras.layers.RandomRotation(0.05, fill_mode='reflect')
random_zoom = tf.keras.layers.RandomZoom(0.1, fill_mode='reflect')

def augment_test(img):
    img = tf.image.random_flip_left_right(img)
    img = tf.image.random_brightness(img, max_delta=0.2)
    img = tf.image.random_contrast(img, 0.8, 1.2)
    img = random_rot(tf.expand_dims(img, 0), training=True)[0]
    img = random_zoom(tf.expand_dims(img, 0), training=True)[0]
    img = tf.clip_by_value(img, -1.0, 1.0)
    return img

test_img_path = os.path.join(COLOR_DIR, sample_rows[0]['image_path'])
raw = tf.io.read_file(test_img_path)
img = tf.image.decode_image(raw, channels=3, expand_animations=False)
img = tf.cast(img, tf.float32)
img = tf.image.resize(img, [224, 224])
# Assuming preprocess_input scales to [-1, 1]
img_pre = tf.keras.applications.mobilenet_v3.preprocess_input(img)
img_aug = augment_test(img_pre)

print(f"Original image shape: {img.shape}, min: {tf.reduce_min(img)}, max: {tf.reduce_max(img)}")
print(f"Preprocessed shape: {img_pre.shape}, min: {tf.reduce_min(img_pre):.2f}, max: {tf.reduce_max(img_pre):.2f}")
print(f"Augmented shape: {img_aug.shape}, min: {tf.reduce_min(img_aug):.2f}, max: {tf.reduce_max(img_aug):.2f}")

# 7. Overfit Sanity Test (200 images, no augmentation, no class weights)
print("\n--- 7. Overfit Sanity Test ---")
overfit_sample = random.sample(reader, 200)
paths = [os.path.join(COLOR_DIR, r['image_path']) for r in overfit_sample]
labels = [class_index[r['class']] for r in overfit_sample]

path_ds = tf.data.Dataset.from_tensor_slices(paths)
label_ds = tf.data.Dataset.from_tensor_slices(labels)
ds = tf.data.Dataset.zip((path_ds, label_ds))

def simple_load(path, label):
    raw = tf.io.read_file(path)
    img = tf.image.decode_image(raw, channels=3, expand_animations=False)
    img = tf.cast(img, tf.float32)
    img = tf.image.resize(img, [224, 224])
    # ONLY use preprocess_input, no augmentations
    img = tf.keras.applications.mobilenet_v3.preprocess_input(img)
    return img, label

ds = ds.map(simple_load).batch(32)

inputs = tf.keras.Input(shape=(224, 224, 3))
x = base(inputs, training=False) # Freeze batch norm stats but trainable layers update
x = tf.keras.layers.GlobalAveragePooling2D()(x)
x = tf.keras.layers.Dense(128, activation='relu')(x)
outputs = tf.keras.layers.Dense(21, activation='softmax')(x)
model = tf.keras.Model(inputs, outputs)

# We make the whole model trainable to quickly force overfitting on 200 images
model.trainable = True

model.compile(optimizer=tf.keras.optimizers.Adam(1e-3),
              loss='sparse_categorical_crossentropy',
              metrics=['accuracy'])

print("Starting 10 epochs of training on 200 images...")
history = model.fit(ds, epochs=10, verbose=1)

print("\nFinal overfit accuracy:", history.history['accuracy'][-1])
if history.history['accuracy'][-1] > 0.80:
    print("SANITY TEST PASSED: Model is capable of learning and mapping labels correctly.")
else:
    print("SANITY TEST FAILED: Model could not overfit a tiny dataset.")

print("=== DIAGNOSIS SCRIPT END ===")

