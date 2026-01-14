import 'dart:convert'; // Import this for json.decode
import 'dart:io';
import 'package:afghan_bazar/models/product_ads_model.dart';
import 'package:flutter/material.dart';
import 'package:afghan_bazar/collections/product_ads_collection.dart';
import 'package:afghan_bazar/services/auth_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

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

  // In MyAdsBloc class

  Future<bool> deleteAd(int adId) async {
    final response = await AuthService().authPost(
      'delete-ads',
      body: jsonEncode({'ad_id': adId}),
    );

    if (response.statusCode == 200) {
      // Remove from local list
      final index = _ads.indexWhere((ad) => ad.id == adId);
      if (index != -1) {
        _ads.removeAt(index);
        notifyListeners();
      }

      return true; // Return true if successful
    } else {
      print('Error deleting Ad');
      return false;
    }
  }

  Future<bool> updateProduct(
    ProductAdsModel product, {
    List<XFile>? newImages,
    List<String>? deletedImages,
  }) async {
    try {
      // 1. Prepare the updated photos list (keep existing, remove deleted)
      List<String> updatedPhotos = List.from(product.photos ?? []);

      // Remove deleted images from the list
      if (deletedImages != null && deletedImages.isNotEmpty) {
        updatedPhotos.removeWhere((img) => deletedImages.contains(img));
      }

      // 2. Prepare multipart request
      var uri = Uri.parse(
        "${AuthService.baseUrl}/product-ads/update/${product.id}",
      );

      var request = http.MultipartRequest("POST", uri);

      // 3. Add all fields
      request.fields.addAll({
        'title': product.title,
        'price': product.price,
        'currency': product.currency,
        'category': product.category ?? '',
        'condition': product.condition,
        'description': product.description ?? '',
        'location': product.location ?? '',
        'allow_offers': product.allowOffers ? '1' : '0',
        'pickup': product.pickup ? '1' : '0',
        'delivery': product.delivery ? '1' : '0',
        'delivery_by_afghanbazaar': product.deliveryByPlatform ? '1' : '0',
        'latitude': product.latitude ?? '',
        'longitude': product.longitude ?? '',
        '_method': 'PUT',
      });

      // 4. Add available locations
      if (product.availableLocations != null &&
          product.availableLocations!.isNotEmpty) {
        request.fields['pickup_locations'] = product.availableLocations!.join(
          ',',
        );
      }

      // 5. Send existing photo URLs as fields (so backend knows to keep them)
      for (int i = 0; i < updatedPhotos.length; i++) {
        request.fields['existing_photos[$i]'] = updatedPhotos[i];
      }

      // 6. Upload NEW images only
      if (newImages != null && newImages.isNotEmpty) {
        for (int i = 0; i < newImages.length; i++) {
          final imageFile = File(newImages[i].path);
          if (await imageFile.exists()) {
            request.files.add(
              await http.MultipartFile.fromPath(
                'new_photos[$i]',
                imageFile.path,
              ),
            );
          }
        }
      }

      // 7. Send deleted image URLs so backend can remove them
      if (deletedImages != null && deletedImages.isNotEmpty) {
        for (int i = 0; i < deletedImages.length; i++) {
          request.fields['deleted_photos[$i]'] = deletedImages[i];
        }
      }

      // 8. Add video if exists
      if (product.videoPath != null && File(product.videoPath!).existsSync()) {
        request.files.add(
          await http.MultipartFile.fromPath('video', product.videoPath!),
        );
      }

      // 9. Send the request
      final response = await AuthService().authPost(
        "ads/update/${product.id}",
        body: request,
        isMultipart: true,
      );

      // 10. Handle response
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);

        // Update local list
        final index = _ads.indexWhere((ad) => ad.id == product.id);
        if (index != -1) {
          if (responseData['data'] != null) {
            final updatedProduct = ProductAdsModel.fromJson(
              responseData['data'],
            );
            _ads[index] = updatedProduct;
          } else {
            // Combine old and new images
            List<String> finalPhotos = [];
            finalPhotos.addAll(updatedPhotos); // Existing kept images

            // Add new image URLs from response if available
            if (responseData['new_images'] != null) {
              finalPhotos.addAll(List<String>.from(responseData['new_images']));
            }

            final updatedProduct = product.copyWith(photos: finalPhotos);
            _ads[index] = updatedProduct;
          }
          notifyListeners();
        }

        return true;
      } else {
        print('Failed to update product: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error updating product: $e');
      return false;
    }
  }
}
