import 'package:butler/models/news_model.dart';
import 'package:butler/services/firebase/realtime_database_service.dart';

class RealTimeDatabase {
  final _realTimeDatabaseService = RealTimeDatabaseService.instance;
  RealTimeDatabase();

  Future<void> testLimitChildNode() async =>
      _realTimeDatabaseService.testLimitChildNodeService();

  //
  Future<void> addNewsToReadList(String uid, NewsModel news) async =>
      _realTimeDatabaseService.addNewsToReadListService(uid, news);

  //
  Stream<bool?> isNewsInReadList(String uid, String newsId) =>
      _realTimeDatabaseService.isNewsInReadListService(uid, newsId);
  //
  Future<List<NewsModel>?> getReadListNews(String uid) =>
      _realTimeDatabaseService.getReadListNewsServices(uid: uid);
}
