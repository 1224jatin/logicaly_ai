import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:logicaly_ai_project/models/ai_message_model.dart';
import 'package:logicaly_ai_project/services/fire_store_services.dart';
import 'package:logicaly_ai_project/views/profile/profile.dart';

class ChatBot extends StatefulWidget {
  const ChatBot({super.key});

  @override
  State<StatefulWidget> createState() => _ChatBot();
}

class _ChatBot extends State<ChatBot> {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
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
                  const Icon(Icons.menu, size: 26),
                  InkWell(
                    child: const Icon(Icons.person_outline, size: 26),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Profile(),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: StreamBuilder<List<AiMessageModel>>(
                  stream: _firestoreService.messagesStream(),
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
      padding: const EdgeInsets.symmetric(horizontal: 14),
      height: 58,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          const Icon(Icons.add, color: Colors.blue),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: "Ask Anything",
                border: InputBorder.none,
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          IconButton(
            onPressed: _sendMessage,
            icon: Icon(Icons.send, color: Colors.blue.shade700),
          ),
        ],
      ),
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
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (text.isEmpty || uid == null) {
      return;
    }

    _messageController.clear();
    await _firestoreService.addMessage(
      AiMessageModel(
        messageId: "",
        senderId: uid,
        receiverId: "ai",
        message: text,
      ),
    );
    await _firestoreService.addMessage(
      AiMessageModel(
        messageId: "",
        senderId: "ai",
        receiverId: uid,
        message: "Saved. AI response generation can be connected here.",
      ),
    );
    await _firestoreService.addActivity(title: "Asked AI", subtitle: text);
  }
}
