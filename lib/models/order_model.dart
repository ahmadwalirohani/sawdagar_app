class OrderModel {
  int id;
  int buyerId;
  int adId;
  String status;
  double price;
  double shippingCost;
  double totalAmount;
  int quantity;
  String createdAt;

  // New product ad fields (related to the ad)
  String? adTitle;
  String? adDescription;
  String? adPrice;
  String? adCurrency;
  String? adCategory;
  List<String?>? adPhotos;

  OrderModel({
    required this.id,
    required this.buyerId,
    required this.adId,
    this.status = 'processing',
    this.price = 0.0,
    this.shippingCost = 0.0,
    this.totalAmount = 0.0,
    this.quantity = 1,
    required this.createdAt,

    // New product ad fields
    this.adTitle,
    this.adDescription,
    this.adPrice,
    this.adCurrency,
    this.adCategory,
    this.adPhotos,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'],
      buyerId: json['buyer_id'],
      adId: json['ad_id'],
      status: json['status'] ?? 'processing',
      price: double.tryParse(json['price'] ?? '0') ?? 0.0,
      shippingCost: double.tryParse(json['shipping_cost'] ?? '0') ?? 0.0,
      totalAmount: double.tryParse(json['total_amount'] ?? '0') ?? 0.0,
      quantity: json['quantity'] ?? 1,
      createdAt: json['created_at'],

      // New product ad fields
      adTitle: json['ad_title'],
      adDescription: json['ad_description'],
      adPrice: json['ad_price'],
      adCurrency: json['ad_currency'],
      adCategory: json['ad_category'],
      adPhotos: json['ad_photos'] != null
          ? List<String>.from(json['ad_photos'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'buyer_id': buyerId,
      'ad_id': adId,
      'status': status,
      'price': price.toString(),
      'shipping_cost': shippingCost.toString(),
      'total_amount': totalAmount.toString(),
      'quantity': quantity,
      'created_at': createdAt,

      // New product ad fields
      'ad_title': adTitle,
      'ad_description': adDescription,
      'ad_price': adPrice,
      'ad_currency': adCurrency,
      'ad_category': adCategory,
      'ad_photos': adPhotos,
    };
  }
}
