import 'dart:async';

import 'package:flutter/material.dart';
import 'package:logicaly_ai_project/services/auth_services.dart';
import 'package:logicaly_ai_project/views/auth/login_screen.dart';
import 'package:logicaly_ai_project/views/auth/password_reset_screen.dart';
import 'package:logicaly_ai_project/views/navigation_bar.dart';
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
      title: 'Logicaly AI',
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

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late final StreamSubscription<AuthState> _authSubscription;
  Session? _session;
  bool _isPasswordRecovery = false;

  @override
  void initState() {
    super.initState();
    _session = Supabase.instance.client.auth.currentSession;
    _authSubscription = AuthService().authStateChanges.listen((authState) {
      if (!mounted) {
        return;
      }

      setState(() {
        _session = authState.session;
        if (authState.event == AuthChangeEvent.passwordRecovery) {
          _isPasswordRecovery = true;
        } else if (authState.event == AuthChangeEvent.signedOut) {
          _isPasswordRecovery = false;
        }
      });
    });
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isPasswordRecovery) {
      return const PasswordResetScreen();
    }

    if (_session != null) {
      return const NavigationBarScreen();
    }

    return const LoginScreen();
  }
}
