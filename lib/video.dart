import 'package:afghan_bazar/models/video_model.dart';

class Video {
  Video({required this.data});

  Video.fromJson(dynamic json) {
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data.add(VideoModel.fromJson(v));
      });
    }
  }
  late List<VideoModel> data;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['data'] = data.map((v) => v.toJson()).toList();
    return map;
  }
}
