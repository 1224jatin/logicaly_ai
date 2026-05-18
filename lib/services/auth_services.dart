import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;
  User? get currentUser => _auth.currentUser;
  Future<void> sendOtp({
    required String phoneNumber,
    required Function(String verificationId)
    codeSent,
    required Function(FirebaseAuthException e)
    onError,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted:
          (PhoneAuthCredential credential) async {
        // Auto Login
        await _auth.signInWithCredential(
          credential,
        );
      },
      verificationFailed:
          (FirebaseAuthException e) {
        onError(e);
      },
      codeSent:
          (String verificationId, int? resendToken) {
        codeSent(verificationId);
      },
      codeAutoRetrievalTimeout:
          (String verificationId) {},
    );
  }

  Future<UserCredential?> verifyOtp({
    required String verificationId,
    required String otp,
  }) async {
    try {
      PhoneAuthCredential credential =
      PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );
      UserCredential userCredential =
      await _auth.signInWithCredential(
        credential,
      );

      return userCredential;

    } catch (e) {
      print("OTP Verification Error: $e");
      return null;
    }
  }



}