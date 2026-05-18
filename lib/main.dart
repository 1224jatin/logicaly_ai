import 'package:flutter/material.dart';
import 'package:logicaly_ai_project/views/auth/login_screen.dart';
import 'package:logicaly_ai_project/views/auth/sign_up_screen.dart';
import 'package:logicaly_ai_project/views/chat/chat_bot.dart';
import 'package:logicaly_ai_project/views/doubt_camera_screen/doubt_camera_screen.dart';
import 'package:logicaly_ai_project/views/flashcards/flash_card.dart';
import 'package:logicaly_ai_project/views/flashcards/manual_flashcards.dart';
import 'package:logicaly_ai_project/views/profile/profile.dart';
import 'package:logicaly_ai_project/views/smart_Notes/smart_notes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,      ),
      home:  SignUpScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(

        child: Column(

          mainAxisAlignment: .center,
          children: [
          ],
        ),
      ),
    );
  }
}
