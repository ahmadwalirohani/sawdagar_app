class ChatSessionModel {
  final int chatId;
  final String? sessionId;
  final String? sessionToken;
  final String type;
  final bool isSender;

  // Partner (flattened)
  final int? partnerId;
  final String? partnerName;
  final String? partnerEmail;
  final String? partnerAvatar;

  // Product Ad (flattened)
  final int? adId;
  final String? adTitle;
  final String? adPrice;
  final String? adPhoto;

  final String createdAt;

  ChatSessionModel({
    required this.chatId,
    this.sessionId,
    this.sessionToken,
    required this.type,
    required this.isSender,
    this.partnerId,
    this.partnerName,
    this.partnerEmail,
    this.partnerAvatar,
    this.adId,
    this.adTitle,
    this.adPrice,
    this.adPhoto,
    required this.createdAt,
  });

  /// Factory to parse JSON data from API
  factory ChatSessionModel.fromJson(Map<String, dynamic> json) {
    return ChatSessionModel(
      chatId: json['chat_id'],
      sessionId: json['session_id'],
      sessionToken: json['session_token'],
      type: json['type'] ?? 'buyer',
      isSender: json['is_sender'] ?? false,
      partnerId: json['partner_id'],
      partnerName: json['partner_name'],
      partnerEmail: json['partner_email'],
      partnerAvatar: json['partner_avatar'],
      adId: json['ad_id'],
      adTitle: json['ad_title'],
      adPrice: json['ad_price']?.toString(),
      adPhoto: json['ad_photo'][0],
      createdAt: json['created_at'] ?? '',
    );
  }

  /// Converts object back to JSON (for caching or sending)
  Map<String, dynamic> toJson() {
    return {
      'chat_id': chatId,
      'session_id': sessionId,
      'session_token': sessionToken,
      'type': type,
      'is_sender': isSender,
      'partner_id': partnerId,
      'partner_name': partnerName,
      'partner_email': partnerEmail,
      'partner_avatar': partnerAvatar,
      'ad_id': adId,
      'ad_title': adTitle,
      'ad_price': adPrice,
      'ad_photo': adPhoto,
      'created_at': createdAt,
    };
  }
}
