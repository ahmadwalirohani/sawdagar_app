import 'dart:convert';
import 'package:afghan_bazar/models/product_ads_model.dart';
import 'package:afghan_bazar/services/auth_service.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const baseUrl = AuthService.baseHost;

  static Future<int> addOrRemoveFavorite(int productId) async {
    final response = await AuthService().authPost(
      'favorites/toggle',
      body: jsonEncode({'productAdId': productId}),
    );

    // if (response.statusCode != 200) {
    //   throw Exception("Failed to toggle favorite");
    // }
    return response.statusCode;
  }

  static Future<List<ProductAdsModel>> fetchAds({String? category}) async {
    final url = category != null
        ? "$baseUrl/ads?category=$category"
        : "$baseUrl/ads";
    final response = await http.get(Uri.parse(url));
    final List<dynamic> jsonList = json.decode(response.body)["data"];
    return jsonList.map((e) => ProductAdsModel.fromJson(e)).toList();
  }
}
