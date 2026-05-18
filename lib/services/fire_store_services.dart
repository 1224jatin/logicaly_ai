import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_model.dart';
import '../models/ai_message_model.dart';
import '../models/flashcard_model.dart';
import '../models/profile_model.dart';
import '../models/quizz_model.dart';

class FirestoreService {

  // ================= FIREBASE INSTANCE =================

  FirebaseFirestore firestore =
      FirebaseFirestore.instance;

  // =====================================================
  // ================= USER COLLECTION ===================
  // =====================================================

  Future<void> addUser(UserModel userModel) async {

    await firestore
        .collection("users")
        .doc(userModel.uId)
        .set(userModel.tojson());
  }

  Future<UserModel?> getUser(String uid) async {

    DocumentSnapshot documentSnapshot =
    await firestore
        .collection("users")
        .doc(uid)
        .get();

    if (documentSnapshot.exists) {

      return UserModel.fromJson(
        documentSnapshot.data()
        as Map<String, dynamic>,
      );
    }

    return null;
  }

  // =====================================================
  // ================= MESSAGE COLLECTION =================
  // =====================================================

  Future<void> addMessage(AiMessageModel aiMessageModel) async {

    await firestore
        .collection("messages")
        .doc(aiMessageModel.messageId)
        .set(aiMessageModel.tojson());
  }

  Future<List<AiMessageModel>>
  getMessages() async {

    QuerySnapshot querySnapshot =
    await firestore
        .collection("messages")
        .get();

    return querySnapshot.docs.map((doc) {

      return AiMessageModel.fromJson(

        doc.data() as Map<String, dynamic>,
      );

    }).toList();
  }

  // =====================================================
  // ================= FLASHCARD COLLECTION ===============
  // =====================================================

  Future<void> addFlashcard(FlashcardModel flashcardModel) async {

    await firestore
        .collection("flashcards")
        .doc(flashcardModel.cardId)
        .set(flashcardModel.tojson());
  }

  Future<List<FlashcardModel>>
  getFlashcards() async {

    QuerySnapshot querySnapshot =
    await firestore
        .collection("flashcards")
        .get();

    return querySnapshot.docs.map((doc) {

      return FlashcardModel.fromJson(

        doc.data() as Map<String, dynamic>,
      );

    }).toList();
  }

  // =====================================================
  // ================= PROFILE COLLECTION =================
  // =====================================================

  Future<void> addProfile(ProfileModel profileModel) async {

    await firestore
        .collection("profiles")
        .doc(profileModel.uid)
        .set(profileModel.toJson());
  }

  Future<ProfileModel?> getProfile(
      String uid) async {

    DocumentSnapshot documentSnapshot =
    await firestore
        .collection("profiles")
        .doc(uid)
        .get();

    if (documentSnapshot.exists) {

      return ProfileModel.fromJson(
        documentSnapshot.data()
        as Map<String, dynamic>,
      );
    }

    return null;
  }

  // =====================================================
  // ================= QUIZZ COLLECTION ===================
  // =====================================================

  Future<void> addQuizz(QuizzModel quizzModel) async {

    await firestore
        .collection("quizzes")
        .doc(quizzModel.quizzId)
        .set(quizzModel.tojson());
  }

  Future<List<QuizzModel>>
  getQuizzes() async {

    QuerySnapshot querySnapshot =
    await firestore
        .collection("quizzes")
        .get();

    return querySnapshot.docs.map((doc) {

      return QuizzModel.fromJson(

        doc.data() as Map<String, dynamic>,
      );

    }).toList();
  }
}