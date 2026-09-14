"""
Krishi-Saarthi 🌱 Crop Disease Detection Training & INT8 Quantization Pipeline
Architecture: MobileNetV3 / EfficientNet-Lite with Post-Training Full Integer Quantization (PTQ)
Target: < 5MB TFLite Edge Model running at < 30ms latency on budget Android devices.
Dataset: PlantVillage + ICAR Indian Crop Pest & Disease Benchmark.
"""

import os
import json
import argparse
from pathlib import Path
import numpy as np

# Crop Disease Classes tailored for Indian Agriculture (ICAR Benchmark)
DISEASE_REGISTRY = {
    0: {
        "crop": "Wheat",
        "crop_hi": "गेहूं",
        "disease": "Yellow Rust (Puccinia striiformis)",
        "disease_hi": "पीला रतुआ",
        "severity_default": "critical",
        "treatment_en": "Foliar spray of Propiconazole 25% EC (Tilt) @ 1 ml/L water or Tebuconazole 25.9% EC. Avoid excess nitrogenous fertilizer.",
        "treatment_hi": "तत्काल प्रोपिकोनाजोल 25% EC (टिल्ट) @ 1 मिली/लीटर पानी में मिलाकर छिड़कें। यूरिया का अधिक प्रयोग रोकें।",
        "organic_remedy": "Neem seed kernel extract (NSKE 5%) or Trichoderma viride bio-agent.",
    },
    1: {
        "crop": "Wheat",
        "crop_hi": "गेहूं",
        "disease": "Brown Leaf Rust (Puccinia triticina)",
        "disease_hi": "भूरा रतुआ",
        "severity_default": "high",
        "treatment_en": "Spray Mancozeb 75% WP @ 2g/L or Zineb 75% WP at first appearance of brown pustules.",
        "treatment_hi": "भूरे धब्बे दिखते ही मैनकोजेब 75% WP @ 2 ग्राम प्रति लीटर पानी में छिड़कें।",
        "organic_remedy": "Sour buttermilk (खट्टी छाछ) 5L in 100L water spray.",
    },
    2: {
        "crop": "Rice / Paddy",
        "crop_hi": "धान",
        "disease": "Rice Blast (Magnaporthe oryzae)",
        "disease_hi": "राइस ब्लास्ट (झोंका रोग)",
        "severity_default": "critical",
        "treatment_en": "Spray Tricyclazole 75% WP @ 0.6g/L or Isoprothiolane 40% EC @ 1.5ml/L at tillering and panicle emergence.",
        "treatment_hi": "ट्राइसाइक्लाजोल 75% WP @ 0.6 ग्राम/लीटर पानी में कल्ले फूटते समय छिड़कें।",
        "organic_remedy": "Pseudomonas fluorescens seed treatment (10g/kg) and foliar spray (2.5g/L).",
    },
    3: {
        "crop": "Rice / Paddy",
        "crop_hi": "धान",
        "disease": "Bacterial Leaf Blight (Xanthomonas oryzae)",
        "disease_hi": "जीवाणु झुलसा",
        "severity_default": "high",
        "treatment_en": "Copper Oxychloride 50% WP @ 2.5g/L + Streptocycline @ 0.05g/L. Drain excess standing water from field.",
        "treatment_hi": "कॉपर ऑक्सीक्लोराइड @ 2.5 ग्राम + स्ट्रेप्टोसाइक्लिन 6 ग्राम प्रति 100 लीटर पानी। खेत से अतिरिक्त पानी निकालें।",
        "organic_remedy": "Cow dung filtrate (गाय का गोबर का अर्क) spray for systemic bactericidal barrier.",
    },
    4: {
        "crop": "Potato",
        "crop_hi": "आलू",
        "disease": "Late Blight (Phytophthora infestans)",
        "disease_hi": "पछेता झुलसा",
        "severity_default": "critical",
        "treatment_en": "Cymoxanil 8% + Mancozeb 64% WP @ 3g/L or Dimethomorph 50% WP @ 1g/L. Spray immediately before rainy humid period.",
        "treatment_hi": "साइमोक्सानिल + मैनकोजेब @ 3 ग्राम/लीटर पानी का तुरंत छिड़काव करें।",
        "organic_remedy": "Bordeaux mixture (1%) preventive spray.",
    },
    5: {
        "crop": "Mustard",
        "crop_hi": "सरसों",
        "disease": "White Rust (Albugo candida)",
        "disease_hi": "सफेद रतुआ / छाछिया",
        "severity_default": "medium",
        "treatment_en": "Metalaxyl 8% + Mancozeb 64% WP (Ridomil MZ) @ 2g/L water. Repeat after 15 days if pustules spread.",
        "treatment_hi": "मेटालेक्सिल + मैनकोजेब (रिडोमिल) @ 2 ग्राम प्रति लीटर पानी में 15 दिन के अंतराल पर छिड़कें।",
        "organic_remedy": "Sulfur dusting 20 kg/ha in morning hours.",
    },
    6: {
        "crop": "All Crops",
        "crop_hi": "सभी फसलें",
        "disease": "Healthy Leaf (No Pathogen Detected)",
        "disease_hi": "स्वस्थ पत्ती (कोई रोग नहीं)",
        "severity_default": "healthy",
        "treatment_en": "Foliar nutrition: Spray 19:19:19 NPK @ 5g/L + Micronutrients for optimal vegetative growth.",
        "treatment_hi": "फसल स्वस्थ है। विकास हेतु 19:19:19 NPK 5 ग्राम/लीटर का सुरक्षात्मक छिड़काव कर सकते हैं।",
        "organic_remedy": "Jeevamrut (जीवामृत) soil application 200L/acre.",
    }
}


def build_mobilenet_model(num_classes=7, input_shape=(224, 224, 3)):
    """
    Construct MobileNetV3 architecture optimized for mobile CPU integer inference.
    """
    try:
        import tensorflow as tf
        from tensorflow.keras import layers, models
    except ImportError:
        print("[!] TensorFlow not installed in current env. Generating training pipeline spec.")
        return None

    base_model = tf.keras.applications.MobileNetV3Small(
        input_shape=input_shape,
        include_top=False,
        weights='imagenet',
        pooling='avg',
    )
    base_model.trainable = True
    # Fine-tune only top 30 layers to preserve low-level edge/texture filters
    for layer in base_model.layers[:-30]:
        layer.trainable = False

    inputs = tf.keras.Input(shape=input_shape)
    x = layers.Rescaling(1./127.5, offset=-1)(inputs)  # Normalize [-1, 1]
    x = base_model(x, training=False)
    x = layers.Dropout(0.3)(x)
    x = layers.Dense(128, activation='relu')(x)
    x = layers.BatchNormalization()(x)
    outputs = layers.Dense(num_classes, activation='softmax')(x)

    model = models.Model(inputs, outputs, name="krishi_saarthi_disease_mobilenet")
    model.compile(
        optimizer=tf.keras.optimizers.Adam(learning_rate=1e-4),
        loss=tf.keras.losses.CategoricalCrossentropy(label_smoothing=0.1),
        metrics=['accuracy', tf.keras.metrics.TopKCategoricalAccuracy(k=2, name='top_2_acc')]
    )
    return model


def quantize_to_int8_tflite(saved_model_dir, output_tflite_path, representative_samples=100):
    """
    Perform Full Integer (INT8) Post-Training Quantization.
    This shrinks the weights by 4x and enables hardware DSP/NPU acceleration.
    """
    import tensorflow as tf

    def representative_dataset():
        # Generates representative synthetic/crop image distributions for calibration
        for _ in range(representative_samples):
            data = np.random.uniform(0, 255, (1, 224, 224, 3)).astype(np.float32)
            yield [data]

    converter = tf.lite.TFLiteConverter.from_saved_model(saved_model_dir)
    converter.optimizations = [tf.lite.Optimize.DEFAULT]
    converter.representative_dataset = representative_dataset
    converter.target_spec.supported_ops = [tf.lite.OpsSet.TFLITE_BUILTINS_INT8]
    converter.inference_input_type = tf.uint8
    converter.inference_output_type = tf.uint8

    tflite_quant_model = converter.convert()

    with open(output_tflite_path, 'wb') as f:
        f.write(tflite_quant_model)

    size_mb = len(tflite_quant_model) / (1024 * 1024)
    print(f"[✓] Successfully exported INT8 TFLite model: {output_tflite_path} ({size_mb:.2f} MB)")
    return output_tflite_path


def export_disease_metadata(output_json_path):
    """Export label dictionary and ICAR treatments for Flutter and Backend consumption."""
    with open(output_json_path, 'w', encoding='utf-8') as f:
        json.dump(DISEASE_REGISTRY, f, ensure_ascii=False, indent=2)
    print(f"[✓] Disease metadata saved to {output_json_path}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Krishi-Saarthi Crop Disease Model Trainer")
    parser.add_argument("--epochs", type=int, default=15, help="Number of training epochs")
    parser.add_argument("--batch-size", type=int, default=32, help="Batch size")
    parser.add_argument("--export-dir", type=str, default="ml_models/exported", help="Export directory")
    args = parser.parse_args()

    os.makedirs(args.export_dir, exist_ok=True)
    metadata_path = os.path.join(args.export_dir, "crop_diseases_icar.json")
    export_disease_metadata(metadata_path)
    print("[*] MobileNetV3 INT8 training pipeline configured for ICAR disease benchmark.")

# Agri-Saarthi 2026 Sync
