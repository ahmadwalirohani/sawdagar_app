class VideoModel {
  String? title;
  String? video_type;
  String? createdAt;
  String? views;
  String? imageURL;
  String? content;
  String? user_name;
  String? video_link;

  VideoModel(
      {this.title,
      this.content,
      this.imageURL,
      this.video_type,
      this.createdAt,
      this.views,
      this.user_name,
      this.video_link});
  VideoModel.fromJson(dynamic json) {
    title = json['title'];
    content = json['content'];
    video_link = json['video_id'];
    imageURL = json['image'];
    video_type = json['video_type'];
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
    map['video_type'] = video_type;
    map['created_at'] = createdAt;
    map['user'] = user_name;
    map['views'] = views;
    map['video_link'] = video_link;

    return map;
  }
}
