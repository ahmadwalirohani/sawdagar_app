import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart' as dio;
import 'package:afghan_bazar/article.dart';
import 'package:afghan_bazar/models/article_model.dart';

class CategoryTab5Bloc extends ChangeNotifier {
  List<ArticleModel> _data = [];
  List<ArticleModel> get data => _data;
  bool _isLoading = true;
  bool get isLoading => _isLoading;

  int currentPage = 1;

  bool? _hasData;
  bool? get hasData => _hasData;

  Locale? localeLang;

  final _locales = {'en': 1, 'ps': 2, 'fa': 3, 'ar': 4};
  Future<List<ArticleModel>> _getAnalysisList(String? category) async {
    final Map<String, dynamic> queryParams = {'page': currentPage};

    try {
      dio.Dio dioClient = dio.Dio();

      var f = _locales[localeLang.toString()];

      String url = "https://hurriyat.net/api/article/$f";

      dio.Response response = await dioClient.get(
        url,
        queryParameters: queryParams,
      );

      currentPage = response.data['current_page'] as int;

      Article newresponse = Article.fromJson(response.data);

      _data = [..._data, ...newresponse.data];
      _isLoading = false;
      return newresponse.data;
    } on dio.DioException catch (e) {
      print("this is the main error${e.error}");
      return [];
    }
  }

  Future getData(
    mounted,
    String category, [
    bool isFirst = true,
    Locale? locale,
  ]) async {
    if (locale != null) {
      localeLang = locale;
    }
    if (!isFirst) {
      currentPage += 1;
    } else {
      _data.clear();
    }

    await _getAnalysisList(category);
    notifyListeners();
  }

  setLoading(bool isloading) {
    _isLoading = isloading;
    notifyListeners();
  }

  onRefresh(mounted, String category) {
    _isLoading = true;
    //_snap.clear();
    _data.clear();
    // _lastVisible = null;
    getData(mounted, category);
    notifyListeners();
  }
}
