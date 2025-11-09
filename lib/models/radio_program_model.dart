class RadioProgramModel {
  String? title;
  String? host;
  String? createdAt;
  String? views;
  String? imageURL;
  String? description;
  String? user_name;
  String? video_link;

  RadioProgramModel(
      {this.title,
      this.description,
      this.imageURL,
      this.host,
      this.createdAt,
      this.views,
      this.user_name,
      this.video_link});
  RadioProgramModel.fromJson(dynamic json) {
    title = json['title'];
    description = json['description'];
    video_link = json['video_id'];
    imageURL = json['main_image'];
    host = json['host'];
    views = json['views'].toString();
    createdAt = json['created_at'];
    user_name = json['user'];
  }
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    //map['id'] = url;
    map['title'] = title;
    map['imageURL'] = imageURL;
    map['description'] = description;
    map['host'] = host;
    map['created_at'] = createdAt;
    map['user'] = user_name;
    map['views'] = views;
    map['video_link'] = video_link;

    return map;
  }
}
