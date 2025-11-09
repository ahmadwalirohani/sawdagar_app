import 'package:afghan_bazar/models/product_ads_model.dart';

class ProductAdsCollection {
  List<ProductAdsModel> ads;

  ProductAdsCollection({required this.ads});

  // Deserialize a JSON list into a collection of AdDetails objects
  factory ProductAdsCollection.fromJson(List<dynamic> jsonList) {
    List<ProductAdsModel> ads = jsonList
        .map((json) => ProductAdsModel.fromJson(json))
        .toList();
    return ProductAdsCollection(ads: ads);
  }

  // Serialize the collection of AdDetails objects to a JSON list
  List<Map<String, dynamic>> toJson() {
    return ads.map((ad) => ad.toJson()).toList();
  }
}
