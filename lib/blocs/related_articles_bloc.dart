import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:afghan_bazar/models/news_model.dart';
import 'package:afghan_bazar/news.dart';

class RelatedBloc extends ChangeNotifier {
  List<dynamic> _data = [];
  List<dynamic> get data => _data;

  List featuredList = [];

  final bool _hasData = true;
  bool get hasData => _hasData;

  Locale? localeLang;

  final _locales = {'en': 1, 'ps': 2, 'fa': 3, 'ar': 4};

  Future<List<NewsModel>> _getNewsList(
    String? category,
    String? timestamp,
  ) async {
    try {
      dio.Dio dioClient = dio.Dio();

      var f = _locales[localeLang.toString()];

      String url = "https://hurriyat.net/api/news/category/$category/$f";

      dio.Response response = await dioClient.get(url);
      News newresponse = News.fromJson(response.data);
      _data = newresponse.data;
      featuredList = newresponse.data;
      return newresponse.data;
    } on dio.DioException catch (e) {
      print("this is the main error${e.error}");
      return [];
    }
  }

  Future getData(String? category, String? timestamp, [Locale? locale]) async {
    if (locale != null) {
      localeLang = locale;
    }
    _data.clear();

    await _getNewsList(category, timestamp);
    notifyListeners();
  }

  onRefresh(mounted, String stateName, String timestamp) {
    _data.clear();
    getData(stateName, timestamp);
    notifyListeners();
  }
}
