// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';


// Gemini API Service
class GeminiService {
  static const String _systemPrompt = '''
You are **EsperFlow Assistant**, a helpful AI chatbot for the EsperFlow blood donation app. You provide information about:

**EsperFlow App Information:**
- EsperFlow is a blood donation platform connecting donors with recipients
- Mission: "Connecting Life, Saving Lives"
- Created to revolutionize blood donation through centralized technology
- Eliminates delays in finding compatible blood types
- Community-driven network for blood donation

**App Features:**
1. Blood Requests - Post and find blood donation requests
2. Donor Network - Connect with verified blood donors
3. Hospital Links - Access verified hospital networks
4. Donation History - Track donation journey

**Team Information:**
- CEO: Awais Tahir (03189005624, L1f21bsds0012@ucp.edu.pk)
- Manager: Umar Tariq (03104878731, l1f21bsds0055@ucp.edu.pk)

**General Blood Donation Information:**
- Blood types and compatibility
- Donation process and requirements
- Health benefits of donation
- How to prepare for donation
- Post-donation care

If asked about unrelated topics, politely redirect to EsperFlow services.
Always respond in a friendly, helpful manner.
''';

  static final String apiKey = "AIzaSyDl7MWAggdNye9ULp10_P_NFY3iF-bfXi0";

  static Future<String> getResponse(String userPrompt) async {
    try {
      final model = GenerativeModel(
        model: 'gemini-2.5-flash',
        apiKey: apiKey,
        systemInstruction: Content.text(_systemPrompt),
      );

      final prompt = '''
User's question: "$userPrompt"

Provide a helpful response based on EsperFlow app information and blood donation knowledge.
''';

      final response = await model.generateContent([Content.text(prompt)]);
      return response.text ?? "I'm having trouble responding. Please try again.";
    } catch (e) {
      return "Service is temporarily unavailable. Please try again shortly.";
    }
  }
}

class ChatBotScreen extends StatefulWidget {
  const ChatBotScreen({super.key});

  @override
  State<ChatBotScreen> createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Add initial bot message
    _messages.add(
      ChatMessage(
        text:
            "Hello! I'm your EsperFlow Assistant. Ask me anything about:\n\n• Blood donation\n• EsperFlow features\n• Finding donors\n• App information\n• Team details",
        isUser: false,
      ),
    );
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final userMessage = _messageController.text.trim();

    setState(() {
      _messages.add(ChatMessage(text: userMessage, isUser: true));
      _isLoading = true;
    });

    _messageController.clear();
    _scrollToBottom();

    // Get AI response from Gemini
    final botResponse = await GeminiService.getResponse(userMessage);

    setState(() {
      _messages.add(ChatMessage(text: botResponse, isUser: false));
      _isLoading = false;
    });

    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Chat Assistant',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
        elevation: 4,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Chat Topics'),
                  content: const Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('You can ask me about:'),
                      SizedBox(height: 10),
                      Text('• Blood donation process'),
                      Text('• EsperFlow features'),
                      Text('• Finding blood donors'),
                      Text('• App team information'),
                      Text('• Blood type compatibility'),
                      Text('• Donation requirements'),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('OK'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.red.shade50,
              Colors.white,
              Colors.red.shade50,
            ],
          ),
        ),
        child: Column(
          children: [
            // Welcome Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.red.shade600,
                    Colors.red.shade800,
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.bloodtype,
                      color: Colors.red.shade700,
                      size: 35,
                    ),
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    'EsperFlow Assistant',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Ask me anything about blood donation',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),

            // Chat Messages
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                itemCount: _messages.length + (_isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _messages.length && _isLoading) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16, left: 15, right: 15),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.red.shade100,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(
                              Icons.bloodtype,
                              color: Colors.red.shade700,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.red.shade100,
                                  blurRadius: 5,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.red.shade700,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Thinking...',
                                  style: TextStyle(
                                    color: Colors.red.shade800,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  
                  final message = _messages[index];
                  return ChatBubble(message: message);
                },
              ),
            ),

            // Input Area
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: Colors.red.shade100, width: 2),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.shade100,
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: Colors.red.shade200,
                            width: 1,
                          ),
                        ),
                        child: TextField(
                          controller: _messageController,
                          style: const TextStyle(color: Colors.black87),
                          decoration: InputDecoration(
                            hintText: 'Ask about blood donation...',
                            hintStyle: TextStyle(color: Colors.red.shade400),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 15,
                            ),
                            prefixIcon: Icon(
                              Icons.chat_bubble_outline,
                              color: Colors.red.shade700,
                            ),
                          ),
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.red.shade600,
                            Colors.red.shade800,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.shade300,
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        onPressed: _sendMessage,
                        icon: const Icon(Icons.send, color: Colors.white),
                        padding: const EdgeInsets.all(15),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({required this.text, required this.isUser});
}

class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, left: 15, right: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.bloodtype,
                color: Colors.red.shade700,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: message.isUser 
                  ? CrossAxisAlignment.end 
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: message.isUser
                        ? Colors.red.shade700
                        : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: message.isUser 
                          ? const Radius.circular(15)
                          : const Radius.circular(5),
                      topRight: message.isUser 
                          ? const Radius.circular(5)
                          : const Radius.circular(15),
                      bottomLeft: const Radius.circular(15),
                      bottomRight: const Radius.circular(15),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.shade100,
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    message.text,
                    style: TextStyle(
                      color: message.isUser ? Colors.white : Colors.black87,
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  message.isUser ? 'You' : 'EsperFlow Assistant',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 12),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.red.shade200,
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.person,
                color: Colors.red.shade700,
              ),
            ),
          ],
        ],
      ),
    );
  }
}