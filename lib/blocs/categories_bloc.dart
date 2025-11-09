import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:afghan_bazar/models/category.dart';

class CategoriesBloc extends ChangeNotifier {
  bool _isLoading = true;
  bool get isLoading => _isLoading;

  List<CategoryModel> _data = [];
  List<CategoryModel> get data => _data;

  bool? _hasData;
  bool? get hasData => _hasData;

  Future<Null> getData(mounted) async {
    _hasData = true;
    _data = [
      CategoryModel(
        name: "Afghanistan",
        thumbnailUrl: "https://hurriyat.net/10.jpg",
        timestamp: "2024-10-01T12:00:00Z",
      ),
      CategoryModel(
        name: "Asia",
        thumbnailUrl: "https://hurriyat.net/1.jpg",
        timestamp: "2024-10-02T12:00:00Z",
      ),
      CategoryModel(
        name: "World",
        thumbnailUrl: "https://hurriyat.net/2.jpg",
        timestamp: "2024-10-03T12:00:00Z",
      ),
      CategoryModel(
        name: "Politics",
        thumbnailUrl: "https://hurriyat.net/9.jpg",
        timestamp: "2024-10-04T12:00:00Z",
      ),
      CategoryModel(
        name: "Business",
        thumbnailUrl: "https://hurriyat.net/5.jpg",
        timestamp: "2024-10-05T12:00:00Z",
      ),
      CategoryModel(
        name: "Development",
        thumbnailUrl: "https://hurriyat.net/4.jpg",
        timestamp: "2024-10-06T12:00:00Z",
      ),
      CategoryModel(
        name: "Sport",
        thumbnailUrl: "https://hurriyat.net/6.jpg",
        timestamp: "2024-10-07T12:00:00Z",
      ),
      CategoryModel(
        name: "Technology",
        thumbnailUrl: "https://hurriyat.net/7.jpg",
        timestamp: "2024-10-08T12:00:00Z",
      ),
      CategoryModel(
        name: "Health",
        thumbnailUrl: "https://hurriyat.net/8.jpg",
        timestamp: "2024-10-09T12:00:00Z",
      ),
      CategoryModel(
        name: "Last Two Decades",
        thumbnailUrl: "https://hurriyat.net/11.jpg",
        timestamp: "2024-10-10T12:00:00Z",
      ),
      CategoryModel(
        name: "Islam and Culture",
        thumbnailUrl: "https://hurriyat.net/3.jpg",
        timestamp: "2024-10-11T12:00:00Z",
      ),
    ];
    notifyListeners();
    return null;
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
