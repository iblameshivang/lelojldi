import 'package:flutter/material.dart';
import '../../services/mesh_service.dart';

/// Mesh Network screen showing P2P connectivity and data sharing status.
class MeshScreen extends StatefulWidget {
  const MeshScreen({super.key});

  @override
  State<MeshScreen> createState() => _MeshScreenState();
}

class _MeshScreenState extends State<MeshScreen> with TickerProviderStateMixin {
  final MeshService _meshService = MeshService();
  bool _isMeshActive = false;
  late AnimationController _radarController;

  @override
  void initState() {
    super.initState();
    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
  }

  @override
  void dispose() {
    _radarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('📡 मेश नेटवर्क')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Radar visualization
            Container(
              width: double.infinity,
              height: 240,
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E30),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF9C27B0).withValues(alpha: 0.3)),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      width: _isMeshActive ? 120 : 80,
                      height: _isMeshActive ? 120 : 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF9C27B0).withValues(alpha: _isMeshActive ? 0.3 : 0.1),
                        border: Border.all(
                          color: _isMeshActive ? const Color(0xFF9C27B0) : Colors.grey,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        Icons.cell_tower,
                        size: 40,
                        color: _isMeshActive ? const Color(0xFFCE93D8) : Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _isMeshActive ? 'मेश नेटवर्क सक्रिय' : 'मेश नेटवर्क बंद',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _isMeshActive ? const Color(0xFFCE93D8) : Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _isMeshActive ? '${_meshService.connectedPeers.length} उपकरण जुड़े' : 'शुरू करने के लिए बटन दबाएं',
                      style: const TextStyle(color: Colors.white60, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Toggle button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _toggleMesh,
                icon: Icon(_isMeshActive ? Icons.stop : Icons.play_arrow),
                label: Text(_isMeshActive ? 'बंद करें' : 'मेश शुरू करें'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isMeshActive ? Colors.red.shade700 : const Color(0xFF9C27B0),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Stats grid
            Row(
              children: [
                _statCard('📨', 'भेजे', '0', const Color(0xFF42A5F5)),
                const SizedBox(width: 12),
                _statCard('📩', 'प्राप्त', '0', const Color(0xFF66BB6A)),
                const SizedBox(width: 12),
                _statCard('📱', 'जुड़े', '0', const Color(0xFFFFA726)),
              ],
            ),
            const SizedBox(height: 20),

            // Features list
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('विशेषताएं', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 8),
            _featureTile(Icons.share, 'रोग डेटा साझा', 'निदान स्वचालित रूप से पास के किसानों को भेजें'),
            _featureTile(Icons.warning_amber, 'मौसम चेतावनी', 'आपातकालीन मौसम अलर्ट प्रसारित करें'),
            _featureTile(Icons.store, 'मंडी भाव', 'बाज़ार के दाम बिना इंटरनेट साझा करें'),
            _featureTile(Icons.bluetooth, 'BLE + Wi-Fi', 'ब्लूटूथ + वाई-फाई डायरेक्ट'),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String emoji, String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            Text(label, style: const TextStyle(fontSize: 11, color: Colors.white60)),
          ],
        ),
      ),
    );
  }

  Widget _featureTile(IconData icon, String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E30),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF9C27B0), size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.white60)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _toggleMesh() async {
    if (_isMeshActive) {
      await _meshService.stop();
      _radarController.stop();
    } else {
      await _meshService.startAdvertising('KrishiNode');
      await _meshService.startDiscovery();
      _radarController.repeat();
    }
    setState(() => _isMeshActive = !_isMeshActive);
  }
}
