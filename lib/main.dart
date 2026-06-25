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
  late final Stream<AuthState> _authStateStream;

  @override
  void initState() {
    super.initState();
    _authStateStream = AuthService().authStateChanges;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: _authStateStream,
      builder: (context, snapshot) {
        // 1. Handle password recovery state
        if (snapshot.data?.event == AuthChangeEvent.passwordRecovery) {
          return const PasswordResetScreen();
        }

        // 2. Determine if we have a valid session.
        // We check the snapshot first, then fallback to the synchronous currentSession.
        final session = snapshot.data?.session ?? Supabase.instance.client.auth.currentSession;

        if (session != null) {
          return const NavigationBarScreen();
        }

        // 3. Fallback to Login screen if not authenticated.
        // We don't need a waiting state here because Supabase.initialize was awaited in main(),
        // so currentSession is already determined.
        return const LoginScreen();
      },
    );
  }
}
