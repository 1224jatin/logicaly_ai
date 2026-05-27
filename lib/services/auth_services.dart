import 'dart:convert';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:logicaly_ai_project/models/profile_model.dart';
import 'package:logicaly_ai_project/models/user_model.dart';
import 'package:logicaly_ai_project/services/fire_store_services.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );
  }

  Future<UserCredential> signUp({
    required String userName,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );

    final user = credential.user;
    if (user == null) {
      return credential;
    }

    await user.updateDisplayName(userName.trim());
    await _firestoreService.addUser(
      UserModel(uId: user.uid, userName: userName.trim(), email: email.trim()),
    );
    await _firestoreService.addProfile(
      ProfileModel(
        uid: user.uid,
        name: userName.trim(),
        email: email.trim(),
        streakDays: 0,
        dailyGoalMinutes: 30,
        completedMinutes: 0,
        testsTaken: 0,
        studyHours: 0,
      ),
    );

    return credential;
  }

  Future<void> signOut() => _auth.signOut();
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
