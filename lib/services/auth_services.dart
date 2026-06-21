import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:logicaly_ai_project/models/profile_model.dart';
import 'package:logicaly_ai_project/models/user_model.dart';
import 'package:logicaly_ai_project/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _client = Supabase.instance.client;
  final SupabaseService _supabaseService = SupabaseService();

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  User? get currentUser => _client.auth.currentUser;

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) {
    return _client.auth.signInWithPassword(
      email: email.trim(),
      password: password.trim(),
    );
  }

  Future<void> sendPasswordResetEmail({required String email}) {
    return _client.auth.resetPasswordForEmail(
      email.trim(),
      redirectTo: "logicalyai://password-reset",
    );
  }

  Future<void> updatePassword(String password) {
    return _client.auth.updateUser(UserAttributes(password: password.trim()));
  }

  Future<AuthResponse> signUp({
    required String userName,
    required String email,
    required String password,
  }) async {
    final trimmedName = userName.trim();
    final trimmedEmail = email.trim();
    final response = await _client.auth.signUp(
      email: trimmedEmail,
      password: password.trim(),
      data: {"name": trimmedName},
    );

    final user = response.user;
    if (user == null) {
      return response;
    }

    try {
      await _supabaseService.addUser(
        UserModel(uId: user.id, userName: trimmedName, email: trimmedEmail),
        uid: user.id,
      );
      await _supabaseService.addProfile(
        ProfileModel(
          uid: user.id,
          name: trimmedName,
          email: trimmedEmail,
          streakDays: 0,
          dailyGoalMinutes: 30,
          completedMinutes: 0,
          testsTaken: 0,
          studyHours: 0,
        ),
        uid: user.id,
      );
    } catch (error) {
      debugPrint("Supabase profile bootstrap failed: $error");
    }

    return response;
  }

  Future<void> updateDisplayName(String name) {
    return _client.auth.updateUser(UserAttributes(data: {"name": name.trim()}));
  }

  Future<void> signOut() => _client.auth.signOut();
}

class OtpServices {
  String generateOtp() {
    return Random().nextInt(10000).toString().padLeft(4, '0');
  }

  Future<bool> sendOtp(String email, String generatedOtp) async {
    const serviceId = "service_tv62p4p";
    const temId = "template_fl5vsv8";
    const publicKey = "kCOen-_5UnHKUUCU1";

    final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');

    try {
      final Map<String, dynamic> payload = {
        'service_id': serviceId,
        'template_id': temId,
        'user_id': publicKey,
        'template_params': {
          'otp': generatedOtp,
          'email': email.trim(),
          'time': DateTime.now().toString(),
        },
      };

      debugPrint("Sending request to EmailJS...");
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Origin': 'http://localhost',
        },
        body: json.encode(payload),
      );

      if (response.statusCode == 200) {
        debugPrint("OTP sent: ${response.body}");
        return true;
      }

      debugPrint("EmailJS error: ${response.statusCode} - ${response.body}");
      return false;
    } catch (e) {
      debugPrint("OTP connection error: $e");
      return false;
    }
  }

  bool verifyOtp(String sentOtp, String userEnteredOtp) {
    return sentOtp.trim() == userEnteredOtp.trim();
  }
}
