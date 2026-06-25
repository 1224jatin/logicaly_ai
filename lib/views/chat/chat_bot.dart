import 'package:flutter/material.dart';
import 'package:logicaly_ai_project/models/ai_message_model.dart';
import 'package:logicaly_ai_project/services/auth_services.dart';
import 'package:logicaly_ai_project/services/ai_services.dart';
import 'package:logicaly_ai_project/services/supabase_service.dart';
import 'package:logicaly_ai_project/services/voice_service.dart';
import 'package:logicaly_ai_project/views/profile/profile.dart';

class ChatBot extends StatefulWidget {
  final String? initialPrompt;

  const ChatBot({super.key, this.initialPrompt});

  @override
  State<StatefulWidget> createState() => _ChatBot();
}

class _ChatBot extends State<ChatBot> {
  final SupabaseService _supabaseService = SupabaseService();
  final AiService _aiService = AiService();
  final VoiceService _voiceService = VoiceService();
  final TextEditingController _messageController = TextEditingController();
  
  // Track when the current app session started to hide previous chats
  static final DateTime _sessionStartTime = DateTime.now();
  late Stream<List<AiMessageModel>> _messagesStream;
  
  bool _isSending = false;
  bool _isListening = false;
  bool _isVoiceReady = false;

  @override
  void dispose() {
    _voiceService.stopListening();
    _messageController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _messagesStream = _supabaseService.messagesStream(since: _sessionStartTime);
    final initialPrompt = widget.initialPrompt;
    if (initialPrompt != null && initialPrompt.trim().isNotEmpty) {
      _messageController.text = initialPrompt.trim();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        tooltip: "Chat history",
                        onPressed: _showChatHistory,
                        icon: const Icon(Icons.history, size: 28, color: Colors.black87),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "Logicaly AI",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Profile(),
                        ),
                      );
                    },
                    child: const CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person_outline, size: 24, color: Colors.black87),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: StreamBuilder<List<AiMessageModel>>(
                  stream: _messagesStream,
                  builder: (context, snapshot) {
                    final messages = snapshot.data ?? [];
                    if (messages.isEmpty) {
                      return _buildEmptyState();
                    }

                    return ListView.builder(
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        final isUser = message.senderId != "ai";
                        return Align(
                          alignment: isUser
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            constraints: BoxConstraints(
                              maxWidth:
                                  MediaQuery.of(context).size.width * 0.75,
                            ),
                            decoration: BoxDecoration(
                              color: isUser
                                  ? const Color(0xFF3563E9)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              message.message,
                              style: TextStyle(
                                color: isUser ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              _buildInputBox(),
              const SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "How can I help you?",
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 25),
        Icon(Icons.smart_toy, size: 90, color: Colors.grey.shade300),
        const SizedBox(height: 35),
        Align(
          alignment: Alignment.centerRight,
          child: Column(
            children: [
              _buildSuggestionButton(
                icon: Icons.picture_as_pdf,
                text: "PDF/Notes",
                iconColor: Colors.red,
              ),
              const SizedBox(height: 10),
              _buildSuggestionButton(
                icon: Icons.auto_awesome,
                text: "Summarize text",
                iconColor: Colors.blue,
              ),
              const SizedBox(height: 10),
              _buildSuggestionButton(
                icon: Icons.edit,
                text: "Assignment edit",
                iconColor: Colors.green,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInputBox() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      margin: const EdgeInsets.only(bottom: 8),
      height: 64,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          const SizedBox(width: 8),
          const CircleAvatar(
            radius: 16,
            backgroundColor: Color(0xFFF1F5F9),
            child: Icon(Icons.add, color: Colors.blue, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _messageController,
              style: const TextStyle(fontSize: 15),
              decoration: const InputDecoration(
                hintText: "Ask Anything",
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 10),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          // Voice Input Button
          IconButton(
            tooltip: _isListening ? "Stop listening" : "Voice input",
            onPressed: _isSending ? null : _toggleListening,
            icon: CircleAvatar(
              radius: 20,
              backgroundColor: _isListening ? Colors.red.withOpacity(0.1) : Colors.transparent,
              child: Icon(
                _isListening ? Icons.mic : Icons.mic_none_rounded,
                color: _isListening ? Colors.red : Colors.blue.shade700,
                size: 24,
              ),
            ),
          ),
          // Send Button
          IconButton(
            onPressed: _isSending ? null : _sendMessage,
            icon: Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF3563E9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: _isSending
                  ? const Padding(
                      padding: EdgeInsets.all(10),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.arrow_upward_rounded, color: Colors.white, size: 22),
            ),
          ),
        ],
      ),
    );
  }

  void _showChatHistory() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ChatHistorySheet(supabaseService: _supabaseService),
    );
  }

  Future<void> _toggleListening() async {
    if (_isListening) {
      _voiceService.stopListening();
      setState(() => _isListening = false);
      return;
    }

    if (!_isVoiceReady) {
      _isVoiceReady = await _voiceService.initialize();
      if (!_isVoiceReady) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Microphone permission is required.")),
          );
        }
        return;
      }
    }

    if (!mounted) {
      return;
    }
    setState(() => _isListening = true);
    _voiceService.startListening(
      onResult: (recognizedWords) {
        if (!mounted || recognizedWords.trim().isEmpty) {
          return;
        }
        _messageController.text = recognizedWords;
        _messageController.selection = TextSelection.fromPosition(
          TextPosition(offset: _messageController.text.length),
        );
      },
      onStatus: (status) {
        if (!mounted || status == "listening") {
          return;
        }
        setState(() => _isListening = false);
      },
    );
  }

  Widget _buildSuggestionButton({
    required IconData icon,
    required String text,
    required Color iconColor,
  }) {
    return InkWell(
      onTap: () {
        _messageController.text = text;
        _sendMessage();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFEFF7F7),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 8),
            Text(
              text,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    final uid = AuthService().currentUser?.id;
    if (text.isEmpty || uid == null) {
      return;
    }

    _messageController.clear();
    setState(() => _isSending = true);
    try {
      final history = await _supabaseService.getMessages();
      await _supabaseService.addMessage(
        AiMessageModel(
          messageId: "",
          senderId: uid,
          receiverId: "ai",
          message: text,
        ),
      );
      final aiReply = await _aiService.askChat(
        userMessage: text,
        history: history,
      );

      await _supabaseService.addMessage(
        AiMessageModel(
          messageId: "",
          senderId: "ai",
          receiverId: uid,
          message: aiReply,
        ),
      );
      await _supabaseService.addActivity(title: "Asked AI", subtitle: text);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Could not generate reply: $error")),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }
}

class _ChatHistorySheet extends StatefulWidget {
  final SupabaseService supabaseService;

  const _ChatHistorySheet({required this.supabaseService});

  @override
  State<_ChatHistorySheet> createState() => _ChatHistorySheetState();
}

class _ChatHistorySheetState extends State<_ChatHistorySheet> {
  late final Stream<List<AiMessageModel>> _historyStream;

  @override
  void initState() {
    super.initState();
    _historyStream = widget.supabaseService.messagesStream();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  "Chat History",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: StreamBuilder<List<AiMessageModel>>(
                  stream: _historyStream,
                  builder: (context, snapshot) {
                    final messages = snapshot.data ?? [];
                    if (messages.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Text("No chat history yet."),
                        ),
                      );
                    }

                    return ListView.separated(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      itemCount: messages.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        final isUser = message.senderId != "ai";
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isUser ? Colors.blue.shade50 : Colors.purple.shade50,
                            child: Icon(
                              isUser ? Icons.person_outline : Icons.smart_toy_outlined,
                              color: isUser ? Colors.blue : Colors.purple,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            isUser ? "You" : "Logicaly AI",
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                          ),
                          subtitle: Text(
                            message.message,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 13),
                          ),
                          onTap: () {
                            Navigator.pop(context);
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
