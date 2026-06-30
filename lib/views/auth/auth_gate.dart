import 'package:flutter/material.dart';
import 'package:logicaly_ai_project/services/auth_services.dart';
import 'package:logicaly_ai_project/views/auth/login_screen.dart';
import 'package:logicaly_ai_project/views/auth/password_reset_screen.dart';
import 'package:logicaly_ai_project/views/navigation_bar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late final Stream<AuthState> _authStream;

  @override
  void initState() {
    super.initState();
    _authStream = Supabase.instance.client.auth.onAuthStateChange;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: _authStream,
      builder: (context, snapshot) {
        final session = Supabase.instance.client.auth.currentSession;

        if (snapshot.data?.event == AuthChangeEvent.passwordRecovery) {
          return const PasswordResetScreen();
        }

        if (session != null) {
          return const NavigationBarScreen();
        }

        return const LoginScreen();
      },
    );
  }
}
