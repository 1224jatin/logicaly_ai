import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:logicaly_ai_project/models/ai_message_model.dart';
import 'package:logicaly_ai_project/models/flashcard_model.dart';
import 'package:logicaly_ai_project/services/secrets.dart';

class AiService {
  static const String _envApiKey = String.fromEnvironment("GROQ_API_KEY");
  static String get _rawApiKey =>
      _envApiKey.isNotEmpty ? _envApiKey : Secrets.groqApiKey;

  static const String _chatModel = "llama-3.3-70b-versatile";
  static const String _visionModel = "meta-llama/llama-4-scout-17b-16e-instruct";
  static const String _endpoint =
      "https://api.groq.com/openai/v1/chat/completions";
  static const int _maxStudyInputChars = 10000;
  static const int _maxChatInputChars = 12000;

  Future<String> askChat({
    required String userMessage,
    List<AiMessageModel> history = const [],
  }) async {
    final safeUserMessage = _fitTextToBudget(
      userMessage,
      _maxChatInputChars,
      notice:
          "The message was shortened to fit the AI request limit. Answer using the available parts.",
    );
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
      {"role": "user", "content": safeUserMessage},
    ];

    return _createChatCompletion(messages: messages, maxTokens: 900);
  }

  Future<String> generateNotes(String input) {
    final studyInput = _prepareStudyInput(input);
    return _createChatCompletion(
      maxTokens: 1200,
      messages: [
        {
          "role": "system",
          "content":
              "Create polished study notes. Use short sections, bullet points, definitions, examples, and a quick revision checklist. If the source says it was condensed, mention that the notes are based on the available extracted sections.",
        },
        {
          "role": "user",
          "content": "Generate smart notes from this topic or raw text:\n$studyInput",
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
    final studyInput = _prepareStudyInput(syllabus);
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
              "Create a mock test from this material:\n$studyInput\n\nPreferences:\nDifficulty: $difficulty\nTest type: $testType\nDuration: $duration\nNumber of questions: $questionCount\nFocus weak areas: ${focusWeakAreas ? "yes" : "no"}",
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
    final studyInput = _prepareStudyInput(input);
    final response = await _createChatCompletion(
      maxTokens: 1400,
      responseFormat: {"type": "json_object"},
      messages: [
        {
          "role": "system",
          "content":
              "Return only valid JSON with this shape: {\"flashcards\":[{\"question\":\"...\",\"answer\":\"...\"}]}. Create 8 to 12 concise study flashcards.",
        },
        {"role": "user", "content": studyInput},
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
    final apiKey = _normalizedApiKey;
    if (apiKey.isEmpty) {
      throw AiServiceException(
        "Missing Groq API key. Run Flutter with --dart-define=GROQ_API_KEY=your_key.",
      );
    }

    try {
      final response = await http.post(
        Uri.parse(_endpoint),
        headers: {
          "Authorization": "Bearer $apiKey",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "model": model,
          "messages": messages,
          "temperature": 0.4,
          "max_tokens": maxTokens,
          if (responseFormat != null) "response_format": responseFormat,
        }),
      );

      if (response.statusCode == 401) {
        throw AiServiceException(
          "Invalid or expired Groq API key. Rebuild the APK with GROQ_API_KEY and make sure the key is active.",
        );
      } else if (response.statusCode == 413) {
        throw AiServiceException(
          "The uploaded content is too large for AI. Use a PDF with 2 pages or less, or shorten the text.",
        );
      } else if (response.statusCode == 429) {
        throw AiServiceException("Rate limit reached. Please wait a moment.");
      } else if (response.statusCode != 200) {
        throw AiServiceException(
          _friendlyGroqError(response.statusCode, response.body),
        );
      }

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final choices = decoded["choices"] as List<dynamic>? ?? [];
      if (choices.isEmpty) {
        throw AiServiceException("No response from AI.");
      }

      final message = choices.first["message"] as Map<String, dynamic>;
      final content = message["content"];
      if (content is String && content.trim().isNotEmpty) {
        return content.trim();
      }

      throw AiServiceException("Empty response received.");
    } catch (e) {
      if (e is AiServiceException) rethrow;
      throw AiServiceException("Connection failed. Check your internet.");
    }
  }

  String get _normalizedApiKey {
    var trimmed = _rawApiKey.trim();
    const definePrefix = "GROQ_API_KEY=";
    final defineIndex = trimmed.indexOf(definePrefix);
    if (defineIndex != -1) {
      trimmed = trimmed.substring(defineIndex + definePrefix.length).trim();
    }
    if ((trimmed.startsWith('"') && trimmed.endsWith('"')) ||
        (trimmed.startsWith("'") && trimmed.endsWith("'"))) {
      trimmed = trimmed.substring(1, trimmed.length - 1).trim();
    }
    return trimmed.replaceAll(RegExp(r"\s+"), "");
  }

  String _prepareStudyInput(String input) {
    return _fitTextToBudget(
      input,
      _maxStudyInputChars,
      notice:
          "The source text was shortened to fit the AI request limit. Use only the available content.",
    );
  }

  String _fitTextToBudget(
    String input,
    int maxChars, {
    required String notice,
  }) {
    final compact = input.replaceAll(RegExp(r"\n{3,}"), "\n\n").trim();
    if (compact.length <= maxChars) {
      return compact;
    }

    final headLength = (maxChars * 0.7).floor();
    final tailLength = maxChars - headLength;
    final head = compact.substring(0, headLength).trim();
    final tail = compact.substring(compact.length - tailLength).trim();
    return "$notice\n\n$head\n\n[Middle content removed to fit request size.]\n\n$tail";
  }

  String _friendlyGroqError(int statusCode, String responseBody) {
    final providerMessage = _extractProviderMessage(responseBody);
    if (providerMessage.contains("rate_limit") ||
        providerMessage.contains("tokens per minute") ||
        providerMessage.contains("request too large")) {
      return "The AI request is too large right now. Shorten the text or upload a PDF with 2 pages or less.";
    }

    if (providerMessage.contains("api key") ||
        providerMessage.contains("invalid api key") ||
        providerMessage.contains("unauthorized")) {
      return "Groq API key is invalid. Rebuild the app with a valid GROQ_API_KEY.";
    }

    return "AI request failed ($statusCode). Please try again.";
  }

  String _extractProviderMessage(String responseBody) {
    try {
      final decoded = jsonDecode(responseBody);
      if (decoded is Map<String, dynamic>) {
        final error = decoded["error"];
        if (error is Map<String, dynamic>) {
          final message = error["message"];
          if (message is String) {
            return message.toLowerCase();
          }
        }
      }
    } catch (_) {
      // Fall back to a short lowercase body check below.
    }
    return responseBody.toLowerCase();
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
