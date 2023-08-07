import 'package:butler/models/news_model.dart';
import 'package:butler/models/user_model.dart';
import 'package:butler/services/firebase/firestore_path.dart';
import 'package:butler/services/firebase/firestore_service.dart';
import 'package:uuid/uuid.dart';

String documentIdFromCurrentDate() => const Uuid().v1();

class FirestoreDatabase {
  final _firestoreService = FirestoreService.instance;
  FirestoreDatabase();
  // Method to add new user or update userData
  // Future<void> test(Map<String, dynamic> data) async =>
  //     await _firestoreService.setData(
  //       path: FirestorePath.test(),
  //       data: data,
  //     );

  // Method to add new user or update userData
  Future<void> distributedCounter(String path, String field) async =>
      await _firestoreService.distributedCounterService(
          path: path, field: field);

  //* =======================>  On users Info Methods  <====================================================================================

  // Method to get user data
  Stream<UserModel?> getCurrentUserData(String uid) =>
      _firestoreService.userDataStream(
          path: FirestorePath.newUser(uid),
          builder: (userData, id) {
            return UserModel.fromMap(userData);
          });
  // Method to get userData
  Future<UserModel?> getUserData(String userId) =>
      _firestoreService.userDataFuture(
          path: "users/$userId",
          builder: (userData, id) {
            return UserModel.fromMap(userData);
          });
  // Method to add new user or update userData
  Future<void> setNewUserData(UserModel userData, String newuid) async =>
      await _firestoreService.setData(
        path: FirestorePath.newUser(newuid),
        data: userData.toMap(),
      );
  // Method to  update current user data
  Future<void> updateUserData(
          String uid, Map<String, dynamic> dataToUpdate) async =>
      await _firestoreService.updateUserDataService(
        path: FirestorePath.newUser(uid),
        data: dataToUpdate,
      );
  // Method to verify if user exist ==> used before google or facebook login
  Future<bool> ifUserExist(String newuid) async =>
      await _firestoreService.verifyIfUserExist(
        path: FirestorePath.verifyUser(newuid),
      );
  //

  Future<void> uploadNews(NewsModel newsModel) async =>
      await _firestoreService.setData(
          path: FirestorePath.news(const Uuid().v1()), data: newsModel.toMap());
  //

  // Method to get news
  Future<List<NewsModel>?> getAllNews() => _firestoreService.getCollection(
        path: "news",
        builder: (data, documentId) => NewsModel.fromMap(data, documentId),
      );
}
