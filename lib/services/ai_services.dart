import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:logicaly_ai_project/models/ai_message_model.dart';
import 'package:logicaly_ai_project/models/flashcard_model.dart';

class AiService {
  static const String _apiKey = String.fromEnvironment(
    "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",
    defaultValue: "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",
  );
  static const String _chatModel = "llama-3.3-70b-versatile";
  static const String _visionModel = "meta-llama/llama-4-scout-17b-16e-instruct";
  static const String _endpoint =
      "https://api.groq.com/openai/v1/chat/completions";

  Future<String> askChat({
    required String userMessage,
    List<AiMessageModel> history = const [],
  }) async {
    final recentHistory = history.length > 12
        ? history.sublist(history.length - 12)
        : history;
    final messages = <Map<String, dynamic>>[
      {
        "role": "system",
        "content":
            "You are Logicaly AI, a concise study assistant. Explain concepts clearly, use examples when helpful, and keep answers student-friendly.",
      },
      ...recentHistory.map(
            (message) => {
              "role": message.senderId == "ai" ? "assistant" : "user",
              "content": message.message,
            },
          ),
      {"role": "user", "content": userMessage},
    ];

    return _createChatCompletion(messages: messages, maxTokens: 900);
  }

  Future<String> generateNotes(String input) {
    return _createChatCompletion(
      maxTokens: 1200,
      messages: [
        {
          "role": "system",
          "content":
              "Create polished study notes. Use short sections, bullet points, definitions, examples, and a quick revision checklist.",
        },
        {
          "role": "user",
          "content": "Generate smart notes from this topic or raw text:\n$input",
        },
      ],
    );
  }

  Future<String> generateNotesFromImage({
    required List<int> imageBytes,
    required String imageMimeType,
  }) {
    final base64Image = base64Encode(imageBytes);

    return _createChatCompletion(
      model: _visionModel,
      maxTokens: 1400,
      messages: [
        {
          "role": "system",
          "content":
              "Create polished study notes from the uploaded image. Extract the useful study material first, then organize it into short sections, bullet points, definitions, examples, and a quick revision checklist. If the image is unclear, say what is missing.",
        },
        {
          "role": "user",
          "content": [
            {"type": "text", "text": "Generate smart notes from this image."},
            {
              "type": "image_url",
              "image_url": {
                "url": "data:$imageMimeType;base64,$base64Image",
              },
            },
          ],
        },
      ],
    );
  }

  Future<String> generateMockTest({
    required String syllabus,
    required String difficulty,
    required String testType,
    required String duration,
    required String questionCount,
    required bool focusWeakAreas,
  }) {
    return _createChatCompletion(
      maxTokens: 2200,
      messages: [
        {
          "role": "system",
          "content":
              "Generate a student-ready mock test. Put the test first, then an answer key with concise explanations at the end. For coding questions include constraints, sample input, sample output, and expected approach. Keep formatting clean and easy to read in a mobile app.",
        },
        {
          "role": "user",
          "content":
              "Create a mock test from this material:\n$syllabus\n\nPreferences:\nDifficulty: $difficulty\nTest type: $testType\nDuration: $duration\nNumber of questions: $questionCount\nFocus weak areas: ${focusWeakAreas ? "yes" : "no"}",
        },
      ],
    );
  }

  Future<String> generateMockTestFromImage({
    required List<int> imageBytes,
    required String imageMimeType,
    required String difficulty,
    required String testType,
    required String duration,
    required String questionCount,
    required bool focusWeakAreas,
  }) {
    final base64Image = base64Encode(imageBytes);

    return _createChatCompletion(
      model: _visionModel,
      maxTokens: 2200,
      messages: [
        {
          "role": "system",
          "content":
              "You are an exam paper generator. Read the uploaded study material image, extract the usable topics/notes, and generate a student-ready mock test. Put the test first, then an answer key with concise explanations at the end. If the image is unclear, say exactly what is missing.",
        },
        {
          "role": "user",
          "content": [
            {
              "type": "text",
              "text":
                  "Create a mock test from this uploaded image.\n\nPreferences:\nDifficulty: $difficulty\nTest type: $testType\nDuration: $duration\nNumber of questions: $questionCount\nFocus weak areas: ${focusWeakAreas ? "yes" : "no"}",
            },
            {
              "type": "image_url",
              "image_url": {
                "url": "data:$imageMimeType;base64,$base64Image",
              },
            },
          ],
        },
      ],
    );
  }

  Future<List<FlashcardModel>> generateFlashcards(String input) async {
    final response = await _createChatCompletion(
      maxTokens: 1400,
      responseFormat: {"type": "json_object"},
      messages: [
        {
          "role": "system",
          "content":
              "Return only valid JSON with this shape: {\"flashcards\":[{\"question\":\"...\",\"answer\":\"...\"}]}. Create 8 to 12 concise study flashcards.",
        },
        {"role": "user", "content": input},
      ],
    );

    return _flashcardsFromJsonResponse(response);
  }

  Future<List<FlashcardModel>> generateFlashcardsFromImage({
    required List<int> imageBytes,
    required String imageMimeType,
  }) async {
    final base64Image = base64Encode(imageBytes);
    final response = await _createChatCompletion(
      model: _visionModel,
      maxTokens: 1500,
      messages: [
        {
          "role": "system",
          "content":
              "Read the uploaded study material image and return only valid JSON with this shape: {\"flashcards\":[{\"question\":\"...\",\"answer\":\"...\"}]}. Create 8 to 12 concise study flashcards. If the image is unclear, create one flashcard that explains what is missing.",
        },
        {
          "role": "user",
          "content": [
            {
              "type": "text",
              "text": "Create flashcards from this uploaded image.",
            },
            {
              "type": "image_url",
              "image_url": {
                "url": "data:$imageMimeType;base64,$base64Image",
              },
            },
          ],
        },
      ],
    );

    return _flashcardsFromJsonResponse(response);
  }

  Future<String> solveDoubtFromImage({
    required List<int> imageBytes,
    String question = "Solve this doubt from the image.",
  }) async {
    final base64Image = base64Encode(imageBytes);

    return _createChatCompletion(
      model: _visionModel,
      maxTokens: 1400,
      messages: [
        {
          "role": "system",
          "content":
              "You are a doubt-solving tutor. Read the image, identify the question, then solve it step by step. If the image is unclear, say what is missing.",
        },
        {
          "role": "user",
          "content": [
            {"type": "text", "text": question},
            {
              "type": "image_url",
              "image_url": {"url": "data:image/jpeg;base64,$base64Image"},
            },
          ],
        },
      ],
    );
  }

  Future<String> _createChatCompletion({
    required List<Map<String, dynamic>> messages,
    String model = _chatModel,
    int maxTokens = 1000,
    Map<String, dynamic>? responseFormat,
  }) async {
    if (_apiKey.isEmpty) {
      throw AiServiceException(
        "Missing Groq API key. Run Flutter with --dart-define=GROQ_API_KEY=your_key.",
      );
    }

    final response = await http.post(
      Uri.parse(_endpoint),
      headers: {
        "Authorization": "Bearer $_apiKey",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "model": model,
        "messages": messages,
        "temperature": 0.4,
        "max_completion_tokens": maxTokens,
        if (responseFormat != null) "response_format": responseFormat,
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AiServiceException(
        "Groq request failed (${response.statusCode}): ${response.body}",
      );
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final choices = decoded["choices"] as List<dynamic>? ?? [];
    if (choices.isEmpty) {
      throw AiServiceException("Groq returned no choices.");
    }

    final message = choices.first["message"] as Map<String, dynamic>;
    final content = message["content"];
    if (content is String && content.trim().isNotEmpty) {
      return content.trim();
    }

    throw AiServiceException("Groq returned an empty response.");
  }

  String _extractJson(String value) {
    final trimmed = value.trim();
    if (trimmed.startsWith("{") && trimmed.endsWith("}")) {
      return trimmed;
    }

    final start = trimmed.indexOf("{");
    final end = trimmed.lastIndexOf("}");
    if (start == -1 || end == -1 || end <= start) {
      throw AiServiceException("AI response did not contain valid JSON.");
    }
    return trimmed.substring(start, end + 1);
  }

  List<FlashcardModel> _flashcardsFromJsonResponse(String response) {
    final jsonText = _extractJson(response);
    final decoded = jsonDecode(jsonText) as Map<String, dynamic>;
    final cards = decoded["flashcards"] as List<dynamic>? ?? [];
    return cards
        .map((card) => card as Map<String, dynamic>)
        .where(
          (card) =>
              (card["question"] as String?)?.trim().isNotEmpty == true &&
              (card["answer"] as String?)?.trim().isNotEmpty == true,
        )
        .map(
          (card) => FlashcardModel(
            cardId: "",
            cardQues: (card["question"] as String).trim(),
            cardAns: (card["answer"] as String).trim(),
          ),
        )
        .toList();
  }
}

class AiServiceException implements Exception {
  final String message;

  AiServiceException(this.message);

  @override
  String toString() => message;
}
