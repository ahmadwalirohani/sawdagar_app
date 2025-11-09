import  'package:flutter/material.dart';
import 'package:afghan_bazar/models/news_model.dart';
import 'package:afghan_bazar/news.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart' as dio;

class SearchBloc with ChangeNotifier {
  SearchBloc() {
    getRecentSearchList();
  }

  List<String> _recentSearchData = [];
  List<String> get recentSearchData => _recentSearchData;

  String _searchText = '';
  String get searchText => _searchText;

  final _locales = {'en': 1, 'ps': 2, 'fa': 3, 'ar': 4};

  bool _searchStarted = false;
  bool get searchStarted => _searchStarted;

  final TextEditingController _textFieldCtrl = TextEditingController();
  TextEditingController get textfieldCtrl => _textFieldCtrl;
  //final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future getRecentSearchList() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    _recentSearchData = sp.getStringList('recent_search_data') ?? [];
    notifyListeners();
  }

  Future addToSearchList(String value) async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    _recentSearchData.add(value);
    await sp.setStringList('recent_search_data', _recentSearchData);
    notifyListeners();
  }

  Future removeFromSearchList(String value) async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    _recentSearchData.remove(value);
    await sp.setStringList('recent_search_data', _recentSearchData);
    notifyListeners();
  }

  Future<List> getData(Locale localeLang) async {
    List<NewsModel> data = [];
    // QuerySnapshot rawData = await firestore
    //     .collection('contents')
    //     .orderBy('timestamp', descending: true)
    //     .get();

    // List<DocumentSnapshot> _snap = [];
    // _snap.addAll(rawData.docs.where((u) => (u['title']
    //         .toLowerCase()
    //         .contains(_searchText.toLowerCase()) ||
    //     u['category'].toLowerCase().contains(_searchText.toLowerCase()) ||
    //     u['description'].toLowerCase().contains(_searchText.toLowerCase()))));
    // data = _snap.map((e) => Article.fromFirestore(e)).toList();
    try {
      dio.Dio dioClient = dio.Dio();

      var f = _locales[localeLang.toString()];

      final Map<String, dynamic> queryParams = {
        'query': _searchText.toLowerCase(),
        'language_id': f,
      };

      String url = "https://hurriyat.net/api/search";

      dio.Response response = await dioClient.get(
        url,
        queryParameters: queryParams,
      );

      News newresponse = News.fromJson(response.data);

      data = [...data, ...newresponse.data];
      //_isLoading = false;
      return newresponse.data;
    } on dio.DioException catch (e) {
      print("this is the main error${e.error}");
      return [];
    }
    return data;
  }

  setSearchText(value) {
    _textFieldCtrl.text = value;
    _searchText = value;
    _searchStarted = true;
    notifyListeners();
  }

  saerchInitialize() {
    _textFieldCtrl.clear();
    _searchStarted = false;
    notifyListeners();
  }
}
