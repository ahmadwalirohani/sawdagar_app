class GalleryModel {
  String? title;
  String? caption;
  String? createdAt;
  String? photographer;
  String? imageURL;
  String? location;
  String? user_name;

  GalleryModel(
      {this.title,
      this.location,
      this.imageURL,
      this.caption,
      this.createdAt,
      this.photographer,
      this.user_name});
  GalleryModel.fromJson(dynamic json) {
    title = json['title'];
    location = json['location'];
    imageURL = json['image'];
    caption = json['caption'];
    photographer = json['photographer'].toString();
    createdAt = json['created_at'];
    user_name = json['user'];
  }
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    //map['id'] = url;
    map['title'] = title;
    map['imageURL'] = imageURL;
    map['location'] = location;
    map['caption'] = caption;
    map['created_at'] = createdAt;
    map['user'] = user_name;
    map['photographer'] = photographer;

    return map;
  }
}
