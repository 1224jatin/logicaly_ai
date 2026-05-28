import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

class StorageService {
  final SupabaseClient _client = Supabase.instance.client;

  String? get currentUid => _client.auth.currentUser?.id;

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
    final path = "users/$uid/$folder/$safeName";
    await _client.storage.from("user-files").upload(path, file);
    return _client.storage.from("user-files").getPublicUrl(path);
  }

  Future<void> deleteByUrl(String downloadUrl) async {
    final marker = "/storage/v1/object/public/user-files/";
    final markerIndex = downloadUrl.indexOf(marker);
    if (markerIndex == -1) {
      return;
    }

    final path = Uri.decodeComponent(
      downloadUrl.substring(markerIndex + marker.length),
    );
    await _client.storage.from("user-files").remove([path]);
  }
}
