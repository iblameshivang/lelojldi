import 'package:flutter/material.dart';
import '../../services/dosage_calculator.dart';

/// AR Spot-Spraying screen (Feature 10).
/// Computes diseased leaf boundary area and exact micro-dosage to avoid chemical overuse.
class ArSprayScreen extends StatefulWidget {
  const ArSprayScreen({super.key});

  @override
  State<ArSprayScreen> createState() => _ArSprayScreenState();
}

class _ArSprayScreenState extends State<ArSprayScreen> with SingleTickerProviderStateMixin {
  final DosageCalculator _calculator = DosageCalculator();
  String _selectedCrop = 'गेहूं (Wheat)';
  String _selectedChemical = 'Propiconazole 25% EC';
  double _affectedAreaSqm = 14.5;
  bool _isArCalibrated = true;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dosage = _calculator.calculateDosage(
      crop: _selectedCrop,
      chemical: _selectedChemical,
      areaSqm: _affectedAreaSqm,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('AR स्पॉट छिड़काव (AR Spraying)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        actions: [
          IconButton(
            icon: Icon(_isArCalibrated ? Icons.sensors : Icons.sensors_off, color: _isArCalibrated ? Colors.greenAccent : Colors.orange),
            onPressed: () {
              setState(() => _isArCalibrated = !_isArCalibrated);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(_isArCalibrated ? 'AR सेंसर कैलिब्रेटेड है' : 'सेंसर री-कैलिब्रेशन मोड')),
              );
            },
            tooltip: 'AR Sensor Status',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // AR Viewport with HUD overlay
            _buildArViewport(),

            // Crop & Chemical selection
            _buildControls(),

            // Precise Dosage Calculation Card
            _buildDosageCard(dosage),

            // Savings & Eco-Impact Card
            _buildSavingsCard(),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildArViewport() {
    return Container(
      margin: const EdgeInsets.all(16),
      height: 280,
      decoration: BoxDecoration(
        color: const Color(0xFF0F141C),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF00BCD4), width: 1.5),
      ),
      child: Stack(
        children: [
          // Simulated Camera leaf background with crop field visual
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Container(
              color: const Color(0xFF132014),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.eco, size: 70, color: Colors.green.withValues(alpha: 0.35)),
                    const SizedBox(height: 8),
                    Text(
                      'पौधे पर कैमरा फोकस करें',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // AR Detected Infection Polygon Bounding Box
          Positioned(
            top: 50,
            left: 50,
            right: 50,
            bottom: 60,
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.12 + 0.08 * _pulseController.value),
                    border: Border.all(
                      color: Colors.redAccent.withValues(alpha: 0.7 + 0.3 * _pulseController.value),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Stack(
                    children: [
                      // AR Zone Tag
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red.shade900.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.warning_amber, color: Colors.yellowAccent, size: 14),
                              SizedBox(width: 4),
                              Text(
                                'रोग क्षेत्र (Spot 1): पीला रतुआ',
                                style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // AR Area measurement label
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.75),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'प्रभावित क्षेत्रफल: ${_affectedAreaSqm.toStringAsFixed(1)} m²',
                            style: const TextStyle(fontSize: 11, color: Colors.cyanAccent, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // HUD status badge
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF00BCD4)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.gps_fixed, size: 12, color: Colors.cyanAccent),
                  SizedBox(width: 4),
                  Text('AR ट्रैकिंग सक्रिय (60 FPS)', style: TextStyle(fontSize: 10, color: Colors.white70)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        color: const Color(0xFF1B1B2A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'फसल व कीटनाशक चयन:',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedCrop,
                      decoration: InputDecoration(
                        labelText: 'फसल (Crop)',
                        filled: true,
                        fillColor: const Color(0xFF242438),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      ),
                      items: ['गेहूं (Wheat)', 'धान (Paddy)', 'सरसों (Mustard)', 'आलू (Potato)'].map((c) {
                        return DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 13)));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedCrop = val);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedChemical,
                      decoration: InputDecoration(
                        labelText: 'दवा (Chemical)',
                        filled: true,
                        fillColor: const Color(0xFF242438),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      ),
                      items: [
                        'Propiconazole 25% EC',
                        'Mancozeb 75% WP',
                        'Cymoxanil + Mancozeb',
                        'Chlorpyrifos 20% EC',
                      ].map((c) {
                        return DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 12)));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedChemical = val);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Area slider
              Row(
                children: [
                  const Text('स्पॉट आकार:', style: TextStyle(fontSize: 12, color: Colors.white70)),
                  Expanded(
                    child: Slider(
                      value: _affectedAreaSqm,
                      min: 1.0,
                      max: 100.0,
                      divisions: 99,
                      activeColor: const Color(0xFF00BCD4),
                      onChanged: (val) => setState(() => _affectedAreaSqm = val),
                    ),
                  ),
                  Text('${_affectedAreaSqm.toStringAsFixed(1)} m²', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.cyanAccent)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDosageCard(Map<String, dynamic> dosage) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF006064).withValues(alpha: 0.6), const Color(0xFF004D40).withValues(alpha: 0.4)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF00BCD4).withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.calculate, color: Colors.cyanAccent, size: 22),
              SizedBox(width: 8),
              Text(
                'सटीक माइक्रोडोज़ (Precise Spot Dosage)',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _metricBox('दवा की मात्रा', '${(dosage['chemical_ml'] as double).toStringAsFixed(1)} ml', 'Chemical'),
              _metricBox('पानी की मात्रा', '${(dosage['water_liters'] as double).toStringAsFixed(1)} L', 'Water'),
              _metricBox('नोज़ल स्प्रे दबाव', '2.5 bar', 'Pressure'),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.black38,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(Icons.shield_outlined, color: Colors.orangeAccent, size: 16),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'सुरक्षा निर्देश: हवा की गति 10 किमी/घंटा से कम होने पर ही स्प्रे करें। चेहरे पर मास्क पहनें।',
                    style: TextStyle(fontSize: 11, color: Colors.white70),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricBox(String label, String value, String sub) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.cyanAccent)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.white)),
        Text(sub, style: const TextStyle(fontSize: 10, color: Colors.white38)),
      ],
    );
  }

  Widget _buildSavingsCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1B2E1D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF4CAF50).withValues(alpha: 0.5)),
      ),
      child: const Row(
        children: [
          Icon(Icons.savings, color: Colors.lightGreenAccent, size: 36),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '82% कीटनाशक बचत (Chemical Saved)!',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.lightGreenAccent),
                ),
                SizedBox(height: 4),
                Text(
                  'पूरे खेत में छिड़कने की बजाय केवल प्रभावित पौधे पर छिड़काव से ₹1,800/एकड़ की बचत और ज़मीन का स्वास्थ्य सुरक्षित।',
                  style: TextStyle(fontSize: 11, color: Colors.white70, height: 1.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
