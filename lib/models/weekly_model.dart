class WeeklyModel {
  String? title;
  late String createdAt;
  String? imageURL;
  String? content;
  String? user_name;
  String? pdfUrl;

  WeeklyModel(
      {this.title,
      this.content,
      this.imageURL,
      required this.createdAt,
      this.user_name,
      this.pdfUrl});
  WeeklyModel.fromJson(dynamic json) {
    title = json['title'];
    content = json['content'];
    pdfUrl = json['pdf'];
    imageURL = json['image'];
    createdAt = json['created_at'];
    user_name = json['user'];
  }
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['title'] = title;
    map['imageURL'] = imageURL;
    map['content'] = content;
    map['created_at'] = createdAt;
    map['user'] = user_name;
    map['pdfUrl'] = pdfUrl;

    return map;
  }
}
