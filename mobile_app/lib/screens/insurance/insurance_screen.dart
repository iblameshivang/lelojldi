import 'package:flutter/material.dart';
import '../../services/insurance_recorder.dart';

/// Insurance Evidence Locker Screen (Feature 12).
/// Tamper-proof video recording with hardware metadata injection & blockchain anchor.
class InsuranceScreen extends StatefulWidget {
  const InsuranceScreen({super.key});

  @override
  State<InsuranceScreen> createState() => _InsuranceScreenState();
}

class _InsuranceScreenState extends State<InsuranceScreen> with SingleTickerProviderStateMixin {
  final InsuranceRecorder _recorder = InsuranceRecorder();
  bool _isRecording = false;
  int _recordSeconds = 0;
  Map<String, dynamic>? _lastClaim;
  late AnimationController _blinkController;

  final List<Map<String, dynamic>> _claimsHistory = [
    {
      'policy_number': 'PMFBY-UP-2026-981245',
      'claim_type': 'ओलावृष्टि (Hailstorm Damage)',
      'status': 'स्वीकृत (Approved)',
      'amount': '₹42,500',
      'date': '02 मार्च 2026',
      'tx_id': '0x7f9a8b1c2d3e4f5a6b7c8d9e0f1a2b3c4d5e6f7a',
      'status_color': Colors.greenAccent,
    },
    {
      'policy_number': 'PMFBY-UP-2025-441209',
      'claim_type': 'कीट प्रकोप (Pest Attack)',
      'status': 'निपटारा पूर्ण (Settled)',
      'amount': '₹28,000',
      'date': '14 नवंबर 2025',
      'tx_id': '0x3c2a1b9e8d7f6a5b4c3d2e1f0a9b8c7d6e5f4a3b',
      'status_color': Colors.blueAccent,
    },
  ];

  @override
  void initState() {
    super.initState();
    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _blinkController.dispose();
    super.dispose();
  }

  void _toggleRecording() async {
    if (_isRecording) {
      // Stop recording and generate evidence package
      setState(() => _isRecording = false);
      final evidence = _recorder.finalizeEvidence(seconds: _recordSeconds);

      setState(() {
        _lastClaim = evidence;
        _claimsHistory.insert(0, {
          'policy_number': 'PMFBY-UP-2026-NEW-${DateTime.now().millisecond}',
          'claim_type': 'ओलावृष्टि / बेमौसम वर्षा (Damage Claim)',
          'status': 'सत्यापित और सुरक्षित (Secured)',
          'amount': '₹35,000 (प्रस्तावित)',
          'date': 'आज (Today)',
          'tx_id': evidence['blockchain_tx_id'] ?? '0x88e7...b901',
          'status_color': Colors.amberAccent,
        });
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ वीडियो रिकॉर्डिंग व मेटाडेटा ब्लॉकचेन पर सुरक्षित हो गया!'),
          backgroundColor: Color(0xFF2E7D32),
        ),
      );
    } else {
      // Start recording
      setState(() {
        _isRecording = true;
        _recordSeconds = 0;
      });

      // Increment recording timer
      for (int i = 0; i < 6; i++) {
        if (!mounted || !_isRecording) break;
        await Future.delayed(const Duration(seconds: 1));
        if (mounted && _isRecording) {
          setState(() => _recordSeconds++);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('बीमा लॉकर (Insurance Locker)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        actions: [
          IconButton(
            icon: const Icon(Icons.security),
            onPressed: () => _showSecurityDialog(),
            tooltip: 'Security Specs',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Evidence Viewfinder / Recorder
            _buildRecorderView(),

            const SizedBox(height: 16),

            // Blockchain Proof Badge (if recorded)
            if (_lastClaim != null) _buildBlockchainCard(),

            const SizedBox(height: 16),
            const Text(
              'बीमा दावा इतिहास (Claims & Evidence History):',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 10),

            // Claims list
            ..._claimsHistory.map((c) => _buildClaimTile(c)),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildRecorderView() {
    return Container(
      height: 240,
      decoration: BoxDecoration(
        color: const Color(0xFF141923),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _isRecording ? Colors.redAccent : const Color(0xFF607D8B),
          width: 2,
        ),
      ),
      child: Stack(
        children: [
          // Background simulation
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.videocam,
                  size: 60,
                  color: _isRecording ? Colors.redAccent.withValues(alpha: 0.5) : Colors.white24,
                ),
                const SizedBox(height: 8),
                Text(
                  _isRecording ? 'टैम्पर-प्रूफ वीडियो रिकॉर्ड हो रहा है...' : 'खेत में नुकसान का वीडियो प्रमाण रिकॉर्ड करें',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12),
                ),
              ],
            ),
          ),

          // Live Watermark HUD (GPS, Sensors, UTC)
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('📍 GPS: 26.8467° N, 80.9462° E (±1.8m)', style: TextStyle(fontSize: 10, color: Colors.greenAccent)),
                  const Text('🧭 Gyro: X:0.02 Y:0.98 Z:0.12', style: TextStyle(fontSize: 10, color: Colors.cyanAccent)),
                  Text('⏱️ UTC: ${DateTime.now().toUtc().toIso8601String().substring(0, 19)}Z', style: const TextStyle(fontSize: 10, color: Colors.white70)),
                ],
              ),
            ),
          ),

          // Recording status badge
          if (_isRecording)
            Positioned(
              top: 12,
              right: 12,
              child: AnimatedBuilder(
                animation: _blinkController,
                builder: (context, child) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.7 * _blinkController.value + 0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.circle, size: 10, color: Colors.white),
                        const SizedBox(width: 6),
                        Text('REC 00:0$_recordSeconds', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                      ],
                    ),
                  );
                },
              ),
            ),

          // Bottom Action Button
          Positioned(
            bottom: 16,
            left: 20,
            right: 20,
            child: ElevatedButton.icon(
              icon: Icon(_isRecording ? Icons.stop : Icons.fiber_manual_record, color: Colors.white),
              label: Text(
                _isRecording ? 'रिकॉर्डिंग रोकें व ब्लॉकचेन पर सुरक्षित करें' : 'नया सबूत वीडियो बनाएं (Record Evidence)',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isRecording ? Colors.red.shade800 : const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _toggleRecording,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlockchainCard() {
    final claim = _lastClaim!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2638),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.purpleAccent.withValues(alpha: 0.6), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.link, color: Colors.purpleAccent, size: 22),
              SizedBox(width: 8),
              Text(
                'पॉलीगॉन ब्लॉकचेन एंकर (Polygon Hash Anchored)',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Tx Hash: ${claim['blockchain_tx_id']}',
            style: const TextStyle(fontSize: 11, fontFamily: 'monospace', color: Colors.purpleAccent),
          ),
          const SizedBox(height: 6),
          Text(
            'वीडियो हैश: ${claim['video_hash']}',
            style: const TextStyle(fontSize: 11, fontFamily: 'monospace', color: Colors.white70),
          ),
          const SizedBox(height: 8),
          const Text(
            '🛡️ यह वीडियो और इसके सभी सेंसर डेटा को बदला नहीं जा सकता (Tamper-Proof)। बीमा कंपनी इसे अस्वीकार नहीं कर सकती।',
            style: TextStyle(fontSize: 11, color: Colors.white60, height: 1.3),
          ),
        ],
      ),
    );
  }

  Widget _buildClaimTile(Map<String, dynamic> claim) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      color: const Color(0xFF1B1F2A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    claim['claim_type'],
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: (claim['status_color'] as Color).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: claim['status_color'], width: 1),
                  ),
                  child: Text(
                    claim['status'],
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: claim['status_color']),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('पॉलिसी: ${claim['policy_number']}', style: const TextStyle(fontSize: 11, color: Colors.white54)),
                Text('दावा: ${claim['amount']}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.greenAccent)),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('तारीख: ${claim['date']}', style: const TextStyle(fontSize: 10, color: Colors.white38)),
                Row(
                  children: [
                    const Icon(Icons.verified, size: 12, color: Colors.purpleAccent),
                    const SizedBox(width: 4),
                    Text(
                      '${claim['tx_id'].toString().substring(0, 16)}...',
                      style: const TextStyle(fontSize: 10, color: Colors.purpleAccent, fontFamily: 'monospace'),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showSecurityDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('टैम्पर-प्रूफ बीमा लॉकर'),
        content: const Text(
          '1. वीडियो के प्रत्येक फ्रेम में GPS, गायरोस्कोप व समय का डेटा एम्बेड होता है।\n\n'
          '2. प्रत्येक फ्रेम का SHA-256 हैश निकालकर एक मर्कल चेन बनती है।\n\n'
          '3. वीडियो के अंत में निजी कुंजी (ECDSA) द्वारा डिजिटल हस्ताक्षर किया जाता है।\n\n'
          '4. हैश को सार्वजनिक ब्लॉकचेन (Polygon) पर डाला जाता है जिससे कोई वीडियो से छेड़छाड़ न कर सके।',
          style: TextStyle(fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('ठीक है')),
        ],
      ),
    );
  }
}
