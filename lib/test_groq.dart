import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  test('Test Groq API Connection', () async {
    const apiKey = String.fromEnvironment("GROQ_API_KEY");
    const endpoint = "https://api.groq.com/openai/v1/chat/completions";
    const model = "llama-3.3-70b-versatile";

    if (apiKey.isEmpty) {
      fail("Missing GROQ_API_KEY. Run with --dart-define=GROQ_API_KEY=your_key.");
    }

    try {
      print("Sending request to Groq...");
      final response = await http.post(
        Uri.parse(endpoint),
        headers: {
          "Authorization": "Bearer $apiKey",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "model": model,
          "messages": [
            {"role": "user", "content": "Hello"}
          ],
          "temperature": 0.4,
          "max_completion_tokens": 100,
        }),
      );

      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");
    } catch (e) {
      print("Connection failed: $e");
    }
  });
}
