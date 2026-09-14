import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'dart:math';

/// Interactive 2G Rural Telecom Simulator (USSD & SMS Gateway)
/// Allows farmers and testing officers to dial *123# and send SMS queries.
class UssdSmsScreen extends StatefulWidget {
  const UssdSmsScreen({super.key});

  @override
  State<UssdSmsScreen> createState() => _UssdSmsScreenState();
}

class _UssdSmsScreenState extends State<UssdSmsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Dio _dio = Dio(BaseOptions(baseUrl: 'http://localhost:8000/api/v1/telecom'));

  // USSD State
  String _dialedNumber = '*123#';
  bool _isInUssdSession = false;
  String _ussdSessionId = '';
  String _currentUssdScreenText = '';
  final TextEditingController _ussdInputController = TextEditingController();
  bool _isUssdLoading = false;

  // SMS State
  final TextEditingController _smsRecipientController = TextEditingController(text: '56161');
  final TextEditingController _smsBodyController = TextEditingController(text: 'CROP WHEAT RUST');
  final List<Map<String, dynamic>> _smsChatHistory = [];
  bool _isSmsSending = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _ussdInputController.dispose();
    _smsRecipientController.dispose();
    _smsBodyController.dispose();
    super.dispose();
  }

  void _onKeyPress(String key) {
    if (_isInUssdSession) return;
    setState(() {
      _dialedNumber += key;
    });
  }

  void _onBackspace() {
    if (_isInUssdSession || _dialedNumber.isEmpty) return;
    setState(() {
      _dialedNumber = _dialedNumber.substring(0, _dialedNumber.length - 1);
    });
  }

  Future<void> _startUssdSession() async {
    if (_dialedNumber.isEmpty) return;
    setState(() {
      _isUssdLoading = true;
      _ussdSessionId = 'sess-${Random().nextInt(999999)}';
    });

    try {
      final response = await _dio.post('/ussd/session', data: {
        'session_id': _ussdSessionId,
        'msisdn': '9876543210',
        'user_input': _dialedNumber,
        'service_code': '*123#',
      });

      if (response.statusCode == 200) {
        final data = response.data;
        setState(() {
          _isInUssdSession = true;
          _currentUssdScreenText = data['response']?.toString().replaceFirst('CON ', '').replaceFirst('END ', '') ?? '';
          _isUssdLoading = false;
        });

        if (data['action'] == 'END') {
          _showUssdEndDialog(_currentUssdScreenText);
        }
      }
    } catch (e) {
      setState(() {
        _isUssdLoading = false;
        _isInUssdSession = true;
        _currentUssdScreenText = '🌱 कृषि-सारथी टेलीकॉम सेवा (*123#)\n1. फसल रोग व उपचार\n2. लाइव मंडी भाव\n3. मौसम अलर्ट\n4. खाद QR जांच';
      });
    }
  }

  Future<void> _sendUssdResponse() async {
    final input = _ussdInputController.text.trim();
    if (input.isEmpty) return;
    _ussdInputController.clear();

    setState(() {
      _isUssdLoading = true;
    });

    try {
      final response = await _dio.post('/ussd/session', data: {
        'session_id': _ussdSessionId,
        'msisdn': '9876543210',
        'user_input': input,
        'service_code': '*123#',
      });

      if (response.statusCode == 200) {
        final data = response.data;
        final isEnd = data['action'] == 'END';
        final text = data['response']?.toString().replaceFirst('CON ', '').replaceFirst('END ', '') ?? '';

        setState(() {
          _currentUssdScreenText = text;
          _isUssdLoading = false;
        });

        if (isEnd) {
          _showUssdEndDialog(text);
        }
      }
    } catch (_) {
      setState(() {
        _isUssdLoading = false;
        _currentUssdScreenText = 'सेवा समाप्त। पुनः *123# डायल करें।';
      });
      _showUssdEndDialog(_currentUssdScreenText);
    }
  }

  void _showUssdEndDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E30),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.cell_tower, color: Color(0xFF4CAF50)),
            SizedBox(width: 8),
            Text('टेलीकॉम USSD संदेश', style: TextStyle(color: Colors.white, fontSize: 16)),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(color: Colors.white, height: 1.4, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _isInUssdSession = false;
                _currentUssdScreenText = '';
              });
            },
            child: const Text('ठीक है (OK)', style: TextStyle(color: Color(0xFF4CAF50), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _sendSms() async {
    final text = _smsBodyController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _isSmsSending = true;
      _smsChatHistory.add({
        'isUser': true,
        'text': text,
        'time': 'अभी',
      });
    });
    _smsBodyController.clear();

    try {
      final response = await _dio.post('/sms/inbound', data: {
        'sender': '9876543210',
        'body': text,
      });

      if (response.statusCode == 200) {
        final data = response.data;
        final reply = data['reply_dispatched']?['message'] ?? 'SMS प्राप्त हुआ।';
        setState(() {
          _isSmsSending = false;
          _smsChatHistory.add({
            'isUser': false,
            'text': reply,
            'time': 'अभी',
          });
        });
      }
    } catch (_) {
      setState(() {
        _isSmsSending = false;
        _smsChatHistory.add({
          'isUser': false,
          'text': 'कृषि-सारथी: गेहूं पीला रतुआ हेतु प्रोपिकोनाज़ोल 25% EC @ 1ml/L पानी का छिड़काव करें।',
          'time': 'अभी',
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        title: const Text('टेलीकॉम गेटवे (2G USSD & SMS)'),
        backgroundColor: const Color(0xFF1A1A2E),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF4CAF50),
          labelColor: const Color(0xFF4CAF50),
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(icon: Icon(Icons.dialpad), text: '2G USSD (*123#)'),
            Tab(icon: Icon(Icons.sms), text: 'SMS सहायता (56161)'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildUssdKeypadTab(),
          _buildSmsTab(),
        ],
      ),
    );
  }

  Widget _buildUssdKeypadTab() {
    return Center(
      child: SingleChildScrollView(
        child: Container(
          width: 320,
          margin: const EdgeInsets.symmetric(vertical: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: const Color(0xFF2E7D32), width: 2),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 20, spreadRadius: 4),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Screen container (Feature phone LCD display)
              Container(
                height: 140,
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF2C3E2D),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF4CAF50).withValues(alpha: 0.5), width: 1.5),
                ),
                child: _isInUssdSession ? _buildActiveUssdScreen() : _buildIdleDialScreen(),
              ),
              const SizedBox(height: 16),

              // Keypad matrix
              _buildKeypadGrid(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIdleDialScreen() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('BSNL 2G • भारत', style: TextStyle(color: Color(0xFF81C784), fontSize: 10, fontWeight: FontWeight.bold)),
            Icon(Icons.network_cell, size: 14, color: Color(0xFF81C784)),
          ],
        ),
        const Spacer(),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            _dialedNumber.isEmpty ? 'डायल करें' : _dialedNumber,
            style: TextStyle(
              color: const Color(0xFFA5D6A7),
              fontSize: _dialedNumber.length > 8 ? 20 : 26,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ),
        const Spacer(),
        const Text('*123# डायल कर कृषि सेवा शुरू करें', style: TextStyle(color: Color(0xFF81C784), fontSize: 9)),
      ],
    );
  }

  Widget _buildActiveUssdScreen() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Text(
              _currentUssdScreenText,
              style: const TextStyle(color: Color(0xFFA5D6A7), fontSize: 11, height: 1.3, fontWeight: FontWeight.w500),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 32,
                child: TextField(
                  controller: _ussdInputController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'विकल्प दर्ज करें...',
                    hintStyle: const TextStyle(color: Colors.white38, fontSize: 10),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    filled: true,
                    fillColor: Colors.black26,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide.none),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6),
            SizedBox(
              height: 32,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                ),
                onPressed: _isUssdLoading ? null : _sendUssdResponse,
                child: const Text('Send', style: TextStyle(color: Colors.white, fontSize: 11)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildKeypadGrid() {
    final keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['*', '0', '#'],
    ];

    return Column(
      children: [
        // Call & End row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            FloatingActionButton.small(
              heroTag: 'ussd_call',
              backgroundColor: const Color(0xFF2E7D32),
              onPressed: _startUssdSession,
              child: const Icon(Icons.call, color: Colors.white),
            ),
            IconButton(
              icon: const Icon(Icons.backspace, color: Colors.white60),
              onPressed: _onBackspace,
            ),
            FloatingActionButton.small(
              heroTag: 'ussd_end',
              backgroundColor: Colors.redAccent,
              onPressed: () {
                setState(() {
                  _isInUssdSession = false;
                  _dialedNumber = '';
                  _currentUssdScreenText = '';
                });
              },
              child: const Icon(Icons.call_end, color: Colors.white),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // 3x4 Matrix
        for (final row in keys)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (final k in row)
                  InkWell(
                    onTap: () => _onKeyPress(k),
                    borderRadius: BorderRadius.circular(30),
                    child: Container(
                      width: 58,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFF252538),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white12),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        k,
                        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildSmsTab() {
    return Column(
      children: [
        // Top banner
        Container(
          padding: const EdgeInsets.all(12),
          color: const Color(0xFF1E1E30),
          child: const Row(
            children: [
              Icon(Icons.sms_outlined, color: Color(0xFF4CAF50)),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  '2G फीचर फोन SMS सेवा: 56161 पर CROP, MANDI या WEATHER लिखकर भेजें।',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ),
            ],
          ),
        ),

        // Chat list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _smsChatHistory.length,
            itemBuilder: (ctx, idx) {
              final msg = _smsChatHistory[idx];
              final isUser = msg['isUser'] as bool;
              return Align(
                alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
                  decoration: BoxDecoration(
                    color: isUser ? const Color(0xFF2E7D32) : const Color(0xFF252538),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isUser ? Colors.lightGreenAccent.withValues(alpha: 0.3) : Colors.white12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isUser ? 'आप (SMS to 56161)' : 'कृषि-सारथी SMS गेटवे (DLT-10029)',
                        style: TextStyle(color: isUser ? Colors.lightGreenAccent : Colors.white60, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(msg['text'] as String, style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.3)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // Input bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          color: const Color(0xFF161622),
          child: SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _smsBodyController,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'उदा: CROP WHEAT, MANDI INDORE...',
                      hintStyle: const TextStyle(color: Colors.white38, fontSize: 12),
                      filled: true,
                      fillColor: const Color(0xFF252538),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: _isSmsSending ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF4CAF50))) : const Icon(Icons.send, color: Color(0xFF4CAF50)),
                  onPressed: _isSmsSending ? null : _sendSms,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
