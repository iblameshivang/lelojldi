
/// AR Spot-Spraying service.
/// Calculates disease boundaries, affected area, and chemical dosage.
class DosageCalculator {
  // Common pesticide dosage table (per hectare)
  static const Map<String, PesticideInfo> pesticideDatabase = {
    'mancozeb': PesticideInfo(
      name: 'Mancozeb 75 WP',
      nameHi: 'मैंकोज़ेब 75 WP',
      dosePerHa: 2000, // grams per hectare
      waterPerHa: 500,  // liters of water per hectare
      dilutionRatio: '2.5g/L',
      safetyInterval: 7, // days before harvest
      targetDiseases: ['Late Blight', 'Early Blight', 'Downy Mildew'],
    ),
    'copper_oxychloride': PesticideInfo(
      name: 'Copper Oxychloride 50 WP',
      nameHi: 'कॉपर ऑक्सीक्लोराइड 50 WP',
      dosePerHa: 3000,
      waterPerHa: 500,
      dilutionRatio: '3g/L',
      safetyInterval: 14,
      targetDiseases: ['Bacterial Blight', 'Leaf Spot', 'Canker'],
    ),
    'propiconazole': PesticideInfo(
      name: 'Propiconazole 25 EC',
      nameHi: 'प्रोपिकोनाज़ोल 25 EC',
      dosePerHa: 500,
      waterPerHa: 500,
      dilutionRatio: '1ml/L',
      safetyInterval: 21,
      targetDiseases: ['Rust', 'Powdery Mildew', 'Sheath Blight'],
    ),
    'imidacloprid': PesticideInfo(
      name: 'Imidacloprid 17.8 SL',
      nameHi: 'इमिडाक्लोप्रिड 17.8 SL',
      dosePerHa: 100,
      waterPerHa: 500,
      dilutionRatio: '0.5ml/L',
      safetyInterval: 14,
      targetDiseases: ['Aphids', 'Jassids', 'Whitefly', 'Thrips'],
    ),
    'neem_oil': PesticideInfo(
      name: 'Neem Oil (Organic)',
      nameHi: 'नीम तेल (जैविक)',
      dosePerHa: 5000,
      waterPerHa: 500,
      dilutionRatio: '5ml/L',
      safetyInterval: 0,
      targetDiseases: ['General pest control', 'Organic farming'],
    ),
  };

  /// Calculate chemical dosage for a given affected area.
  Map<String, dynamic> calculateDosage({
    double? areaSqMeters,
    double? areaSqm,
    String? pesticide,
    String? chemical,
    String? crop,
    double sprayerCapacityLiters = 16, // Standard knapsack sprayer
  }) {
    final area = areaSqm ?? areaSqMeters ?? 10.0;
    final chem = chemical ?? pesticide ?? 'Mancozeb 75 WP';
    final waterLiters = area * 0.15; // 0.15 L per m2
    final chemicalMl = waterLiters * 1.5; // 1.5 ml per liter

    return {
      'chemical_ml': chemicalMl,
      'water_liters': waterLiters,
      'area_sqm': area,
      'chemical_name': chem,
      'crop': crop ?? 'Wheat',
      'tank_loads': (waterLiters / sprayerCapacityLiters).ceil(),
      'dosage_rate': '1.5 ml/L',
      'spray_pressure_bar': 2.5,
    };
  }

  /// Recommend pesticide based on disease name.
  String recommendPesticide(String diseaseName) {
    final disease = diseaseName.toLowerCase();
    if (disease.contains('blight')) return 'mancozeb';
    if (disease.contains('rust')) return 'propiconazole';
    if (disease.contains('bacterial')) return 'copper_oxychloride';
    if (disease.contains('aphid') || disease.contains('thrip') || disease.contains('jassid')) {
      return 'imidacloprid';
    }
    return 'neem_oil'; // Default organic option
  }

  /// Calculate convex hull area from boundary points.
  double calculateBoundaryArea(List<Point> points) {
    if (points.length < 3) return 0;

    // Shoelace formula
    double area = 0;
    for (int i = 0; i < points.length; i++) {
      int j = (i + 1) % points.length;
      area += points[i].x * points[j].y;
      area -= points[j].x * points[i].y;
    }
    return (area.abs() / 2);
  }
}

class PesticideInfo {
  final String name;
  final String nameHi;
  final double dosePerHa;
  final double waterPerHa;
  final String dilutionRatio;
  final int safetyInterval;
  final List<String> targetDiseases;

  const PesticideInfo({
    required this.name,
    required this.nameHi,
    required this.dosePerHa,
    required this.waterPerHa,
    required this.dilutionRatio,
    required this.safetyInterval,
    required this.targetDiseases,
  });
}

class SprayDosage {
  final PesticideInfo pesticide;
  final double areaSqMeters;
  final double areaHectares;
  final double totalChemicalGrams;
  final double totalWaterLiters;
  final int tankLoads;
  final double chemicalPerTankGrams;
  final double waterPerTankLiters;
  final double sprayerCapacity;

  SprayDosage({
    required this.pesticide,
    required this.areaSqMeters,
    required this.areaHectares,
    required this.totalChemicalGrams,
    required this.totalWaterLiters,
    required this.tankLoads,
    required this.chemicalPerTankGrams,
    required this.waterPerTankLiters,
    required this.sprayerCapacity,
  });

  String getSummaryHi() {
    return '''🎯 छिड़काव मार्गदर्शन:
• क्षेत्र: ${areaSqMeters.toStringAsFixed(1)} वर्ग मीटर (${areaHectares.toStringAsFixed(4)} हेक्टेयर)
• दवाई: ${pesticide.nameHi}
• कुल दवाई: ${totalChemicalGrams.toStringAsFixed(1)} ग्राम
• कुल पानी: ${totalWaterLiters.toStringAsFixed(1)} लीटर
• टैंक भरे: $tankLoads बार
• प्रति टैंक: ${chemicalPerTankGrams.toStringAsFixed(1)}g दवाई + ${waterPerTankLiters.toStringAsFixed(1)}L पानी
• कटाई से पहले: ${pesticide.safetyInterval} दिन रुकें''';
  }
}

class Point {
  final double x;
  final double y;
  const Point(this.x, this.y);
}
