import 'package:butler/ui/firebase/firestore_path.dart';
import 'package:butler/ui/firebase/firestore_service.dart';
import 'package:uuid/uuid.dart';

String documentIdFromCurrentDate() => const Uuid().v1();

class FirestoreDatabase {
  final _firestoreService = FirestoreService.instance;
  FirestoreDatabase();
  // Method to add new user or update userData
  Future<void> test(Map<String, dynamic> data) async =>
      await _firestoreService.setData(
        path: FirestorePath.test(),
        data: data,
      );
}
