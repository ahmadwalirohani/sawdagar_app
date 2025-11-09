class ArticleModel {
  String? title;
  String? category;
  String? createdAt;
  String? views;
  String? imageURL;
  String? content;
  String? user_name;
  String? writer;

  ArticleModel({
    this.title,
    this.content,
    this.imageURL,
    this.category,
    this.createdAt,
    this.views,
    this.user_name,
    this.writer,
  });
  ArticleModel.fromJson(dynamic json) {
    title = json['title'];
    content = json['content'];
    imageURL = json['image'];
    category = json['category_name'];
    views = json['views'].toString();
    createdAt = json['created_at'];
    user_name = json['user'];
    writer = json['writer'];
  }
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    //map['id'] = url;
    map['title'] = title;
    map['imageURL'] = imageURL;
    map['content'] = content;
    map['category'] = category;
    map['created_at'] = createdAt;
    map['user'] = user_name;
    map['views'] = views;
    map['writer'] = writer;

    return map;
  }
}
