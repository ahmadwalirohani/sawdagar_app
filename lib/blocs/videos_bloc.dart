import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:afghan_bazar/models/video_model.dart';
import 'package:afghan_bazar/video.dart';
import 'package:dio/dio.dart' as dio;

class VideosBloc extends ChangeNotifier {
  List<VideoModel> _data = [];
  List<VideoModel> get data => _data;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  int currentPage = 1;

  bool? _hasData;
  bool? get hasData => _hasData;

  String _popSelection = 'recent';
  String get popupSelection => _popSelection;
  Locale? localeLang;

  final _locales = {'en': 1, 'ps': 2, 'fa': 3, 'ar': 4};

  Future<List<VideoModel>> _getNewsList(String? category) async {
    final Map<String, dynamic> queryParams = {'page': currentPage};

    try {
      dio.Dio dioClient = dio.Dio();

      var f = _locales[localeLang.toString()];

      String url = "https://hurriyat.net/api/videos/2/$f";

      dio.Response response = await dioClient.get(
        url,
        queryParameters: queryParams,
      );

      currentPage = response.data['current_page'] as int;

      Video newresponse = Video.fromJson(response.data);

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
    String orderBy, [
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

    await _getNewsList(orderBy);
    notifyListeners();
  }

  afterPopSelection(value, mounted, orderBy) {
    _popSelection = value;
    onRefresh(mounted, orderBy);
    notifyListeners();
  }

  setLoading(bool isloading) {
    _isLoading = isloading;
    notifyListeners();
  }

  onRefresh(mounted, orderBy) {
    _isLoading = true;
    //_snap.clear();
    _data.clear();
    // _lastVisible = null;
    getData(mounted, orderBy);
    notifyListeners();
  }
}
