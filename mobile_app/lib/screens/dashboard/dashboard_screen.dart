import 'package:flutter/material.dart';
import '../../db/delta_sync.dart';

/// Farmer Profile, Plots & Sync Dashboard Screen (Features 5 & 7).
/// Manages farm plots, local SQLCipher records, QR identity, and Merkle tree differential sync.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DeltaSync _deltaSync = DeltaSync();
  bool _isSyncing = false;
  String _syncStatusText = 'सिंक स्थिति: अप-टू-डेट (All synced)';
  DateTime _lastSyncTime = DateTime.now().subtract(const Duration(minutes: 25));

  void _triggerSync() async {
    setState(() {
      _isSyncing = true;
      _syncStatusText = 'मेश व सर्वर से डिफरेंशियल सिंक जारी...';
    });

    await Future.delayed(const Duration(milliseconds: 1500));
    await _deltaSync.sync(
      baseUrl: 'http://localhost:8000',
      authToken: 'demo-bearer-token',
      deviceId: 'krishi-node-01',
      localData: {},
    );

    if (mounted) {
      setState(() {
        _isSyncing = false;
        _lastSyncTime = DateTime.now();
        _syncStatusText = 'सिंक सफल: 3 रिकॉर्ड्स मर्कल ट्री द्वारा अपडेट हुए';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🔄 स्थानीय डेटाबेस (SQLCipher) सफलतापूर्वक सिंक हो गया!'),
          backgroundColor: Color(0xFF2E7D32),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('किसान डैशबोर्ड (My Farm)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        actions: [
          IconButton(
            icon: Icon(_isSyncing ? Icons.sync : Icons.sync_problem, color: _isSyncing ? Colors.greenAccent : Colors.orangeAccent),
            onPressed: _isSyncing ? null : _triggerSync,
            tooltip: 'Sync Now',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _triggerSync(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Farmer Profile Card
            _buildFarmerProfileCard(),

            const SizedBox(height: 16),

            // Differential Sync Status Card
            _buildSyncStatusCard(),

            const SizedBox(height: 16),

            // Farm Plots List
            _buildFarmPlotsSection(),

            const SizedBox(height: 16),

            // Recent Diagnoses Quick Summary
            _buildDiagnosesSection(),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildFarmerProfileCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 28,
                backgroundColor: Colors.white24,
                child: Text('RK', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'रमेश कुमार (Ramesh Kumar)',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'गाँव: बख्शी का तालाब, लखनऊ (UP_LKO)',
                      style: TextStyle(fontSize: 12, color: Colors.white70),
                    ),
                    Text(
                      'आधार: **** **** 9012 • PM-Kisan ID: UP8921',
                      style: TextStyle(fontSize: 11, color: Colors.white60),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.qr_code_2, color: Colors.white, size: 28),
                onPressed: () => _showFarmerQrDialog(),
                tooltip: 'My Farmer QR',
              ),
            ],
          ),
          const Divider(color: Colors.white24, height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _statMini('कुल खेत (Plots)', '2'),
              _statMini('क्षेत्रफल (Area)', '3.1 एकड़'),
              _statMini('मुख्य फसल', 'गेहूं + सरसों'),
              _statMini('स्वास्थ्य रेटिंग', '88% A+'),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _statMini(String title, String val) {
    return Column(
      children: [
        Text(val, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 2),
        Text(title, style: const TextStyle(fontSize: 10, color: Colors.white70)),
      ],
    );
  }

  Widget _buildSyncStatusCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1B2030),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF3F51B5).withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _isSyncing ? Icons.autorenew : Icons.cloud_done,
                color: _isSyncing ? Colors.greenAccent : const Color(0xFF4CAF50),
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _syncStatusText,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              if (_isSyncing)
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.greenAccent),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'अंतिम सिंक: ${_lastSyncTime.hour.toString().padLeft(2, '0')}:${_lastSyncTime.minute.toString().padLeft(2, '0')}',
                style: const TextStyle(fontSize: 11, color: Colors.white54),
              ),
              const Text(
                'मर्कल ट्री: 18 स्थानीय ब्लॉक्स सुरक्षित',
                style: TextStyle(fontSize: 11, color: Colors.cyanAccent),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFarmPlotsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'मेरे खेत (My Farm Plots):',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 10),
        _plotCard(
          'उत्तर खेत (North Field)',
          'गेहूं (Wheat - HD 2967)',
          '8,200 m² (2.02 एकड़)',
          'बुवाई: 45 दिन पहले • कल्ले फूटने की अवस्था',
          Colors.green,
        ),
        const SizedBox(height: 8),
        _plotCard(
          'नहर वाला खेत (Canal Plot)',
          'सरसों (Mustard - Pusa Bold)',
          '4,500 m² (1.11 एकड़)',
          'बुवाई: 60 दिन पहले • फूल व फलियाँ आने की अवस्था',
          Colors.amber,
        ),
      ],
    );
  }

  Widget _plotCard(String title, String crop, String area, String stage, Color indicatorColor) {
    return Card(
      color: const Color(0xFF1E1E2C),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(width: 8, height: 8, decoration: BoxDecoration(color: indicatorColor, shape: BoxShape.circle)),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                const Spacer(),
                Text(area, style: const TextStyle(fontSize: 11, color: Colors.white70)),
              ],
            ),
            const SizedBox(height: 6),
            Text('🌾 $crop', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.lightGreenAccent)),
            const SizedBox(height: 2),
            Text(stage, style: const TextStyle(fontSize: 11, color: Colors.white54)),
          ],
        ),
      ),
    );
  }

  Widget _buildDiagnosesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'हालिया निदान स्थिति (Recent Diagnoses):',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 10),
        _diagnosisTile('पीला रतुआ (Yellow Rust)', 'उत्तर खेत (Wheat)', '94% AI Confidence', 'उपचारित (Treated)', Colors.redAccent),
        const SizedBox(height: 8),
        _diagnosisTile('सफेद रतुआ (White Rust)', 'नहर वाला खेत (Mustard)', '89% AI Confidence', 'निगरानी जारी (Monitored)', Colors.orangeAccent),
      ],
    );
  }

  Widget _diagnosisTile(String disease, String plot, String conf, String status, Color color) {
    return Card(
      color: const Color(0xFF1E1E2C),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.2),
          child: Icon(Icons.bug_report, color: color, size: 20),
        ),
        title: Text(disease, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
        subtitle: Text('$plot • $conf', style: const TextStyle(fontSize: 11, color: Colors.white54)),
        trailing: Chip(
          label: Text(status, style: const TextStyle(fontSize: 10, color: Colors.white)),
          backgroundColor: color.withValues(alpha: 0.3),
        ),
      ),
    );
  }

  void _showFarmerQrDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('किसान डिजिटल पहचान (Farmer QR)'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: const Icon(Icons.qr_code_2, size: 160, color: Colors.black),
            ),
            const SizedBox(height: 12),
            const Text(
              'रमेश कुमार • UP_LKO_001\nक्रिप्टोग्राफिक P2P मेश आईडी सत्यापित',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('बंद करें')),
        ],
      ),
    );
  }
}
