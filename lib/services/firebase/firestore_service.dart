import 'package:butler/services/firebase/distributed_counter.dart';
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

  Future<void> distributedCounterService(
      {required String path, required String field}) async {
    await FirebaseFirestore.instance.doc(path).get().then((doc) async {
      if (doc.exists) {
        DistributedCounter(FirebaseFirestore.instance.doc(path), field)
            .incrementBy(1);
      }
    });
  }

  //* =======================>    Methods  <====================================================================================

  // Method to delete data
  Future<void> deleteData({required String path}) async {
    final reference = FirebaseFirestore.instance.doc(path);
    await reference.delete();
  }

  // Method to strem collection
  Stream<List<T>> collectionStream<T>({
    required String? path,
    required T Function(Map<String, dynamic> data, String documentID) builder,
    Query Function(Query query)? queryBuilder,
    int Function(T lhs, T rhs)? sort,
  }) {
    Query query = FirebaseFirestore.instance.collection(path!);
    if (queryBuilder != null) {
      query = queryBuilder(query);
    }
    final Stream<QuerySnapshot> snapshots = query.snapshots();
    return snapshots.map((snapshot) {
      final result = snapshot.docs
          .map((snapshot) =>
              builder(snapshot.data() as Map<String, dynamic>, snapshot.id))
          .where((value) => value != null)
          .toList();
      if (sort != null) {
        result.sort(sort);
      }
      return result;
    });
  }

// Method to document collection
  Stream<T> documentStream<T>({
    required String? path,
    required T Function(Map<String, dynamic> data, String documentID) builder,
  }) {
    final DocumentReference reference = FirebaseFirestore.instance.doc(path!);
    final Stream<DocumentSnapshot> snapshots = reference.snapshots();
    return snapshots.map((snapshot) =>
        builder(snapshot.data() as Map<String, dynamic>, snapshot.id));
  }

  //* =======================>    On Users  <====================================================================================

  // Method to strem UserData
  Stream<T?> userDataStream<T>({
    required String path,
    required T Function(Map<String, dynamic> data, String documentID) builder,
  }) {
    final DocumentReference reference = FirebaseFirestore.instance.doc(path);
    final Stream<DocumentSnapshot> snapshots = reference.snapshots();
    return snapshots.map((snapshot) => snapshot.data() != null
        ? builder(snapshot.data() as Map<String, dynamic>, snapshot.id)
        : null);
  }

  // Method to get UserData
  Future<T?> userDataFuture<T>({
    required String path,
    required T Function(Map<String, dynamic> data, String documentID) builder,
  }) async {
    final DocumentReference reference = FirebaseFirestore.instance.doc(path);
    final DocumentSnapshot query = await reference.get();
    return query.data() != null
        ? builder(query.data() as Map<String, dynamic>, query.id)
        : null;
  }

  // Method to update UserData
  Future<void> updateUserDataService({
    required String path,
    required Map<String, dynamic> data,
    bool merge = false,
  }) async {
    FirebaseFirestore.instance.doc(path).update(data);
  }

  // Method to verify if user exist
  Future<bool> verifyIfUserExist({required String path}) async {
    final reference = FirebaseFirestore.instance.doc(path);
    final data = await reference.get();

    if (data.data() == null) {
      return false;
    } else {
      return true;
    }
  }

  //
  // Method to get collection documents
  Future<List<T>> getCollection<T>({
    required String? path,
    required T Function(Map<String, dynamic> data, String documentID) builder,
    Query Function(Query query)? queryBuilder,
    int Function(T lhs, T rhs)? sort,
  }) {
    Query query = FirebaseFirestore.instance.collection(path!);
    if (queryBuilder != null) {
      query = queryBuilder(query);
    }
    final Future<QuerySnapshot> snapshots = query.get();

    return snapshots.then((snapshot) {
      final result = snapshot.docs
          .map((snapshot) =>
              builder(snapshot.data() as Map<String, dynamic>, snapshot.id))
          .where((value) => value != null)
          .toList();
      if (sort != null) {
        result.sort(sort);
      }
      return result;
    });
  }
}
