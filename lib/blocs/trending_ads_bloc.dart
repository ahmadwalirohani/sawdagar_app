import 'dart:convert'; // Import this for json.decode
import 'package:afghan_bazar/models/product_ads_model.dart';
import 'package:afghan_bazar/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:afghan_bazar/collections/product_ads_collection.dart';
import 'package:afghan_bazar/services/auth_service.dart';

class TrendingAdsBloc with ChangeNotifier {
  final Map<String, List<ProductAdsModel>> _adsByCategory = {};
  bool _hasData = true;
  bool get hasData => _hasData;

  List<ProductAdsModel> getAds(String category) {
    return _adsByCategory[category] ?? [];
  }

  Future<void> getData({required String category}) async {
    try {
      var response = await AuthService().authGet('trending-ads/$category');

      if (response.statusCode == 200 || response.statusCode == 201) {
        List<dynamic> jsonList = json.decode(response.body);
        ProductAdsCollection data = ProductAdsCollection.fromJson(jsonList);

        _adsByCategory[category] = data.ads;
        _hasData = data.ads.isNotEmpty;
      } else {
        throw Exception(
          'Failed to load $category ads. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error fetching $category ads: $e');
      _hasData = false;
    }

    notifyListeners();
  }

  Future<void> toggleFavorite(
    ProductAdsModel product, {
    VoidCallback? onUnauthorized,
  }) async {
    try {
      final statusCode = await ApiService.addOrRemoveFavorite(product.id);

      if (statusCode == 401) {
        // Trigger the callback from the UI
        onUnauthorized?.call();
        return;
      }

      product.isFavorite = !product.isFavorite;
      notifyListeners();
    } catch (e) {
      debugPrint("Favorite toggle failed: $e");
    }
  }

  void onRefresh(String category) {
    _adsByCategory[category] = [];
    _hasData = true;
    getData(category: category);
    notifyListeners();
  }
}
