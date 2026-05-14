import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:logicaly_ai_project/views/profile/profile.dart';

import '../doubt_camera_screen/doubt_camera_screen.dart';
import '../flashcards/flash_card.dart';
import '../quiz/mock_screen.dart';
import '../smart_Notes/smart_notes.dart';

class ChatBot extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _ChatBot();

}
class _ChatBot extends State<ChatBot>{

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

                  // Top Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Icon(Icons.menu, size: 26),
                      InkWell(
                        child: const Icon(Icons.person_outline, size: 26),
                        onTap: () {
                          Navigator.push(
                              context,
                               MaterialPageRoute(builder: (context) => Profile())
                          );
                        },
                      )
                    ],
                  ),

                  const Spacer(),

                  // Title
                  const Text(
                    "How can I help you?",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 25),

                  // Robot Icon
                  Icon(
                    Icons.smart_toy,
                    size: 90,
                    color: Colors.grey.shade300,
                  ),

                  const Spacer(),

                  // Suggestion Buttons
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

                  const SizedBox(height: 20),

                  // Chat Input Box
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    height: 58,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: Colors.grey.shade300,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.add,
                          color: Colors.blue,
                        ),

                        const SizedBox(width: 10),

                        const Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: "Ask Anything",
                              border: InputBorder.none,
                            ),
                          ),
                        ),

                        Icon(
                          Icons.mic_none,
                          color: Colors.blue.shade700,
                        ),

                        const SizedBox(width: 12),

                        Icon(
                          Icons.graphic_eq,
                          color: Colors.blue.shade700,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 15),
                ],
              ),
            ),
          ),
        );
    }

  // Suggestion Button Widget
  Widget _buildSuggestionButton({
    required IconData icon,
    required String text,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF7F7),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: iconColor,
            size: 20,
          ),

          const SizedBox(width: 8),

          Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

}