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
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: navigationScreens[seletedIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: seletedIndex,
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.black54,
          type: BottomNavigationBarType.fixed,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.edit_outlined),
              label: "",
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.crop_free),
              label: "",
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.smart_toy),
              label: "",
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.note_add_outlined),
              label: "",
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.layers_outlined),
              label: "",
            ),
          ],
          onTap: (index) {
            if (seletedIndex != index) {
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
