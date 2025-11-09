import 'package:afghan_bazar/models/order_model.dart';

class OrdersCollection {
  List<OrderModel> ads;

  OrdersCollection({required this.ads});

  // Deserialize a JSON list into a collection of AdDetails objects
  factory OrdersCollection.fromJson(List<dynamic> jsonList) {
    List<OrderModel> ads = jsonList
        .map((json) => OrderModel.fromJson(json))
        .toList();
    return OrdersCollection(ads: ads);
  }

  // Serialize the collection of AdDetails objects to a JSON list
  List<Map<String, dynamic>> toJson() {
    return ads.map((ad) => ad.toJson()).toList();
  }
}
