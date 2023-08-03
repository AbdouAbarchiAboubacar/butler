/*
This class represent all possible CRUD operation for RealTimeDatabase.
 */
import 'dart:async';
import 'package:firebase_database/firebase_database.dart';

var realtimeServerTimestamp = ServerValue.timestamp;

class RealTimeDatabaseService {
  RealTimeDatabaseService._();
  static final instance = RealTimeDatabaseService._();
  final DatabaseReference db = FirebaseDatabase.instance.ref();
}
