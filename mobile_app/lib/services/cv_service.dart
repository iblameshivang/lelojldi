import 'dart:io';
import 'dart:math';

/// Computer Vision service for crop disease detection using TFLite/ONNX models.
class CVService {
  static const String modelPath = 'assets/models/mobilenetv4_leaf_classifier_int8.tflite';
  static const String labelsPath = 'assets/models/labels.txt';
  static const int inputSize = 224;
  static const int numClasses = 38; // PlantVillage dataset classes

  bool _isInitialized = false;
  List<String> _labels = [];

  // Disease name mapping (English -> Hindi)
  static const Map<String, String> diseaseNamesHindi = {
    'Apple___Apple_scab': 'सेब - पपड़ी रोग',
    'Apple___Black_rot': 'सेब - काला सड़न',
    'Apple___Cedar_apple_rust': 'सेब - जंग रोग',
    'Apple___healthy': 'सेब - स्वस्थ',
    'Corn___Common_rust': 'मक्का - सामान्य जंग',
    'Corn___Gray_leaf_spot': 'मक्का - भूरा पत्ती धब्बा',
    'Corn___healthy': 'मक्का - स्वस्थ',
    'Grape___Black_rot': 'अंगूर - काला सड़न',
    'Grape___healthy': 'अंगूर - स्वस्थ',
    'Potato___Early_blight': 'आलू - अगेती अंगमारी',
    'Potato___Late_blight': 'आलू - पछेती अंगमारी',
    'Potato___healthy': 'आलू - स्वस्थ',
    'Rice___Bacterial_leaf_blight': 'चावल - जीवाणु पत्ती झुलसा',
    'Rice___Brown_spot': 'चावल - भूरा धब्बा',
    'Rice___Leaf_smut': 'चावल - पत्ती कांगियारी',
    'Rice___healthy': 'चावल - स्वस्थ',
    'Tomato___Bacterial_spot': 'टमाटर - जीवाणु धब्बा',
    'Tomato___Early_blight': 'टमाटर - अगेती अंगमारी',
    'Tomato___Late_blight': 'टमाटर - पछेती अंगमारी',
    'Tomato___Leaf_Mold': 'टमाटर - पत्ती फफूंद',
    'Tomato___healthy': 'टमाटर - स्वस्थ',
    'Wheat___Brown_rust': 'गेहूं - भूरी जंग',
    'Wheat___Yellow_rust': 'गेहूं - पीली जंग',
    'Wheat___healthy': 'गेहूं - स्वस्थ',
  };

  // Treatment recommendations
  static const Map<String, Map<String, String>> treatments = {
    'Rice___Bacterial_leaf_blight': {
      'en': 'Apply streptocycline (0.01%) + copper oxychloride (0.25%). Drain excess water. Use resistant varieties like Improved Samba Mahsuri.',
      'hi': 'स्ट्रेप्टोसाइक्लिन (0.01%) + कॉपर ऑक्सीक्लोराइड (0.25%) का छिड़काव करें। अतिरिक्त पानी निकालें। प्रतिरोधी किस्मों का उपयोग करें।',
    },
    'Tomato___Late_blight': {
      'en': 'Spray Mancozeb (0.25%) or Metalaxyl + Mancozeb. Remove infected parts. Ensure proper spacing.',
      'hi': 'मैंकोज़ेब (0.25%) या मेटालैक्सिल + मैंकोज़ेब का छिड़काव करें। संक्रमित हिस्से हटाएं। उचित दूरी रखें।',
    },
    'Wheat___Brown_rust': {
      'en': 'Spray Propiconazole (0.1%) at first symptom. Use resistant varieties. Avoid late sowing.',
      'hi': 'पहले लक्षण पर प्रोपिकोनाज़ोल (0.1%) का छिड़काव करें। प्रतिरोधी किस्मों का उपयोग करें। देर से बुवाई से बचें।',
    },
    'Potato___Late_blight': {
      'en': 'Apply Mancozeb (0.25%) preventively. Spray Cymoxanil + Mancozeb when symptoms appear. Harvest early.',
      'hi': 'मैंकोज़ेब (0.25%) का निवारक छिड़काव करें। लक्षण दिखने पर सिमोक्सानिल + मैंकोज़ेब लगाएं। जल्दी कटाई करें।',
    },
  };

  /// Initialize the CV model (load TFLite model + labels).
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // In production: load TFLite model via tflite_flutter
      // For demo: load labels and simulate inference
      _labels = _getDefaultLabels();
      _isInitialized = true;
    } catch (e) {
      print('CV Service init error: $e');
      _labels = _getDefaultLabels();
      _isInitialized = true;
    }
  }

  /// Run inference on an image file.
  Future<DiagnosisResult> diagnose(File imageFile) async {
    if (!_isInitialized) await initialize();

    // In production: preprocess image -> run TFLite inference
    // For demo: simulate realistic inference
    final random = Random();
    final diseaseIndex = random.nextInt(_labels.length);
    final diseaseName = _labels[diseaseIndex];
    final confidence = 0.75 + random.nextDouble() * 0.20; // 75-95% confidence

    final hindiName = diseaseNamesHindi[diseaseName] ?? diseaseName;
    final treatment = treatments[diseaseName];
    final severity = _calculateSeverity(confidence);

    return DiagnosisResult(
      diseaseName: diseaseName,
      diseaseNameHi: hindiName,
      confidence: confidence,
      severity: severity,
      treatmentEn: treatment?['en'] ?? 'Consult your local agricultural officer.',
      treatmentHi: treatment?['hi'] ?? 'अपने स्थानीय कृषि अधिकारी से परामर्श करें।',
      cropType: _extractCropType(diseaseName),
      isHealthy: diseaseName.contains('healthy'),
      modelVersion: 'mobilenetv4_int8_v1',
    );
  }

  String _calculateSeverity(double confidence) {
    if (confidence >= 0.85) return 'critical';
    if (confidence >= 0.70) return 'high';
    if (confidence >= 0.50) return 'medium';
    if (confidence >= 0.30) return 'low';
    return 'healthy';
  }

  String _extractCropType(String diseaseName) {
    return diseaseName.split('___').first.toLowerCase();
  }

  List<String> _getDefaultLabels() {
    return diseaseNamesHindi.keys.toList();
  }
}

/// Result of a crop disease diagnosis.
class DiagnosisResult {
  final String diseaseName;
  final String diseaseNameHi;
  final double confidence;
  final String severity;
  final String treatmentEn;
  final String treatmentHi;
  final String cropType;
  final bool isHealthy;
  final String modelVersion;

  DiagnosisResult({
    required this.diseaseName,
    required this.diseaseNameHi,
    required this.confidence,
    required this.severity,
    required this.treatmentEn,
    required this.treatmentHi,
    required this.cropType,
    required this.isHealthy,
    required this.modelVersion,
  });

  Map<String, dynamic> toJson() => {
    'disease_name': diseaseName,
    'disease_name_hi': diseaseNameHi,
    'confidence': confidence,
    'severity': severity,
    'treatment_en': treatmentEn,
    'treatment_hi': treatmentHi,
    'crop_type': cropType,
    'is_healthy': isHealthy,
    'model_version': modelVersion,
  };
}
