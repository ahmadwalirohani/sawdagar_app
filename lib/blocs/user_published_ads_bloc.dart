import 'dart:convert'; // Import this for json.decode
import 'package:afghan_bazar/models/product_ads_model.dart';
import 'package:flutter/material.dart';
import 'package:afghan_bazar/collections/product_ads_collection.dart';
import 'package:afghan_bazar/services/auth_service.dart';

class UserPublishedAdsBloc with ChangeNotifier {
  List<ProductAdsModel> _ads = [];
  bool _hasData = true;
  bool get hasData => _hasData;

  List<ProductAdsModel> getAds() {
    return _ads;
  }

  Future<void> getData(int id) async {
    try {
      var response = await AuthService().authGet('user-published-ads/$id');
      if (response.statusCode == 200 || response.statusCode == 201) {
        List<dynamic> jsonList = json.decode(response.body);
        ProductAdsCollection data = ProductAdsCollection.fromJson(jsonList);

        _ads = data.ads;
        _hasData = data.ads.isNotEmpty;
      } else {
        throw Exception('Failed to load ads. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching ads: $e');
      _hasData = false;
    }

    notifyListeners();
  }
}
