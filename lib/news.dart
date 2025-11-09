import 'package:afghan_bazar/models/news_model.dart';

class News {
  News({required this.data});

  News.fromJson(dynamic json) {
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data.add(NewsModel.fromJson(v));
      });
    }
  }
  late List<NewsModel> data;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['data'] = data.map((v) => v.toJson()).toList();
    return map;
  }
}
