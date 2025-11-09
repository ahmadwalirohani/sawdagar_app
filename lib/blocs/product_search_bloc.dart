import 'dart:convert'; // Import this for json.decode
import 'package:afghan_bazar/models/product_ads_model.dart';
import 'package:afghan_bazar/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:afghan_bazar/collections/product_ads_collection.dart';
import 'package:afghan_bazar/services/auth_service.dart';

class ProductSearchBloc with ChangeNotifier {
  List<ProductAdsModel> _ads = [];
  bool _hasData = true;
  bool _isLoading = true;
  bool get hasData => _hasData;
  bool get isLoading => _isLoading;
  int currentPage = 0;
  int _totalItems = 0;
  int get totalItems => _totalItems;

  // Filter variables
  String? category;
  String? location;
  double? priceMin;
  double? priceMax;
  String? queryText; // Text query for general search

  List<ProductAdsModel> getAds() {
    return _ads;
  }

  // Modified getData method with filters and queryText
  Future<void> getData(
    bool isScroll, {
    String? category,
    String? location,
    String? priceMin,
    String? priceMax,
    String? queryText, // Added queryText parameter
  }) async {
    if (!isScroll) {
      _ads = [];
      currentPage = 1;
    }
    try {
      // Build the query string based on the filter parameters
      Map<String, String> queryParams = {};

      if (queryText != null && queryText.isNotEmpty) {
        queryParams['query'] = queryText; // Add text query
      }
      if (category != null && category.isNotEmpty) {
        queryParams['category'] = category;
      }
      if (location != null && location.isNotEmpty) {
        queryParams['location'] = location;
      }
      if (priceMin != null && priceMin != '') {
        queryParams['priceMin'] = priceMin.toString();
      }
      if (priceMax != null && priceMax != '') {
        queryParams['priceMax'] = priceMax.toString();
      }

      if (currentPage > 0) {
        queryParams['page'] = (currentPage).toString();
      }

      // Construct the query string from the parameters
      String queryString = Uri(queryParameters: queryParams).query;
      // Make the API call with the query parameters
      var response = await AuthService().authGet('search-ads?$queryString');
      if (response.statusCode == 200 || response.statusCode == 201) {
        _isLoading = false;

        currentPage = (json.decode(response.body)['current_page'] as int) + 1;
        _totalItems = json.decode(response.body)['total_items'] as int;
        List<dynamic> jsonList = json.decode(response.body)['data'];
        ProductAdsCollection data = ProductAdsCollection.fromJson(jsonList);

        _ads = [..._ads, ...data.ads];
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

  void onRefresh({bool mounted = true}) {
    _ads = [];
    _hasData = false;
    currentPage = 1;
    getData(false);

    notifyListeners();
  }

  void clearData() {
    _ads = [];
    _hasData = false;
    currentPage = 1;
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
