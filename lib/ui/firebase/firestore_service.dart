import 'package:cloud_firestore/cloud_firestore.dart';

/*
This class represent all possible CRUD operation for Firestore.
It contains all generic implementation needed based on the provided document
path and documentID,since most of the time in Firestore design, we will have
documentID and path for any document and collections.
 */

var firestoreServerTimestamp = FieldValue.serverTimestamp();

class FirestoreService {
  FirestoreService._();
  static final instance = FirestoreService._();
  // Method to set data
  Future<void> setData({
    required String path,
    required Map<String, dynamic> data,
    bool merge = false,
  }) async {
    final reference = FirebaseFirestore.instance.doc(path);
    await reference.set(data).then((value) {
      print("//? ==> success");
    });
  }
}
