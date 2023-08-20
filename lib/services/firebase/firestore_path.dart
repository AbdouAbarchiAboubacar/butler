/*
This class defines all the possible read/write locations from the Firestore database.
In future, any new path can be added here.
This class work together with FirestoreService and FirestoreDatabase.
 */

import 'package:uuid/uuid.dart';

String documentIdFromCurrentDate() => const Uuid().v1();

class FirestorePath {
  ///
  // static String test() => 'test/test';

  ///
  static String distributedCounter() => 'pages/page';

  ///
  static String newUser(String? uid) => 'users/$uid';
  static String wencomeEmail(String? uid) => 'welcomeMail/$uid';
  static String userPath(String? uid) => 'users/$uid';
  static String verifyUser(String uid) => 'users/$uid';

  ///
  static String news(String id) => 'news/$id';

  ///
}
