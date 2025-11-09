class AnalysisModel {
  String? title;
  String? createdAt;
  String? views;
  String? imageURL;
  String? content;
  String? user_name;

  AnalysisModel(
      {this.title,
      this.content,
      this.imageURL,
      this.createdAt,
      this.views,
      this.user_name});
  AnalysisModel.fromJson(dynamic json) {
    title = json['title'];
    content = json['content'];
    imageURL = json['image'];
    views = json['views'].toString();
    createdAt = json['created_at'];
    user_name = json['user'];
  }
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    //map['id'] = url;
    map['title'] = title;
    map['imageURL'] = imageURL;
    map['content'] = content;
    map['created_at'] = createdAt;
    map['user'] = user_name;
    map['views'] = views;

    return map;
  }
}
