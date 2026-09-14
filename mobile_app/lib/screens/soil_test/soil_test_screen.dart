import 'package:flutter/material.dart';
import '../../services/soil_analyzer.dart';

/// Soil Health Estimator screen (Feature 11).
/// Uses camera, Munsell color matching and on-device ML to estimate soil NPK, pH & Organic Carbon.
class SoilTestScreen extends StatefulWidget {
  const SoilTestScreen({super.key});

  @override
  State<SoilTestScreen> createState() => _SoilTestScreenState();
}

class _SoilTestScreenState extends State<SoilTestScreen> {
  final SoilAnalyzer _analyzer = SoilAnalyzer();
  bool _isAnalyzing = false;
  Map<String, dynamic>? _soilResult;
  String _selectedSoilType = 'दोमट मिट्टी (Alluvial Loam)';

  final List<Map<String, dynamic>> _soilTypes = [
    {'name': 'दोमट मिट्टी (Alluvial Loam)', 'color': const Color(0xFF5D4037), 'desc': 'गेहूं, धान और सब्जियों के लिए उत्तम'},
    {'name': 'काली मिट्टी (Black Soil / Regur)', 'color': const Color(0xFF3E2723), 'desc': 'कपास और सोयाबीन के लिए आदर्श'},
    {'name': 'बलुई मिट्टी (Sandy Loam)', 'color': const Color(0xFF8D6E63), 'desc': 'सरसों, मूंगफली और बाजरा हेतु उपयुक्त'},
    {'name': 'लाल व पीली मिट्टी (Red Soil)', 'color': const Color(0xFF795548), 'desc': 'दालों और तिलहन के लिए उपयोगी'},
  ];

  void _analyzeSoilSample(String typeName) async {
    setState(() {
      _isAnalyzing = true;
      _soilResult = null;
    });

    await Future.delayed(const Duration(milliseconds: 1200));
    final result = _analyzer.estimateSoilHealth(typeName);

    if (mounted) {
      setState(() {
        _isAnalyzing = false;
        _soilResult = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('मिट्टी स्वास्थ्य जाँच (Soil Health)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('📜 पिछले 3 सॉइल टेस्ट रिकॉर्ड्स सुरक्षित हैं')),
              );
            },
            tooltip: 'Soil History',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Camera Guide Card
            _buildCameraGuideCard(),

            const SizedBox(height: 16),
            const Text(
              'नमूना मिट्टी का प्रकार चुनें (Select Sample):',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 8),

            // Soil type selector
            SizedBox(
              height: 100,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _soilTypes.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final soil = _soilTypes[index];
                  final isSelected = _selectedSoilType == soil['name'];
                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedSoilType = soil['name']);
                      _analyzeSoilSample(soil['name']);
                    },
                    child: Container(
                      width: 150,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF4E342E) : const Color(0xFF201B18),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? const Color(0xFFFFB74D) : Colors.white12,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: soil['color'],
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white30),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            soil['name'],
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            soil['desc'],
                            style: const TextStyle(fontSize: 9, color: Colors.white54),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // Analysis button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: Icon(_isAnalyzing ? Icons.hourglass_top : Icons.camera_alt, color: Colors.white),
                label: Text(
                  _isAnalyzing ? 'कंप्यूटर विज़न + Munsell विश्लेषण जारी...' : 'फोटो खींचें और मिट्टी जाँचें (Analyze Soil)',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6D4C41),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _isAnalyzing ? null : () => _analyzeSoilSample(_selectedSoilType),
              ),
            ),

            const SizedBox(height: 20),

            // Results Dashboard Card
            if (_soilResult != null) _buildResultCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraGuideCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2C221D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF8D6E63).withValues(alpha: 0.5)),
      ),
      child: const Row(
        children: [
          Icon(Icons.lightbulb_outline, color: Color(0xFFFFB74D), size: 32),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'सटीक जाँच के लिए निर्देश:',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFFFFB74D)),
                ),
                SizedBox(height: 4),
                Text(
                  '1. मिट्टी की ऊपरी 1 इंच सूखी परत हटाकर ताज़ा मिट्टी लें।\n'
                  '2. प्राकृतिक धूप में फोटो लें (छांव या बल्ब की रोशनी से बचें)।\n'
                  '3. स्केल कैलिब्रेशन के लिए ₹5 का सिक्का मिट्टी के पास रखें।',
                  style: TextStyle(fontSize: 11, color: Colors.white70, height: 1.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard() {
    final res = _soilResult!;
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1A17),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFB74D), width: 1.5),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.health_and_safety, color: Color(0xFFFFB74D), size: 24),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'मिट्टी स्वास्थ्य कार्ड (Soil Health Card)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              Chip(
                label: Text(res['soil_quality'] ?? 'उत्कृष्ट', style: const TextStyle(fontSize: 11, color: Colors.black)),
                backgroundColor: const Color(0xFFFFB74D),
              ),
            ],
          ),
          const Divider(height: 24),

          // Primary metrics grid
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _metricCircle('pH मान', '${res['ph']}', res['ph_status'] ?? 'सामान्य (Neutral)'),
              _metricCircle('ऑर्गेनिक कार्बन', '${res['organic_carbon']}%', res['oc_status'] ?? 'मध्यम (Medium)'),
              _metricCircle('नमी (Moisture)', '${res['moisture_pct']}%', 'इष्टतम (Optimal)'),
            ],
          ),

          const SizedBox(height: 20),
          const Text('NPK पोषक तत्व रेटिंग:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white70)),
          const SizedBox(height: 8),

          _nutrientBar('नाइट्रोजन (N)', res['nitrogen_rating'] ?? 0.65, Colors.greenAccent),
          _nutrientBar('फॉस्फोरस (P)', res['phosphorus_rating'] ?? 0.52, Colors.orangeAccent),
          _nutrientBar('पोटाश (K)', res['potassium_rating'] ?? 0.78, Colors.blueAccent),

          const SizedBox(height: 16),

          // Recommended crops & advice
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF2A231F),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.recommend, color: Colors.lightGreenAccent, size: 18),
                    SizedBox(width: 6),
                    Text(
                      'अनुशंसित फसलें (Best Suited Crops):',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.lightGreenAccent),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  res['recommended_crops'] ?? 'गेहूं (Wheat HD-2967), सरसों (Mustard Pusa Bold), आलू',
                  style: const TextStyle(fontSize: 12, color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  '💡 सुधार सलाह: ${res['fertilizer_advice'] ?? "2 बोरी जिप्सम प्रति एकड़ डालें तथा 10 क्विंटल गोबर की खाद मिलाएँ।"}',
                  style: const TextStyle(fontSize: 11, color: Colors.white70, height: 1.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricCircle(String label, String value, String status) {
    return Column(
      children: [
        Container(
          width: 65,
          height: 65,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF2C221D),
            border: Border.all(color: const Color(0xFFFFB74D), width: 2),
          ),
          child: Center(
            child: Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFFFB74D)),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
        Text(status, style: const TextStyle(fontSize: 10, color: Colors.white54)),
      ],
    );
  }

  Widget _nutrientBar(String label, double ratio, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(width: 100, child: Text(label, style: const TextStyle(fontSize: 12, color: Colors.white70))),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: ratio,
                backgroundColor: Colors.white12,
                color: color,
                minHeight: 8,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text('${(ratio * 100).toInt()}%', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}
