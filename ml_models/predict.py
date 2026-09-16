import os, sys, json, warnings
warnings.filterwarnings('ignore')
os.environ['TF_CPP_MIN_LOG_LEVEL'] = '3'
os.environ['TF_ENABLE_ONEDNN_OPTS'] = '0'
os.environ['CUDA_VISIBLE_DEVICES']  = '-1'

import logging
logging.disable(logging.CRITICAL)

import numpy as np
import tensorflow as tf
tf.get_logger().setLevel('ERROR')
from tensorflow import keras
from tensorflow.keras import layers, Model
from tensorflow.keras.applications import MobileNetV3Large

# ── Paths ─────────────────────────────────────────────────────────────────────
BASE_DIR    = os.path.dirname(os.path.abspath(__file__))
MODEL_DIR   = os.path.join(BASE_DIR, 'models', 'plant_disease_v1')
WEIGHTS     = os.path.join(MODEL_DIR, 'best_model.weights.h5')
LABELS_JSON = os.path.join(MODEL_DIR, 'class_labels.json')

IMG_SIZE        = 224
NUM_CLASSES     = 21
LOW_CONF_THRESH = 0.50

PLANT_CLASS_INDICES = {
    'apple':  [0, 1, 2, 3],
    'maize':  [4, 5, 6, 7],
    'potato': [8, 9, 10],
    'tomato': [11, 12, 13, 14, 15, 16, 17, 18, 19, 20],
}

PLANT_DISPLAY = {'apple': 'Apple', 'maize': 'Maize', 'potato': 'Potato', 'tomato': 'Tomato'}


def select_plant():
    options = [('1', 'tomato', 'Tomato'),
               ('2', 'potato', 'Potato'),
               ('3', 'maize',  'Maize'),
               ('4', 'apple',  'Apple')]
    print()
    print("  Select your crop/plant:")
    for num, _, label in options:
        print(f"    {num}. {label}")
    print()
    while True:
        choice = input("  Enter number (1-4): ").strip()
        for num, key, _ in options:
            if choice == num:
                return key
        print("  Invalid. Enter 1, 2, 3, or 4.")


def build_model():
    base = MobileNetV3Large(
        input_shape=(IMG_SIZE, IMG_SIZE, 3),
        include_top=False, weights=None, include_preprocessing=False,
    )
    base.trainable = False
    inputs = keras.Input(shape=(IMG_SIZE, IMG_SIZE, 3))
    x = base(inputs, training=False)
    x = layers.GlobalAveragePooling2D()(x)
    x = layers.BatchNormalization()(x)
    x = layers.Dense(512, activation='relu', kernel_regularizer=tf.keras.regularizers.l2(1e-4))(x)
    x = layers.Dropout(0.4)(x)
    x = layers.Dense(256, activation='relu', kernel_regularizer=tf.keras.regularizers.l2(1e-4))(x)
    x = layers.Dropout(0.3)(x)
    outputs = layers.Dense(NUM_CLASSES, activation='softmax')(x)
    return Model(inputs, outputs, name='PlantDisease_MobileNetV3L')


def preprocess(path):
    raw = tf.io.read_file(path)
    img = tf.image.decode_image(raw, channels=3, expand_animations=False)
    img = tf.cast(img, tf.float32)
    img = tf.image.resize(img, [IMG_SIZE, IMG_SIZE])
    img = (img / 127.5) - 1.0
    return tf.expand_dims(img, 0)


def filtered_predict(probs, plant_key, class_names):
    indices        = PLANT_CLASS_INDICES[plant_key]
    raw            = np.array([probs[i] for i in indices])
    total          = raw.sum()
    norm           = raw / total if total > 0 else raw
    order          = np.argsort(norm)[::-1]
    return {
        'predicted_class': class_names[indices[order[0]]],
        'confidence':      float(norm[order[0]]),
        'plant_mass':      float(total),
        'top3': [
            {'rank': r+1, 'class': class_names[indices[order[r]]], 'confidence': float(norm[order[r]])}
            for r in range(min(3, len(indices)))
        ],
    }


def main():
    if len(sys.argv) < 2:
        print("Usage: python predict.py <image_path>")
        print("Example: python predict.py test_images\\leaf.jpg")
        sys.exit(1)

    image_path = sys.argv[1]
    if not os.path.isfile(image_path):
        print(f"ERROR: Image not found: {image_path}")
        sys.exit(1)

    # Always ask plant interactively
    plant_key = select_plant()

    with open(LABELS_JSON) as f:
        class_names = json.load(f)['class_names']

    model = build_model()
    model.load_weights(WEIGHTS)

    probs  = model.predict(preprocess(image_path), verbose=0)[0]
    result = filtered_predict(probs, plant_key, class_names)

    sep = "=" * 58
    print()
    print(sep)
    print("  PLANT DISEASE PREDICTION")
    print(sep)
    print(f"  Image         : {os.path.basename(image_path)}")
    print(f"  Selected plant: {PLANT_DISPLAY[plant_key]}")
    print()
    print(f"  Predicted     : {result['predicted_class']}")
    print(f"  Confidence    : {result['confidence']*100:.2f}%")

    if result['confidence'] < LOW_CONF_THRESH:
        print()
        print("  WARNING: Low confidence — image may be ambiguous.")

    if result['plant_mass'] < 0.40:
        print()
        print(f"  NOTE: Only {result['plant_mass']*100:.1f}% of model probability assigned to")
        print(f"        {PLANT_DISPLAY[plant_key]} — consider verifying plant selection.")

    print()
    print(f"  Top-3 {PLANT_DISPLAY[plant_key]} predictions:")
    for e in result['top3']:
        bar = "#" * int(e['confidence'] * 30)
        print(f"    #{e['rank']}  {e['confidence']*100:6.2f}%  {bar:<30}  {e['class']}")

    print(sep)
    print()


if __name__ == '__main__':
    main()
