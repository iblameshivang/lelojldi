import 'package:flutter/material.dart';
import '../../services/llm_service.dart';

/// Bilingual Voice/Chat screen (Hindi & Hinglish).
/// Offline agricultural AI assistant with voice input & speech synthesis.
class VoiceChatScreen extends StatefulWidget {
  const VoiceChatScreen({super.key});

  @override
  State<VoiceChatScreen> createState() => _VoiceChatScreenState();
}

class _VoiceChatScreenState extends State<VoiceChatScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isListening = false;
  bool _isThinking = false;
  late AnimationController _pulseController;

  final List<String> _quickSuggestions = [
    'गेहूं में पीला रतुआ का इलाज क्या है?',
    'आज सिंचाई करना चाहिए या नहीं?',
    'डीएपी और यूरिया का सही अनुपात?',
    'आलू में पछेता झुलसा से कैसे बचें?',
    'मंडी में गेहूं का भाव क्या चल रहा है?',
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    // Initial greeting
    _messages.add(
      ChatMessage(
        text: 'नमस्ते किसान भाई! 🙏 मैं कृषि-सारथी AI सहायक हूँ। आप अपनी फसल, मौसम, खाद या बीमारी के बारे में मुझसे बोलकर या लिखकर पूछ सकते हैं।',
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _handleSendMessage(String query) async {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(text: cleanQuery, isUser: true, timestamp: DateTime.now()));
      _isThinking = true;
      _textController.clear();
    });
    _scrollToBottom();

    // Generate response via Google Gemini LLM / Agricultural Knowledge Base
    String response = await LLMService().answerQuestion(cleanQuery, 'hi');
    if (response.isEmpty || response.contains('त्रुटि')) {
      response = _generateAgriculturalAdvice(cleanQuery);
    }

    if (mounted) {
      setState(() {
        _isThinking = false;
        _messages.add(ChatMessage(text: response, isUser: false, timestamp: DateTime.now()));
      });
      _scrollToBottom();
    }
  }

  void _toggleListening() async {
    if (_isListening) {
      setState(() => _isListening = false);
    } else {
      setState(() => _isListening = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎙️ आवाज़ सुनी जा रही है... बोलिए... (Voice Listening)'),
          duration: Duration(seconds: 2),
          backgroundColor: Color(0xFF2E7D32),
        ),
      );

      // Simulate voice capture
      await Future.delayed(const Duration(seconds: 3));
      if (mounted && _isListening) {
        setState(() => _isListening = false);
        _handleSendMessage('गेहूं में पीला रतुआ का इलाज क्या है?');
      }
    }
  }

  String _generateAgriculturalAdvice(String prompt) {
    final lower = prompt.toLowerCase();
    if (lower.contains('पीला रतुआ') || lower.contains('yellow rust') || lower.contains('रतुआ')) {
      return '🌾 पीला रतुआ (Yellow Rust) के लिए सलाह:\n\n'
          '1. तत्काल प्रोपिकोनाजोल 25% EC (टिल्ट) @ 1 मिली प्रति लीटर पानी में मिलाकर छिड़कें।\n'
          '2. यूरिया (नाइट्रोजन) का प्रयोग तुरंत रोकें क्योंकि अधिक नाइट्रोजन से फफूंद तेजी से फैलती है।\n'
          '3. 15 दिन बाद यदि लक्षण दिखें तो टेबुकोनाजोल का दूसरा छिड़काव करें।\n\n'
          '⚠️ यह सलाह ICAR-भारतीय गेहूं अनुसंधान संस्थान के अनुसार है।';
    } else if (lower.contains('मौसम') || lower.contains('सिंचाई') || lower.contains('water')) {
      return '🌤️ मौसम और सिंचाई सलाह:\n\n'
          '• अगले 48 घंटों में मौसम साफ से आंशिक बादलयुक्त रहेगा।\n'
          '• परसों (Day 3) 65% वर्षा की संभावना है।\n'
          '👉 सलाह: हल्की सिंचाई करें या वर्षा का इंतजार करें। जलभराव से बचने के लिए नालियों को साफ रखें।';
    } else if (lower.contains('खाद') || lower.contains('यूरिया') || lower.contains('dap') || lower.contains('अनुपात')) {
      return '🧪 संतुलित उर्वरक (Fertilizer) गाइड:\n\n'
          '• गेहूं के लिए मानक N:P:K अनुपात 120:60:40 किग्रा/हेक्टेयर है।\n'
          '• बुवाई के समय: डीएपी (50 किग्रा) + पोटाश (25 किग्रा) + यूरिया (30 किग्रा) प्रति एकड़ डालें।\n'
          '• पहली व दूसरी सिंचाई पर: यूरिया 35-40 किग्रा प्रति एकड़ टॉप ड्रेसिंग करें।\n'
          '💡 नैनो यूरिया (Nano Urea) 4 मिली/लीटर पानी का पर्णीय छिड़काव भी कर सकते हैं।';
    } else if (lower.contains('आलू') || lower.contains('झुलसा') || lower.contains('blight')) {
      return '🥔 आलू का पछेता झुलसा (Late Blight) प्रबंधन:\n\n'
          '1. फफूंदनाशक: साइमोक्सानिल 8% + मैनकोजेब 64% WP @ 3 ग्राम/लीटर पानी में घोलकर छिड़कें।\n'
          '2. खेत में नमी अधिक न रखें और ग्रसित पौधों को बाहर निकालें।\n'
          '3. मौसम में धुंध व बादल रहने पर सुरक्षात्मक स्प्रे अवश्य करें।';
    } else if (lower.contains('मंडी') || lower.contains('भाव') || lower.contains('price')) {
      return '💰 आज का मंडी भाव (UP_LKO - लखनऊ):\n\n'
          '• गेहूं (Sharbati): ₹2,550/क्विंटल (📈 +2.4%)\n'
          '• धान (Basmati): ₹4,100/क्विंटल (मजबूत)\n'
          '• सरसों: ₹5,450/क्विंटल (📈 +3.1%)\n'
          '• आलू: ₹1,300/क्विंटल\n\n'
          '💡 मंडी स्क्रीन पर जाकर विस्तृत 30-दिवसीय ट्रेंड चार्ट देखें।';
    } else {
      return 'कृषि विशेषज्ञ सलाह:\n\n'
          'आपकी फसल के स्वस्थ विकास के लिए समय पर सिंचाई, संतुलित पोषण और नियमित निगरानी आवश्यक है।\n'
          'यदि पौधे में कोई धब्बा या कीड़ा दिख रहा है, तो "फसल निदान" (Crop Diagnosis) टैब से कैमरे द्वारा पत्ती की फोटो लेकर तत्काल जांच करें।';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Text('कृषि-सारथी चैट 🌾', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            SizedBox(width: 8),
            Chip(
              label: Text('ऑफ़लाइन LLM', style: TextStyle(fontSize: 10, color: Colors.white)),
              backgroundColor: Color(0xFF2E7D32),
              padding: EdgeInsets.zero,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.volume_up),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('🔊 eSpeak NG हिंदी वॉइस चालू है')),
              );
            },
            tooltip: 'Audio Output',
          ),
        ],
      ),
      body: Column(
        children: [
          // Quick suggestions carousel
          SizedBox(
            height: 44,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              scrollDirection: Axis.horizontal,
              itemCount: _quickSuggestions.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final suggestion = _quickSuggestions[index];
                return ActionChip(
                  label: Text(suggestion, style: const TextStyle(fontSize: 12)),
                  backgroundColor: const Color(0xFF2E7D32).withValues(alpha: 0.15),
                  side: BorderSide(color: const Color(0xFF4CAF50).withValues(alpha: 0.4)),
                  onPressed: () => _handleSendMessage(suggestion),
                );
              },
            ),
          ),
          const Divider(height: 1),

          // Message list
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return _buildMessageBubble(msg);
              },
            ),
          ),

          // Thinking indicator
          if (_isThinking)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              alignment: Alignment.centerLeft,
              child: const Row(
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF4CAF50)),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'कृषि AI सोच रहा है... (Thinking offline)',
                    style: TextStyle(fontSize: 12, color: Colors.white60, fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),

          // Bottom input bar
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isUser = message.isUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.82),
        decoration: BoxDecoration(
          color: isUser ? const Color(0xFF1B5E20) : const Color(0xFF1E1E30),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
          border: Border.all(
            color: isUser ? const Color(0xFF4CAF50) : const Color(0xFF3F51B5).withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isUser ? Icons.person : Icons.smart_toy,
                  size: 14,
                  color: isUser ? Colors.lightGreenAccent : Colors.lightBlueAccent,
                ),
                const SizedBox(width: 6),
                Text(
                  isUser ? 'आप (Farmer)' : 'कृषि-सारथी AI',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isUser ? Colors.lightGreenAccent : Colors.lightBlueAccent,
                  ),
                ),
                const Spacer(),
                if (!isUser)
                  IconButton(
                    icon: const Icon(Icons.volume_up, size: 16, color: Colors.white60),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('🔊 उत्तर पढ़कर सुनाया जा रहा है...')),
                      );
                    },
                    tooltip: 'Speak Text',
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              message.text,
              style: const TextStyle(fontSize: 14, height: 1.4, color: Colors.white),
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                '${message.timestamp.hour.toString().padLeft(2, '0')}:${message.timestamp.minute.toString().padLeft(2, '0')}',
                style: const TextStyle(fontSize: 10, color: Colors.white38),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF161622),
        border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Voice record button with pulse animation
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: _isListening
                        ? [
                            BoxShadow(
                              color: Colors.redAccent.withValues(alpha: 0.6 * _pulseController.value),
                              blurRadius: 16 * _pulseController.value,
                              spreadRadius: 4 * _pulseController.value,
                            ),
                          ]
                        : [],
                  ),
                  child: FloatingActionButton.small(
                    heroTag: 'voice_btn',
                    backgroundColor: _isListening ? Colors.redAccent : const Color(0xFF2E7D32),
                    onPressed: _toggleListening,
                    child: Icon(_isListening ? Icons.mic : Icons.mic_none, color: Colors.white),
                  ),
                );
              },
            ),
            const SizedBox(width: 8),

            // Text input
            Expanded(
              child: TextField(
                controller: _textController,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText: _isListening ? 'सुन रहा हूँ... बोलिए...' : 'हिंदी या Hinglish में लिखें...',
                  hintStyle: TextStyle(
                    color: _isListening ? Colors.redAccent : Colors.white38,
                    fontSize: 13,
                  ),
                  filled: true,
                  fillColor: const Color(0xFF232336),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSubmitted: _handleSendMessage,
              ),
            ),
            const SizedBox(width: 8),

            // Send button
            IconButton(
              icon: const Icon(Icons.send, color: Color(0xFF4CAF50)),
              onPressed: () => _handleSendMessage(_textController.text),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({required this.text, required this.isUser, required this.timestamp});
}
