import 'package:flutter/material.dart';
import '../../services/llm_service.dart';

/// Settings & System Configuration screen with AI Key & LLM management.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _language = 'hi';
  bool _offlineOnly = false;
  bool _meshRelay = true;
  bool _voiceFeedback = true;
  bool _biometricLock = true;

  final TextEditingController _apiKeyController = TextEditingController();
  final LLMService _llmService = LLMService();
  String _aiStatus = 'जांच हो रही है...';
  bool _isKeyConfigured = false;
  bool _isTestingKey = false;

  @override
  void initState() {
    super.initState();
    _checkApiKeyStatus();
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  Future<void> _checkApiKeyStatus() async {
    final status = await _llmService.checkKeyStatus();
    setState(() {
      _isKeyConfigured = status['configured'] == true;
      _aiStatus = _isKeyConfigured
          ? 'सक्रिय (Active): ${status['active_model'] ?? 'gemini-1.5-flash'}'
          : 'ऑफ़लाइन ICAR नॉलेज बेस सक्रिय';
    });
  }

  Future<void> _saveAndTestApiKey() async {
    final key = _apiKeyController.text.trim();
    if (key.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('कृपया एक वैध Google Gemini API Key दर्ज करें')),
      );
      return;
    }

    setState(() => _isTestingKey = true);
    _llmService.setCustomApiKey(key);

    try {
      final reply = await _llmService.answerQuestion('नमस्ते, क्या आप तैयार हैं?', 'hi');
      setState(() {
        _isTestingKey = false;
        _isKeyConfigured = true;
        _aiStatus = 'सफलतापूर्वक कनेक्टेड (Connected to Gemini AI)';
      });
      _apiKeyController.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF2E7D32),
            content: Text('✅ AI कुंजी सक्रिय हो गई!\nउत्तर: ${reply.substring(0, reply.length > 50 ? 50 : reply.length)}...'),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isTestingKey = false;
        _aiStatus = 'कनेक्शन त्रुटि - ऑफ़लाइन मोड उपयोग करें';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        title: const Text('सेटिंग्स (Settings)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: const Color(0xFF1A1A2E),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ─── AI & LLM Engine Section ───
          _sectionHeader('कृषि AI व LLM इंजन (Google Gemini Key)'),
          Card(
            color: const Color(0xFF1B1B2A),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: const Color(0xFF4CAF50).withValues(alpha: 0.3))),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.smart_toy, color: Color(0xFF4CAF50)),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Google Gemini AI एकीकरण',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white),
                        ),
                      ),
                      Chip(
                        label: Text(
                          _isKeyConfigured ? 'Live AI' : 'Offline RAG',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: _isKeyConfigured ? Colors.greenAccent : Colors.orangeAccent,
                          ),
                        ),
                        backgroundColor: (_isKeyConfigured ? Colors.green : Colors.orange).withValues(alpha: 0.15),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'वर्तमान स्थिति: $_aiStatus',
                    style: const TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _apiKeyController,
                    obscureText: true,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Google Gemini API Key दर्ज करें...',
                      hintStyle: const TextStyle(color: Colors.white38, fontSize: 12),
                      filled: true,
                      fillColor: const Color(0xFF252538),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.info_outline, size: 18, color: Colors.white38),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Gemini API Key aistudio.google.com से निःशुल्क प्राप्त की जा सकती है।')),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: _isTestingKey ? null : _saveAndTestApiKey,
                      icon: _isTestingKey
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.key, size: 16, color: Colors.white),
                      label: Text(
                        _isTestingKey ? 'जांच हो रही है...' : 'कुंजी सहेजें व AI टेस्ट करें (Save & Test)',
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),
          // Language section
          _sectionHeader('भाषा और आवाज़ (Language & Voice)'),
          Card(
            color: const Color(0xFF1B1B2A),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.language, color: Colors.greenAccent),
                  title: const Text('मुख्य भाषा (App Language)', style: TextStyle(color: Colors.white, fontSize: 14)),
                  subtitle: Text(_language == 'hi' ? 'हिंदी (Hindi)' : 'English', style: const TextStyle(color: Colors.white60, fontSize: 12)),
                  trailing: DropdownButton<String>(
                    value: _language,
                    dropdownColor: const Color(0xFF252538),
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(value: 'hi', child: Text('हिंदी', style: TextStyle(color: Colors.white))),
                      DropdownMenuItem(value: 'en', child: Text('English', style: TextStyle(color: Colors.white))),
                      DropdownMenuItem(value: 'hinglish', child: Text('Hinglish', style: TextStyle(color: Colors.white))),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _language = val);
                    },
                  ),
                ),
                SwitchListTile(
                  secondary: const Icon(Icons.record_voice_over, color: Colors.blueAccent),
                  title: const Text('वॉइस आउटपुट (Voice TTS)', style: TextStyle(color: Colors.white, fontSize: 14)),
                  subtitle: const Text('परिणाम और सलाह बोलकर सुनाएं', style: TextStyle(color: Colors.white60, fontSize: 12)),
                  value: _voiceFeedback,
                  activeThumbColor: const Color(0xFF4CAF50),
                  onChanged: (val) => setState(() => _voiceFeedback = val),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
          _sectionHeader('ऑफ़लाइन व मेश नेटवर्क (Offline & Mesh)'),
          Card(
            color: const Color(0xFF1B1B2A),
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.wifi_off, color: Colors.orangeAccent),
                  title: const Text('पूर्ण ऑफ़लाइन मोड (Strict Offline)', style: TextStyle(color: Colors.white, fontSize: 14)),
                  subtitle: const Text('केवल स्थानीय TFLite व ऑन-डिवाइस RAG चलाएँ', style: TextStyle(color: Colors.white60, fontSize: 12)),
                  value: _offlineOnly,
                  activeThumbColor: const Color(0xFF4CAF50),
                  onChanged: (val) => setState(() => _offlineOnly = val),
                ),
                SwitchListTile(
                  secondary: const Icon(Icons.cell_tower, color: Colors.purpleAccent),
                  title: const Text('P2P मेश रिलेयर (Mesh Relay)', style: TextStyle(color: Colors.white, fontSize: 14)),
                  subtitle: const Text('पड़ोसी किसानों के पैकेट्स को आगे बढ़ाएँ', style: TextStyle(color: Colors.white60, fontSize: 12)),
                  value: _meshRelay,
                  activeThumbColor: const Color(0xFF4CAF50),
                  onChanged: (val) => setState(() => _meshRelay = val),
                ),
                ListTile(
                  leading: const Icon(Icons.perm_device_info, color: Colors.cyanAccent),
                  title: const Text('नोड आईडी (Device Node ID)', style: TextStyle(color: Colors.white, fontSize: 14)),
                  subtitle: const Text('KS-MESH-LKO-88219 (Aadhaar Linked)', style: TextStyle(color: Colors.white60, fontSize: 12)),
                  trailing: const Icon(Icons.copy, size: 18, color: Colors.white60),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('📋 नोड आईडी कॉपी हो गई')),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
          _sectionHeader('डेटा सुरक्षा व स्टोर अनुपालन (App Store Compliance)'),
          Card(
            color: const Color(0xFF1B1B2A),
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.fingerprint, color: Colors.tealAccent),
                  title: const Text('बायोमेट्रिक / स्क्रीन लॉक', style: TextStyle(color: Colors.white, fontSize: 14)),
                  subtitle: const Text('ऐप खोलने पर फिंगरप्रिंट आवश्यक', style: TextStyle(color: Colors.white60, fontSize: 12)),
                  value: _biometricLock,
                  activeThumbColor: const Color(0xFF4CAF50),
                  onChanged: (val) => setState(() => _biometricLock = val),
                ),
                const ListTile(
                  leading: Icon(Icons.verified_user, color: Colors.amberAccent),
                  title: Text('स्थानीय डेटाबेस एन्क्रिप्शन', style: TextStyle(color: Colors.white, fontSize: 14)),
                  subtitle: Text('SQLCipher 256-bit AES एन्क्रिप्टेड', style: TextStyle(color: Colors.white60, fontSize: 12)),
                  trailing: Chip(
                    label: Text('सक्रिय (Active)', style: TextStyle(fontSize: 10, color: Colors.greenAccent)),
                    backgroundColor: Colors.transparent,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
          _sectionHeader('सिस्टम जानकारी (About Krishi-Saarthi)'),
          const Card(
            color: Color(0xFF1B1B2A),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'कृषि-सारथी 🌱 v1.0.0 (SIH 2026 Production Build)',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'स्मार्ट इंडिया हैकथॉन (SIH 2026) के लिए विकसित 13-सुविधाओं से युक्त पूर्ण ऑफ़लाइन कृषि ऑपरेटिंग सिस्टम। Google Play Store एवं Apple App Store के लिए प्रमाणित।',
                    style: TextStyle(fontSize: 12, color: Colors.white70, height: 1.3),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'पैकेज ID: com.krishisaarthi.app\nलक्षित OS: iOS 14+, Android 14 (SDK 34), Web PWA',
                    style: TextStyle(fontSize: 11, color: Colors.white38),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white60),
      ),
    );
  }
}
