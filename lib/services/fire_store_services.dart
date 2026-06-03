import 'package:logicaly_ai_project/models/ai_message_model.dart';
import 'package:logicaly_ai_project/models/flashcard_model.dart';
import 'package:logicaly_ai_project/models/profile_model.dart';
import 'package:logicaly_ai_project/models/quizz_model.dart';
import 'package:logicaly_ai_project/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FirestoreService {
  final SupabaseClient _client = Supabase.instance.client;

  String? get currentUid => _client.auth.currentUser?.id;

  String _requiredUid([String? uid]) {
    final userId = uid ?? currentUid;
    if (userId == null) {
      throw StateError("No signed-in user found.");
    }
    return userId;
  }

  Future<void> addUser(UserModel userModel, {String? uid}) async {
    await _client.from("users").upsert({
      "id": uid ?? userModel.uId,
      "user_name": userModel.userName,
      "email": userModel.email,
    });
  }

  Future<UserModel?> getUser(String uid) async {
    final data = await _client
        .from("users")
        .select()
        .eq("id", uid)
        .maybeSingle();
    if (data == null) {
      return null;
    }
    return UserModel.fromJson(_normalizeUser(data));
  }

  Future<void> addMessage(AiMessageModel aiMessageModel, {String? uid}) async {
    final userId = _requiredUid(uid);
    await _client.from("messages").insert({
      "user_id": userId,
      "sender_id": aiMessageModel.senderId,
      "receiver_id": aiMessageModel.receiverId,
      "message": aiMessageModel.message,
    });
  }

  Stream<List<AiMessageModel>> messagesStream({String? uid}) {
    final userId = _requiredUid(uid);
    return _client
        .from("messages")
        .stream(primaryKey: ["id"])
        .eq("user_id", userId)
        .order("created_at")
        .map(
          (rows) => rows
              .map((row) => AiMessageModel.fromJson(_normalizeMessage(row)))
              .toList(),
        );
  }

  Future<List<AiMessageModel>> getMessages({String? uid}) async {
    final userId = _requiredUid(uid);
    final rows = await _client
        .from("messages")
        .select()
        .eq("user_id", userId)
        .order("created_at");

    return rows
        .map((row) => AiMessageModel.fromJson(_normalizeMessage(row)))
        .toList();
  }

  Future<void> addFlashcard(
    FlashcardModel flashcardModel, {
    String? uid,
  }) async {
    final userId = _requiredUid(uid);
    await _client.from("flashcards").insert({
      "user_id": userId,
      "question": flashcardModel.cardQues,
      "answer": flashcardModel.cardAns,
    });
  }

  Stream<List<FlashcardModel>> flashcardsStream({String? uid}) {
    final userId = _requiredUid(uid);
    return _client
        .from("flashcards")
        .stream(primaryKey: ["id"])
        .eq("user_id", userId)
        .order("created_at", ascending: false)
        .map(
          (rows) => rows
              .map((row) => FlashcardModel.fromJson(_normalizeFlashcard(row)))
              .toList(),
        );
  }

  Future<List<FlashcardModel>> getFlashcards({String? uid}) async {
    final userId = _requiredUid(uid);
    final rows = await _client
        .from("flashcards")
        .select()
        .eq("user_id", userId)
        .order("created_at", ascending: false);

    return rows
        .map((row) => FlashcardModel.fromJson(_normalizeFlashcard(row)))
        .toList();
  }

  Future<void> addProfile(ProfileModel profileModel, {String? uid}) async {
    await _client.from("profiles").upsert({
      "id": uid ?? profileModel.uid,
      "name": profileModel.name,
      "email": profileModel.email,
      "streak_days": profileModel.streakDays,
      "daily_goal_minutes": profileModel.dailyGoalMinutes,
      "completed_minutes": profileModel.completedMinutes,
      "tests_taken": profileModel.testsTaken,
      "study_hours": profileModel.studyHours,
    });
  }

  Future<void> updateCurrentProfile(Map<String, dynamic> data) async {
    final userId = _requiredUid();
    await _client.from("profiles").upsert({
      "id": userId,
      ..._profileUpdateToSupabase(data),
    });
  }

  Future<void> incrementTestsTaken() async {
    final userId = _requiredUid();
    final profile = await getProfile(userId);
    await updateCurrentProfile({
      "testsTaken": (profile?.testsTaken ?? 0) + 1,
    });
  }

  Stream<ProfileModel?> currentProfileStream() {
    final userId = currentUid;
    if (userId == null) {
      return Stream.value(null);
    }

    return _client
        .from("profiles")
        .stream(primaryKey: ["id"])
        .eq("id", userId)
        .map((rows) {
      if (rows.isEmpty) {
        return null;
      }
      return ProfileModel.fromJson(_normalizeProfile(rows.first));
    });
  }

  Future<ProfileModel?> getProfile(String uid) async {
    final data = await _client
        .from("profiles")
        .select()
        .eq("id", uid)
        .maybeSingle();
    if (data == null) {
      return null;
    }
    return ProfileModel.fromJson(_normalizeProfile(data));
  }

  Future<void> addQuizz(QuizzModel quizzModel, {String? uid}) async {
    final userId = _requiredUid(uid);
    await _client.from("quizzes").insert({
      "user_id": userId,
      "quiz": quizzModel.quizz,
      "quiz_answer": quizzModel.quizzanswer,
    });
  }

  Future<List<QuizzModel>> getQuizzes({String? uid}) async {
    final userId = _requiredUid(uid);
    final rows = await _client
        .from("quizzes")
        .select()
        .eq("user_id", userId)
        .order("created_at");

    return rows.map((row) => QuizzModel.fromJson(_normalizeQuiz(row))).toList();
  }

  Future<void> addNote({
    required String input,
    required String generatedNote,
    String? uid,
  }) async {
    final userId = _requiredUid(uid);
    await _client.from("notes").insert({
      "user_id": userId,
      "input": input,
      "generated_note": generatedNote,
    });
  }

  Stream<List<Map<String, dynamic>>> notesStream({String? uid}) {
    final userId = _requiredUid(uid);
    return _client
        .from("notes")
        .stream(primaryKey: ["id"])
        .eq("user_id", userId)
        .order("created_at", ascending: false)
        .map((rows) => rows.map(_normalizeNote).toList());
  }

  Future<void> deleteNote(String noteId) async {
    await _client.from("notes").delete().eq("id", noteId);
  }

  Future<void> addActivity({
    required String title,
    required String subtitle,
    String? uid,
  }) async {
    final userId = _requiredUid(uid);
    await _client.from("activity").insert({
      "user_id": userId,
      "title": title,
      "subtitle": subtitle,
    });
  }

  Stream<List<Map<String, dynamic>>> activityStream({String? uid}) {
    final userId = _requiredUid(uid);
    return _client
        .from("activity")
        .stream(primaryKey: ["id"])
        .eq("user_id", userId)
        .order("created_at", ascending: false)
        .limit(10)
        .map((rows) => rows.map(_normalizeActivity).toList());
  }

  Map<String, dynamic> _normalizeUser(Map<String, dynamic> row) {
    return {
      "uId": row["id"] as String? ?? "",
      "userName": row["user_name"] as String? ?? "",
      "email": row["email"] as String? ?? "",
    };
  }

  Map<String, dynamic> _normalizeMessage(Map<String, dynamic> row) {
    return {
      "messageId": row["id"]?.toString() ?? "",
      "senderId": row["sender_id"] as String? ?? "",
      "receiverId": row["receiver_id"] as String? ?? "",
      "message": row["message"] as String? ?? "",
    };
  }

  Map<String, dynamic> _normalizeFlashcard(Map<String, dynamic> row) {
    return {
      "cardId": row["id"]?.toString() ?? "",
      "cardQues": row["question"] as String? ?? "",
      "cardAns": row["answer"] as String? ?? "",
    };
  }

  Map<String, dynamic> _normalizeProfile(Map<String, dynamic> row) {
    return {
      "uid": row["id"] as String? ?? "",
      "name": row["name"] as String? ?? "",
      "email": row["email"] as String? ?? "",
      "streakDays": row["streak_days"] as int? ?? 0,
      "dailyGoalMinutes": row["daily_goal_minutes"] as int? ?? 30,
      "completedMinutes": row["completed_minutes"] as int? ?? 0,
      "testsTaken": row["tests_taken"] as int? ?? 0,
      "studyHours": row["study_hours"] as int? ?? 0,
    };
  }

  Map<String, dynamic> _normalizeQuiz(Map<String, dynamic> row) {
    return {
      "quizzId": row["id"]?.toString() ?? "",
      "quizz": row["quiz"] as String? ?? "",
      "quizzanswer": row["quiz_answer"] as String? ?? "",
    };
  }

  Map<String, dynamic> _normalizeNote(Map<String, dynamic> row) {
    return {
      "noteId": row["id"]?.toString() ?? "",
      "input": row["input"] as String? ?? "",
      "generatedNote": row["generated_note"] as String? ?? "",
      "createdAt": row["created_at"]?.toString() ?? "",
    };
  }

  Map<String, dynamic> _normalizeActivity(Map<String, dynamic> row) {
    return {
      "activityId": row["id"]?.toString() ?? "",
      "title": row["title"] as String? ?? "",
      "subtitle": row["subtitle"] as String? ?? "",
    };
  }

  Map<String, dynamic> _profileUpdateToSupabase(Map<String, dynamic> data) {
    final mapped = <String, dynamic>{};
    if (data.containsKey("name")) {
      mapped["name"] = data["name"];
    }
    if (data.containsKey("email")) {
      mapped["email"] = data["email"];
    }
    if (data.containsKey("streakDays")) {
      mapped["streak_days"] = data["streakDays"];
    }
    if (data.containsKey("dailyGoalMinutes")) {
      mapped["daily_goal_minutes"] = data["dailyGoalMinutes"];
    }
    if (data.containsKey("completedMinutes")) {
      mapped["completed_minutes"] = data["completedMinutes"];
    }
    if (data.containsKey("testsTaken")) {
      mapped["tests_taken"] = data["testsTaken"];
    }
    if (data.containsKey("studyHours")) {
      mapped["study_hours"] = data["studyHours"];
    }
    return mapped;
  }
}
