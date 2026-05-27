import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logicaly_ai_project/views/auth/login_screen.dart';

void main() {
  testWidgets('login screen is the signed-out entry point', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Log in'), findsOneWidget);
    expect(find.textContaining('Sign up'), findsOneWidget);
  });
}
