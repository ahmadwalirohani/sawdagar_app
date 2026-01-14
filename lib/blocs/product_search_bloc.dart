import 'dart:convert';
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

  // Track current search parameters
  String? _currentCategory;
  String? _currentLocation;
  String? _currentPriceMin;
  String? _currentPriceMax;
  String? _currentQueryText;

  List<ProductAdsModel> getAds() {
    return _ads;
  }

  // Check if search parameters have changed
  bool _hasSearchChanged({
    String? category,
    String? location,
    String? priceMin,
    String? priceMax,
    String? queryText,
  }) {
    return _currentCategory != category ||
        _currentLocation != location ||
        _currentPriceMin != priceMin ||
        _currentPriceMax != priceMax ||
        _currentQueryText != queryText;
  }

  // Store current search parameters
  void _updateCurrentSearchParams({
    String? category,
    String? location,
    String? priceMin,
    String? priceMax,
    String? queryText,
  }) {
    _currentCategory = category;
    _currentLocation = location;
    _currentPriceMin = priceMin;
    _currentPriceMax = priceMax;
    _currentQueryText = queryText;
  }

  // Clear current search parameters
  void _clearCurrentSearchParams() {
    _currentCategory = null;
    _currentLocation = null;
    _currentPriceMin = null;
    _currentPriceMax = null;
    _currentQueryText = null;
  }

  // Modified getData method with filters and queryText
  Future<void> getData(
    bool isScroll, {
    String? category,
    String? location,
    String? priceMin,
    String? priceMax,
    String? queryText,
  }) async {
    // Check if this is a new search (different parameters or first page)
    final bool isNewSearch =
        !isScroll ||
        _hasSearchChanged(
          category: category,
          location: location,
          priceMin: priceMin,
          priceMax: priceMax,
          queryText: queryText,
        );

    // If it's a new search, reset everything
    if (isNewSearch) {
      _ads = [];
      currentPage = 1;
      _hasData = true;
      _isLoading = true;

      // Update current search parameters
      _updateCurrentSearchParams(
        category: category,
        location: location,
        priceMin: priceMin,
        priceMax: priceMax,
        queryText: queryText,
      );

      notifyListeners(); // Notify UI that loading has started
    } else {
      // For pagination (scrolling), increment page
      currentPage++;
    }

    try {
      // Build the query string based on the filter parameters
      Map<String, String> queryParams = {};

      if (queryText != null && queryText.isNotEmpty) {
        queryParams['query'] = queryText;
      }
      if (category != null && category.isNotEmpty) {
        queryParams['category'] = category;
      }
      if (location != null && location.isNotEmpty) {
        queryParams['location'] = location;
      }
      if (priceMin != null && priceMin.isNotEmpty) {
        queryParams['priceMin'] = priceMin;
      }
      if (priceMax != null && priceMax.isNotEmpty) {
        queryParams['priceMax'] = priceMax;
      }

      // Always include page parameter for pagination
      queryParams['page'] = currentPage.toString();

      // Construct the query string from the parameters
      String queryString = Uri(queryParameters: queryParams).query;

      // Make the API call with the query parameters
      var response = await AuthService().authGet('search-ads?$queryString');

      if (response.statusCode == 200 || response.statusCode == 201) {
        _isLoading = false;

        final responseBody = json.decode(response.body);
        currentPage = (responseBody['current_page'] as int);
        _totalItems = responseBody['total_items'] as int;

        List<dynamic> jsonList = responseBody['data'];
        ProductAdsCollection data = ProductAdsCollection.fromJson(jsonList);

        // For new search, replace ads. For pagination, append ads.
        if (isNewSearch) {
          _ads = data.ads;
        } else {
          _ads = [..._ads, ...data.ads];
        }

        _hasData = data.ads.isNotEmpty;
      } else {
        throw Exception('Failed to load ads. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching ads: $e');
      _hasData = false;
      _isLoading = false;
    }

    notifyListeners();
  }

  // Method specifically for text search (call this from your search field)
  Future<void> searchByQuery(String queryText) async {
    // Clear previous data and perform new search
    await getData(
      false, // isScroll = false for new search
      queryText: queryText,
      category: _currentCategory,
      location: _currentLocation,
      priceMin: _currentPriceMin,
      priceMax: _currentPriceMax,
    );
  }

  // Method to apply filters
  Future<void> applyFilters({
    String? category,
    String? location,
    String? priceMin,
    String? priceMax,
  }) async {
    await getData(
      false, // isScroll = false for new search
      queryText: _currentQueryText,
      category: category,
      location: location,
      priceMin: priceMin,
      priceMax: priceMax,
    );
  }

  // Clear all filters and search
  Future<void> clearSearch() async {
    _clearCurrentSearchParams();
    _ads = [];
    _hasData = true;
    _isLoading = true;
    currentPage = 1;
    notifyListeners();

    // Optionally, you can load initial data here if needed
    // await getData(false);
  }

  Future<void> toggleFavorite(
    ProductAdsModel product, {
    VoidCallback? onUnauthorized,
  }) async {
    try {
      final statusCode = await ApiService.addOrRemoveFavorite(product.id);

      if (statusCode == 401) {
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
    _clearCurrentSearchParams();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
