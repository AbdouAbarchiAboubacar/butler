import 'package:butler/models/news_model.dart';
import 'package:butler/models/user_model.dart';
import 'package:butler/services/firebase/firestore_path.dart';
import 'package:butler/services/firebase/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  Future<void> sendWelcomeEmail(
          Map<String, dynamic> data, String newuid) async =>
      await _firestoreService.setData(
        path: FirestorePath.wencomeEmail(newuid),
        data: data,
      );

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
  // Method to  update current user data
  Future<void> createProfilePDFDocument(User user) async =>
      await _firestoreService.createProfilePDFDocumentService(
        path: "userProfilePDF/${user.uid}",
        data: {
          "displayName": user.displayName,
          "email": user.email,
          "emailVerified": user.emailVerified,
          "photoURL": user.photoURL,
          "uid": user.uid
        },
      );
  // Method to verify if user exist ==> used before google or facebook login
  Future<bool> ifUserExist(String newuid) async =>
      await _firestoreService.verifyIfUserExist(
        path: FirestorePath.verifyUser(newuid),
      );
  // Method to verify if user exist ==> used before google or facebook login
  Future<bool> ifWelcomeEmailAlreadySend(String newuid) async =>
      await _firestoreService.verifyIfUserExist(
        path: "welcomeMail/$newuid",
      );

  //

  Future<void> uploadNews(String id, NewsModel newsModel) async {
    Map<String, dynamic> data = newsModel.toMap();
    data.addAll({'createdAt': FieldValue.serverTimestamp()});
    return await _firestoreService.setData(
        path: FirestorePath.news(id), data: data);
  }

  //

  // Method to get news
  Future<List<NewsModel>?> getAllNews() => _firestoreService.getCollection(
        path: "news",
        builder: (data, documentId) => NewsModel.fromMap(data),
      );
  // Method to get news
  Future<List<NewsModel>?> getFoundedNewsBySearch(List<String> paths) =>
      _firestoreService.getDocumentsByPaths(
        paths: paths,
        builder: (data) => NewsModel.fromMap(data),
      );
  //
  Future<void> initPublicContact(String uid, Map<String, dynamic> data) async =>
      await _firestoreService.setData(path: "/publicContacts/$uid", data: data);
}
