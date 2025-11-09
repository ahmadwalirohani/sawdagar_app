import 'package:afghan_bazar/models/article_model.dart';

class Article {
  Article({required this.data});

  Article.fromJson(dynamic json) {
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data.add(ArticleModel.fromJson(v));
      });
    }
  }
  late List<ArticleModel> data;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['data'] = data.map((v) => v.toJson()).toList();
    return map;
  }
}
