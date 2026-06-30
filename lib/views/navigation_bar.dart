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
  final List<int> _history = [2];
  final List<Widget> navigationScreens = [
    const SmartNotes(),
    const DoubtCameraScreen(),
    const ChatBot(),
    const MockTestScreen(),
    const FlashCard(),
  ];
  int seletedIndex = 2;

  Future<bool> _onWillPop() async {
    if (_history.length > 1) {
      setState(() {
        _history.removeLast();
        seletedIndex = _history.last;
      });
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _history.length <= 1,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        _onWillPop();
      },
      child: Scaffold(
        body: IndexedStack(
          index: seletedIndex,
          children: navigationScreens,
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: seletedIndex,
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.black54,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.edit_outlined),
              label: "Notes",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.crop_free),
              label: "Scan",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.smart_toy),
              label: "AI Chat",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.note_add_outlined),
              label: "Tests",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.layers_outlined),
              label: "Cards",
            ),
          ],
          onTap: (index) {
            if (seletedIndex != index) {
              // Dismiss keyboard to prevent 'dirty widget' errors during transition
              FocusScope.of(context).unfocus();

              setState(() {
                seletedIndex = index;
                _history.remove(index);
                _history.add(index);
              });
            }
          },
        ),
      ),
    );
  }
}
