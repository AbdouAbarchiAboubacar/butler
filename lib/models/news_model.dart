class NewsModel {
  final String? id, authorUid, title, content, coverImage;
  final int? views;

  NewsModel(
      {required this.authorUid,
      required this.id,
      this.title,
      this.content,
      this.coverImage,
      this.views});
  factory NewsModel.fromMap(Map<String?, dynamic> data, String? documentId) {
    String? authorUid = data['authorUid'];
    String? title = data['title'];
    String? content = data['content'];
    String? coverImage = data['coverImage'];
    int? views = data['views'];

    return NewsModel(
        id: documentId,
        authorUid: authorUid,
        title: title,
        content: content,
        views: views,
        coverImage: coverImage);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'authorUid': authorUid,
      'title': title,
      'content': content,
      'views': views ?? 0,
      'coverImage': coverImage
    };
  }
}
