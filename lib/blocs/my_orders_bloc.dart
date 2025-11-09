import 'dart:convert'; // Import this for json.decode
import 'package:afghan_bazar/collections/orders_collection.dart';
import 'package:afghan_bazar/models/order_model.dart';
import 'package:flutter/material.dart';
import 'package:afghan_bazar/services/auth_service.dart';

class MyOrdersBloc with ChangeNotifier {
  List<OrderModel> _ads = [];
  bool _hasData = true;
  bool get hasData => _hasData;

  List<OrderModel> getAds() {
    return _ads;
  }

  Future<void> getData(String? status) async {
    try {
      Map<String, String> queryParams = {};

      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }

      // Construct the query string from the parameters
      String queryString = Uri(queryParameters: queryParams).query;
      // Make the API call with the query parameters
      var response = await AuthService().authGet('my-orders?$queryString');

      if (response.statusCode == 200 || response.statusCode == 201) {
        List<dynamic> jsonList = json.decode(response.body);
        OrdersCollection data = OrdersCollection.fromJson(jsonList);

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
