import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  String? get currentUid => FirebaseAuth.instance.currentUser?.uid;

  Future<String> uploadUserFile({
    required File file,
    required String folder,
    String? fileName,
  }) async {
    final uid = currentUid;
    if (uid == null) {
      throw StateError("No signed-in user found.");
    }

    final safeName =
        fileName ??
        "${DateTime.now().millisecondsSinceEpoch}_${file.path.split(Platform.pathSeparator).last}";
    final ref = _storage.ref().child("users/$uid/$folder/$safeName");
    await ref.putFile(file);
    return ref.getDownloadURL();
  }

  Future<void> deleteByUrl(String downloadUrl) async {
    await _storage.refFromURL(downloadUrl).delete();
  }
}
