import 'dart:convert'; // Import this for json.decode
import 'package:afghan_bazar/models/product_ads_model.dart';
import 'package:flutter/material.dart';
import 'package:afghan_bazar/collections/product_ads_collection.dart';
import 'package:afghan_bazar/services/auth_service.dart';

class MyAdsBloc with ChangeNotifier {
  List<ProductAdsModel> _ads = [];
  bool _hasData = true;
  bool _isLoading = true;
  bool get hasData => _hasData;
  bool get isLoading => _isLoading;

  // Filter variables
  String? status;
  double? sortBy;
  String? queryText; // Text query for general search

  List<ProductAdsModel> getAds() {
    return _ads;
  }

  // Modified getData method with filters and queryText
  Future<void> getData(
    bool isScroll, {
    String? status,
    String? sortBy,
    String? queryText, // Added queryText parameter
  }) async {
    try {
      _isLoading = true;
      // Build the query string based on the filter parameters
      Map<String, String> queryParams = {};

      if (queryText != null && queryText.isNotEmpty) {
        queryParams['query'] = queryText; // Add text query
      }
      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }
      if (sortBy != null && sortBy != '') {
        queryParams['sort_by'] = sortBy.toString();
      }

      // Construct the query string from the parameters
      String queryString = Uri(queryParameters: queryParams).query;
      // Make the API call with the query parameters
      var response = await AuthService().authGet('my-ads?$queryString');

      if (response.statusCode == 200 || response.statusCode == 201) {
        _isLoading = false;

        print(queryString);

        List<dynamic> jsonList = json.decode(response.body)['data'];
        ProductAdsCollection data = ProductAdsCollection.fromJson(jsonList);

        _ads = data.ads;
        _hasData = data.ads.isNotEmpty;
      } else {
        throw Exception('Failed to load ads. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching ads: $e');
      _hasData = false;
    } finally {
      _isLoading = false;
    }

    notifyListeners();
  }

  void onRefresh({bool mounted = true}) {
    _ads = [];
    _hasData = false;
    getData(false);

    notifyListeners();
  }

  void clearData() {
    _ads = [];
    _hasData = false;
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
