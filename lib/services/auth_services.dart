import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

class OtpServices {
  String generateOtp() {
    int generatedOtp = Random().nextInt(900000) + 100000;
    return generatedOtp.toString();
  }

  Future<bool> sendOtp(String email, String generatedOtp) async {
    // 1. Verify these in EmailJS Dashboard
    const serviceId = "service_tkyqtoe";
    const temId = "tmplate_khhlpkd";
    const publicKey = "JL5oMjEMQdUFmE82K"; // This is your user_id

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

      print("Sending request to EmailJS...");
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Origin': 'http://localhost',
        },
        body: json.encode(payload),
      );

      if (response.statusCode == 200) {
        print("✅ Success: ${response.body}");
        return true;
      } else {
        // If it returns 400, check if you need an 'accessToken' in the payload
        print("❌ EmailJS Error: ${response.statusCode} - ${response.body}");
        return false;
      }
    } catch (e) {
      print("❌ Connection Error: $e");
      return false;
    }
  }

  bool verifyOtp(String sentOtp, String userEnteredOtp) {
    return sentOtp.trim() == userEnteredOtp.trim();
  }
}
