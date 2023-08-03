import 'package:butler/ui/firebase/firebase_storage.dart';
import 'package:butler/ui/firebase/firestore_database.dart';
import 'package:butler/ui/firebase/realtime_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    //
    final firestoreDatabase = Provider.of<FirestoreDatabase>(context);
    //
    final realtimeDatabase = Provider.of<RealTimeDatabase>(context);
    //
    final firebaseFileStorage = Provider.of<FirebaseFileStorage>(context);
    //
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        actions: [
          IconButton(
              onPressed: () {
                firestoreDatabase.test({"data": "hello"});
              },
              icon: const Icon(Icons.add))
        ],
      ),
    );
  }
}
