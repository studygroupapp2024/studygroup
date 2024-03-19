import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class Storage {
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  Future<void> uploadFile(
    String filePath,
    String fileName,
  ) async {
    File file = File(filePath);

    try {
      await _firebaseStorage.ref('chatImages/$fileName').putFile(file);
    } on FirebaseException catch (e) {
      print(e);
    }
  }
}
