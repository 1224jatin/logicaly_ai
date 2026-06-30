import 'dart:async';

import 'package:flutter/material.dart';
import 'package:logicaly_ai_project/views/auth/auth_gate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const String _supabaseUrl = "https://cbnpzpcyjydpcfyzzije.supabase.co";
const String _supabaseAnonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNibnB6cGN5anlkcGNmeXp6aWplIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODIwMjk4OTEsImV4cCI6MjA5NzYwNTg5MX0.1qQRLZSrpqQDoVWb_-i8rZdbQG4TrKJogM84aN7WPMo";

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (_supabaseAnonKey.isEmpty || _supabaseAnonKey.contains("PASTE")) {
    runApp(const MissingSupabaseConfigApp());
    return;
  }

  await Supabase.initialize(
    url: _supabaseUrl,
    anonKey: _supabaseAnonKey,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Logiqly',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const AuthGate(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MissingSupabaseConfigApp extends StatelessWidget {
  const MissingSupabaseConfigApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              "Missing Supabase anon key. Paste it into _supabaseAnonKey in lib/main.dart.",
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
