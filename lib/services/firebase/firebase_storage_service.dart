/*
This class represent all possible CRUD operation for FirebaseStorage.
 */
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseStorageService {
  FirebaseStorageService._();
  static final instance = FirebaseStorageService._();
  final FirebaseStorage storageInstance = FirebaseStorage.instance;

  ///
  Future<String?> getDownloadUrlAndFileNameService(String filePath) async {
    Reference storageReference = FirebaseStorage.instance.ref().child(filePath);
    String? downloadURL;
    try {
      downloadURL = await storageReference.getDownloadURL();
    } catch (e) {
      downloadURL = null;
    }
    return downloadURL;
  }
}
