import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/ai_message_model.dart';
import '../models/flashcard_model.dart';
import '../models/profile_model.dart';
import '../models/quizz_model.dart';
import '../models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  String? get currentUid => FirebaseAuth.instance.currentUser?.uid;

  DocumentReference<Map<String, dynamic>> userDoc([String? uid]) {
    final userId = uid ?? currentUid;
    if (userId == null) {
      throw StateError("No signed-in user found.");
    }
    return firestore.collection("users").doc(userId);
  }

  // =====================================================
  // ================= USER COLLECTION ===================
  // =====================================================

  Future<void> addUser(UserModel userModel) async {
    await firestore
        .collection("users")
        .doc(userModel.uId)
        .set(userModel.tojson(), SetOptions(merge: true));
  }

  Future<UserModel?> getUser(String uid) async {
    DocumentSnapshot documentSnapshot = await firestore
        .collection("users")
        .doc(uid)
        .get();

    if (documentSnapshot.exists) {
      return UserModel.fromJson(
        documentSnapshot.data() as Map<String, dynamic>,
      );
    }

    return null;
  }

  // =====================================================
  // ================= MESSAGE COLLECTION =================
  // =====================================================

  Future<void> addMessage(AiMessageModel aiMessageModel, {String? uid}) async {
    final messageId = aiMessageModel.messageId.isEmpty
        ? userDoc(uid).collection("messages").doc().id
        : aiMessageModel.messageId;

    await userDoc(uid).collection("messages").doc(messageId).set({
      ...aiMessageModel.tojson(),
      "messageId": messageId,
      "createdAt": FieldValue.serverTimestamp(),
    });
  }

  Stream<List<AiMessageModel>> messagesStream({String? uid}) {
    return userDoc(uid)
        .collection("messages")
        .orderBy("createdAt")
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => AiMessageModel.fromJson(doc.data()))
              .toList(),
        );
  }

  Future<List<AiMessageModel>> getMessages({String? uid}) async {
    QuerySnapshot querySnapshot = await userDoc(
      uid,
    ).collection("messages").orderBy("createdAt").get();

    return querySnapshot.docs.map((doc) {
      return AiMessageModel.fromJson(doc.data() as Map<String, dynamic>);
    }).toList();
  }

  // =====================================================
  // ================= FLASHCARD COLLECTION ===============
  // =====================================================

  Future<void> addFlashcard(
    FlashcardModel flashcardModel, {
    String? uid,
  }) async {
    final cardId = flashcardModel.cardId.isEmpty
        ? userDoc(uid).collection("flashcards").doc().id
        : flashcardModel.cardId;

    await userDoc(uid).collection("flashcards").doc(cardId).set({
      ...flashcardModel.tojson(),
      "cardId": cardId,
      "createdAt": FieldValue.serverTimestamp(),
    });
  }

  Stream<List<FlashcardModel>> flashcardsStream({String? uid}) {
    return userDoc(uid)
        .collection("flashcards")
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => FlashcardModel.fromJson(doc.data()))
              .toList(),
        );
  }

  Future<List<FlashcardModel>> getFlashcards({String? uid}) async {
    QuerySnapshot querySnapshot = await userDoc(
      uid,
    ).collection("flashcards").orderBy("createdAt", descending: true).get();

    return querySnapshot.docs.map((doc) {
      return FlashcardModel.fromJson(doc.data() as Map<String, dynamic>);
    }).toList();
  }

  // =====================================================
  // ================= PROFILE COLLECTION =================
  // =====================================================

  Future<void> addProfile(ProfileModel profileModel) async {
    await firestore
        .collection("profiles")
        .doc(profileModel.uid)
        .set(profileModel.toJson(), SetOptions(merge: true));

    await firestore
        .collection("users")
        .doc(profileModel.uid)
        .collection("private")
        .doc("profile")
        .set(profileModel.toJson(), SetOptions(merge: true));
  }

  Future<void> updateCurrentProfile(Map<String, dynamic> data) async {
    final uid = currentUid;
    if (uid == null) {
      throw StateError("No signed-in user found.");
    }
    await firestore
        .collection("profiles")
        .doc(uid)
        .set(data, SetOptions(merge: true));
  }

  Stream<ProfileModel?> currentProfileStream() {
    final uid = currentUid;
    if (uid == null) {
      return Stream.value(null);
    }

    return firestore.collection("profiles").doc(uid).snapshots().map((doc) {
      if (!doc.exists) {
        return null;
      }
      return ProfileModel.fromJson(doc.data()!);
    });
  }

  Future<ProfileModel?> getProfile(String uid) async {
    DocumentSnapshot documentSnapshot = await firestore
        .collection("profiles")
        .doc(uid)
        .get();

    if (documentSnapshot.exists) {
      return ProfileModel.fromJson(
        documentSnapshot.data() as Map<String, dynamic>,
      );
    }

    return null;
  }

  // =====================================================
  // ================= QUIZZ COLLECTION ===================
  // =====================================================

  Future<void> addQuizz(QuizzModel quizzModel, {String? uid}) async {
    final quizId = quizzModel.quizzId.isEmpty
        ? userDoc(uid).collection("quizzes").doc().id
        : quizzModel.quizzId;

    await userDoc(uid).collection("quizzes").doc(quizId).set({
      ...quizzModel.tojson(),
      "quizzId": quizId,
      "createdAt": FieldValue.serverTimestamp(),
    });
  }

  Future<List<QuizzModel>> getQuizzes({String? uid}) async {
    QuerySnapshot querySnapshot = await userDoc(
      uid,
    ).collection("quizzes").orderBy("createdAt").get();

    return querySnapshot.docs.map((doc) {
      return QuizzModel.fromJson(doc.data() as Map<String, dynamic>);
    }).toList();
  }

  Future<void> addNote({
    required String input,
    required String generatedNote,
    String? uid,
  }) async {
    final noteRef = userDoc(uid).collection("notes").doc();
    await noteRef.set({
      "noteId": noteRef.id,
      "input": input,
      "generatedNote": generatedNote,
      "createdAt": FieldValue.serverTimestamp(),
    });
  }

  Future<void> addActivity({
    required String title,
    required String subtitle,
    String? uid,
  }) async {
    final activityRef = userDoc(uid).collection("activity").doc();
    await activityRef.set({
      "activityId": activityRef.id,
      "title": title,
      "subtitle": subtitle,
      "createdAt": FieldValue.serverTimestamp(),
    });
  }

  Stream<List<Map<String, dynamic>>> activityStream({String? uid}) {
    return userDoc(uid)
        .collection("activity")
        .orderBy("createdAt", descending: true)
        .limit(10)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }
}
