import 'dart:convert';

class ProductAdsModel {
  int id;
  String title;
  String? description;
  String price;
  String currency;
  String status;
  String? category;
  String condition;
  List<String>? photos;
  String? videoPath;
  String? location;
  String? latitude;
  String? longitude;
  bool allowOffers;
  bool pickup;
  bool delivery;
  bool deliveryByPlatform;
  List<String>? availableLocations;
  String? createdAt;
  int userId;
  bool isFavorite;

  // New user fields
  int? activeAds;
  String? userName;
  String? userEmail;
  String? userImage;
  String? userCreatedAt;
  int? views;

  ProductAdsModel({
    required this.id,
    required this.title,
    this.description,
    this.price = '0',
    this.currency = 'AFN',
    this.status = 'active',
    this.category,
    this.condition = 'Used – Good',
    this.photos,
    this.videoPath,
    this.location,
    this.latitude,
    this.longitude,
    this.allowOffers = true,
    this.pickup = true,
    this.delivery = false,
    this.deliveryByPlatform = false,
    this.availableLocations,
    this.createdAt,
    required this.userId,
    this.isFavorite = false,

    // New user fields
    this.activeAds = 0,
    this.userName,
    this.userEmail,
    this.userImage,
    this.userCreatedAt,
    this.views,
  });

  factory ProductAdsModel.fromJson(Map<String, dynamic> json) {
    return ProductAdsModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      price: json['price'] != '0' ? json['price'] : '0',
      currency: json['currency'] ?? 'AFN',
      status: json['status'] ?? 'active',
      category: json['category'],
      condition: json['condition'] ?? 'Used – Good',
      photos: json['photos'] != null
          ? List<String>.from(jsonDecode(json['photos']))
          : null,
      videoPath: json['video_path'],
      location: json['location'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      allowOffers: json['allow_offers'] == 1 ? true : false,
      pickup: json['pickup'] == 1 ? true : false,
      delivery: json['delivery'] == 1 ? true : false,
      deliveryByPlatform: json['delivery_by_platform'] == 1 ? true : false,
      availableLocations: json['availible_locations'] != null
          ? json['availible_locations']
                .toString()
                .split(',')
                .map((e) => e.trim())
                .toList()
          : null,
      createdAt: json['created_at'],
      userId: json['user_id'],
      isFavorite: json['is_favorite'] == 1 ? true : false,

      // New user fields
      activeAds: json['active_ads'],
      userName: json['user_name'],
      userEmail: json['user_email'],
      userImage: json['user_image'],
      userCreatedAt: json['user_created_at'],
      views: json['views'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'currency': currency,
      'status': status,
      'category': category,
      'condition': condition,
      'photos': photos,
      'video_path': videoPath,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'allow_offers': allowOffers,
      'pickup': pickup,
      'delivery': delivery,
      'delivery_by_platform': deliveryByPlatform,
      'availible_locations': availableLocations,
      'created_at': createdAt,
      'user_id': userId,
      'is_favorite': isFavorite,

      // New user fields
      'active_ads': activeAds,
      'user_name': userName,
      'user_email': userEmail,
      'user_image': userImage,
      'user_created_at': userCreatedAt,
      'views': views,
    };
  }
}
