/*
This class represent all possible CRUD operation for RealTimeDatabase.
 */
import 'dart:async';
import 'package:butler/models/news_model.dart';
import 'package:firebase_database/firebase_database.dart';

var realtimeServerTimestamp = ServerValue.timestamp;

class RealTimeDatabaseService {
  RealTimeDatabaseService._();
  static final instance = RealTimeDatabaseService._();
  final DatabaseReference db = FirebaseDatabase.instance.ref();

  Future<void> testLimitChildNodeService() async {
    db.child('test').push().set({"data": "value"});
  }

  Future<void> addNewsToReadListService(String uid, NewsModel news) async {
    db.child('readList').child(uid).push().set(news.toMap());
  }

  Stream<bool?> isNewsInReadListService(String uid, String newsId) {
    handleData(DatabaseEvent? event, EventSink<bool?> sink) {
      if (event != null) {
        if (event.snapshot.value != null) {
          sink.add(true);
        } else {
          sink.add(false);
        }
      } else {
        sink.add(null);
      }
    }

    final transformer = StreamTransformer<DatabaseEvent, bool?>.fromHandlers(
        handleData: handleData);
    return db
        .child("readList")
        .child(uid)
        .orderByChild("id")
        .equalTo(newsId)
        .onValue
        .transform(transformer);
  }

  Future<List<NewsModel>?> getReadListNewsServices(
      {required String uid}) async {
    List<NewsModel> readListNews = [];
    Query query = db.child("readList").child(uid);

    await query.get().then((snapshot) async {
      if (snapshot.value != null) {
        Map<dynamic, dynamic> newsMap =
            Map<dynamic, dynamic>.from(snapshot.value as Map<dynamic, dynamic>);

        for (var element in newsMap.entries) {
          NewsModel news =
              NewsModel.fromMap(Map<String?, dynamic>.from(element.value));

          readListNews.add(news);
        }
      }
    });
    return readListNews;
  }
}
