//import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:afghan_bazar/models/Slider.dart';
import 'package:afghan_bazar/models/slider_model.dart';
import 'package:dio/dio.dart' as dio;

class FeaturedBloc with ChangeNotifier {
  List<dynamic> _data = [];
  List<dynamic> get data => _data;

  List featuredList = [];

  bool _hasData = true;
  bool get hasData => _hasData;

  Locale? localeLang;

  final _locales = {'en': 1, 'ps': 2, 'fa': 3, 'ar': 4};

  Future<List<SliderModel>> _getFeaturedList() async {
    try {
      dio.Dio dioClient = dio.Dio();

      var f = _locales[localeLang.toString()];
      String url = "https://hurriyat.net/api/latest-news/$f";

      dio.Response response = await dioClient.get(url);
      SliderNews newresponse = SliderNews.fromJson(response.data);
      _data = newresponse.data;
      featuredList = newresponse.data;
      return newresponse.data;
    } on dio.DioException catch (e) {
      print("this is the main error${e.error}");
      return [];
    }
  }

  Future getData([Locale? locale]) async {
    if (locale != null) {
      localeLang = locale;
    }
    await _getFeaturedList();
    _hasData = true;
    notifyListeners();

    // _getFeaturedList().then((featuredList) async {
    //   print(featuredList);
    //   // QuerySnapshot rawData;
    //   // rawData = await firestore
    //   //     .collection('contents')
    //   //     .where('timestamp', whereIn: featuredList)
    //   //     .limit(10)
    //   //     .get();

    //   // List<DocumentSnapshot> _snap = [];
    //   // _snap.addAll(rawData.docs);
    //   // _data = _snap.map((e) => Article.fromFirestore(e)).toList();
    //   // _data.sort((a, b) => b.timestamp!.compareTo(a.timestamp!));
    //   // if (_data.isEmpty) {
    //   //   _hasData = false;
    //   // } else {
    //   //   _hasData = true;
    //   // }
    //   _hasData = false;
    //   notifyListeners();
    // }).onError((error, stackTrace) {
    //   _hasData = false;
    //   notifyListeners();
    // });
  }

  onRefresh() {
    featuredList.clear();
    _data.clear();
    _hasData = true;
    getData();
    notifyListeners();
  }
}
