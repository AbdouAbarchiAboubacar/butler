import 'package:butler/models/user_model.dart';

class NewsModel {
  final String? id, summary, authorUid, title, text, content, coverImage;
  final int? views;

  NewsModel(
      {required this.authorUid,
      required this.id,
      this.title,
      this.content,
      this.text,
      this.summary,
      this.coverImage,
      this.views});
  factory NewsModel.fromMap(Map<String?, dynamic> data) {
    String? id = data['id'];

    String? authorUid = data['authorUid'];
    String? title = data['title'];
    String? content = data['content'];
    String? text = data['text'];
    String? coverImage = data['coverImage'];
    String? summary = data['summary'];

    int? views = data['views'];

    return NewsModel(
        id: id,
        authorUid: authorUid,
        title: title,
        content: content,
        text: text,
        summary: summary,
        views: views,
        coverImage: coverImage);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'authorUid': authorUid,
      'title': title,
      'content': content,
      'text': text,
      'summary': summary,
      'views': views ?? 0,
      'coverImage': coverImage
    };
  }
}
