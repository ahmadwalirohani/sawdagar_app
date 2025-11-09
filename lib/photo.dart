import 'package:afghan_bazar/models/gallery_model.dart';

class Photo {
  Photo({required this.data});

  Photo.fromJson(dynamic json) {
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data.add(GalleryModel.fromJson(v));
      });
    }
  }
  late List<GalleryModel> data;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['data'] = data.map((v) => v.toJson()).toList();
    return map;
  }
}
