import 'package:flutter/material.dart';
import 'package:logicaly_ai_project/views/quiz/mock_screen.dart';
import 'package:logicaly_ai_project/views/smart_Notes/smart_notes.dart';

import 'chat/chat_bot.dart';
import 'doubt_camera_screen/doubt_camera_screen.dart';
import 'flashcards/flash_card.dart';

class NavigationBarScreen extends StatefulWidget {
  const NavigationBarScreen({super.key});

  @override
  State<StatefulWidget> createState() => _NavigationBarScreen();
}

class _NavigationBarScreen extends State<NavigationBarScreen> {
  final List<Widget> navigationScreens = [
    const SmartNotes(),
    const DoubtCameraScreen(),
    const ChatBot(),
    const MockTestScreen(),
    const FlashCard(),
  ];
  int seletedIndex = 2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationScreens[seletedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: seletedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.black54,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.edit_outlined), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.crop_free), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.smart_toy), label: ""),
          BottomNavigationBarItem(
            icon: Icon(Icons.note_add_outlined),
            label: "",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.delete_outline), label: ""),
        ],
        onTap: (index) {
          setState(() {
            seletedIndex = index;
          });
        },
      ),
    );
  }
}
