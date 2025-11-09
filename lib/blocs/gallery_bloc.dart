import 'package:flutter/material.dart';
import 'package:afghan_bazar/models/gallery_model.dart';
import 'package:dio/dio.dart' as dio;
import 'package:afghan_bazar/photo.dart';

class GalleryBloc extends ChangeNotifier {
  List<GalleryModel> _data = [];
  List<GalleryModel> get data => _data;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  int currentPage = 1;

  bool? _hasData;
  bool? get hasData => _hasData;

  String _popSelection = 'recent';
  String get popupSelection => _popSelection;
  Locale? localeLang;

  final _locales = {'en': 1, 'ps': 2, 'fa': 3, 'ar': 4};

  Future<List<GalleryModel>> _getNewsList() async {
    final Map<String, dynamic> queryParams = {'page': currentPage};

    try {
      dio.Dio dioClient = dio.Dio();

      var f = _locales[localeLang.toString()];

      String url = "https://hurriyat.net/api/gallery/$f";

      dio.Response response = await dioClient.get(
        url,
        queryParameters: queryParams,
      );

      currentPage = response.data['current_page'] as int;

      Photo newresponse = Photo.fromJson(response.data);

      _data = [..._data, ...newresponse.data];
      _isLoading = false;
      return newresponse.data;
    } on dio.DioException catch (e) {
      print("this is the main error${e.error}");
      return [];
    }
  }

  Future getData(mounted, [bool isFirst = true, Locale? locale]) async {
    if (locale != null) {
      localeLang = locale;
    }
    if (!isFirst) {
      currentPage += 1;
    } else {
      _data.clear();
    }

    await _getNewsList();
    notifyListeners();
  }

  afterPopSelection(value, mounted) {
    _popSelection = value;
    onRefresh(mounted);
    notifyListeners();
  }

  setLoading(bool isloading) {
    _isLoading = isloading;
    notifyListeners();
  }

  onRefresh(mounted) {
    _isLoading = true;
    //_snap.clear();
    _data.clear();
    // _lastVisible = null;
    getData(mounted);
    notifyListeners();
  }
}
