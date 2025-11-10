class FirebaseMessageModel {
  final String id;
  final String chatSessionId;
  final int senderId;
  final String senderName;
  final String? senderAvatar;
  final String content;
  final String messageType; // text, image, file
  final DateTime timestamp;
  final bool isRead;
  final String? mediaUrl;

  FirebaseMessageModel({
    required this.id,
    required this.chatSessionId,
    required this.senderId,
    required this.senderName,
    this.senderAvatar,
    required this.content,
    this.messageType = 'text',
    required this.timestamp,
    this.isRead = false,
    this.mediaUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'chatSessionId': chatSessionId,
      'senderId': senderId,
      'senderName': senderName,
      'senderAvatar': senderAvatar,
      'content': content,
      'messageType': messageType,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'isRead': isRead,
      'mediaUrl': mediaUrl,
    };
  }

  factory FirebaseMessageModel.fromMap(Map<String, dynamic> map) {
    return FirebaseMessageModel(
      id: map['id'],
      chatSessionId: map['chatSessionId'],
      senderId: map['senderId'],
      senderName: map['senderName'],
      senderAvatar: map['senderAvatar'],
      content: map['content'],
      messageType: map['messageType'] ?? 'text',
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
      isRead: map['isRead'] ?? false,
      mediaUrl: map['mediaUrl'],
    );
  }
}
