import 'dart:io';
import 'package:butler/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseUseEmulator {
  final localHostString = Platform.isAndroid ? locaHostAddress : 'localhost';
  FirebaseUseEmulator() {
    initializeFirebaseServices();
    connectToFirebaseAuthEmulator();
    connectToFirebaseFirestoreEmulator();
    connectToFirebaseDatabaseEmulator();
    connectToFirebaseStorageEmulator();
    initialAnalytic();
  }

  Future<void> initializeFirebaseServices() async {}

  void connectToFirebaseFirestoreEmulator() {
    FirebaseFirestore.instance.useFirestoreEmulator(localHostString, 8080);
  }

  void connectToFirebaseAuthEmulator() {
    FirebaseAuth.instance.useAuthEmulator(localHostString, 9099);
  }

  void connectToFirebaseStorageEmulator() {
    FirebaseStorage.instance.useStorageEmulator(
      localHostString,
      9199,
    );
  }

  void connectToFirebaseDatabaseEmulator() {
    FirebaseDatabase.instance.useDatabaseEmulator(localHostString, 9000);
  }

  void initialAnalytic() async {
    bool supported = await FirebaseAnalytics.instance.isSupported();
    if (supported) {
      await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
      if (!FirebaseAnalytics.instance.app.isAutomaticDataCollectionEnabled) {
        await FirebaseAnalytics.instance.app
            .setAutomaticDataCollectionEnabled(true);
      }
    }
  }
}
