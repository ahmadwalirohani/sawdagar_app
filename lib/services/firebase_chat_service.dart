import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:afghan_bazar/models/chat_session_model.dart';
import 'package:afghan_bazar/models/firebase_message_model.dart';

class FirebaseChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Convert your session to Firebase chat room
  Future<void> initializeChatSession(ChatSessionModel session) async {
    final roomId = session.sessionId ?? 'chat_${session.chatId}';

    final roomDoc = await _firestore
        .collection('chatSessions')
        .doc(roomId)
        .get();

    if (!roomDoc.exists) {
      await _firestore.collection('chatSessions').doc(roomId).set({
        'chatId': session.chatId,
        'sessionId': roomId,
        'sessionToken': session.sessionToken,
        'type': session.type,
        'participants': {
          session.partnerId: {
            'name': session.partnerName,
            'email': session.partnerEmail,
            'avatar': session.partnerAvatar,
          },
          // You'll need to add current user ID here from your auth
        },
        'adInfo': {
          'adId': session.adId,
          'adTitle': session.adTitle,
          'adPrice': session.adPrice,
          'adPhoto': session.adPhoto,
        },
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'lastMessage': null,
        'lastUpdated': DateTime.now().millisecondsSinceEpoch,
      });
    }
  }

  // Send a message
  Future<void> sendMessage({
    required String sessionId,
    required int senderId,
    required String senderName,
    required String content,
    String? senderAvatar,
    String messageType = 'text',
    String? mediaUrl,
  }) async {
    final message = FirebaseMessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      chatSessionId: sessionId,
      senderId: senderId,
      senderName: senderName,
      senderAvatar: senderAvatar,
      content: content,
      messageType: messageType,
      timestamp: DateTime.now(),
      mediaUrl: mediaUrl,
    );

    final batch = _firestore.batch();

    // Add message to subcollection
    final messageRef = _firestore
        .collection('chatSessions')
        .doc(sessionId)
        .collection('messages')
        .doc(message.id);
    batch.set(messageRef, message.toMap());

    // Update last message in chat session
    final sessionRef = _firestore.collection('chatSessions').doc(sessionId);
    batch.update(sessionRef, {
      'lastMessage': message.toMap(),
      'lastUpdated': DateTime.now().millisecondsSinceEpoch,
    });

    await batch.commit();
  }

  // Get real-time messages for a session
  Stream<List<FirebaseMessageModel>> getMessages(String sessionId) {
    return _firestore
        .collection('chatSessions')
        .doc(sessionId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => FirebaseMessageModel.fromMap(doc.data()))
              .toList(),
        );
  }

  // Get real-time chat sessions with last messages
  Stream<List<Map<String, dynamic>>> getChatSessions(int userId) {
    return _firestore
        .collection('chatSessions')
        .where('participants.$userId', isNull: false)
        .orderBy('lastUpdated', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) {
            final data = doc.data();
            return {
              'sessionData': data,
              'lastMessage': data['lastMessage'] != null
                  ? FirebaseMessageModel.fromMap(data['lastMessage'])
                  : null,
            };
          }).toList(),
        );
  }

  // Mark messages as read
  Future<void> markMessagesAsRead(String sessionId, int userId) async {
    final messages = await _firestore
        .collection('chatSessions')
        .doc(sessionId)
        .collection('messages')
        .where('senderId', isNotEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .get();

    final batch = _firestore.batch();

    for (final doc in messages.docs) {
      batch.update(doc.reference, {'isRead': true});
    }

    if (messages.docs.isNotEmpty) {
      await batch.commit();
    }
  }

  // Get unread message count for a session
  Stream<int> getUnreadCount(String sessionId, int userId) {
    return _firestore
        .collection('chatSessions')
        .doc(sessionId)
        .collection('messages')
        .where('senderId', isNotEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }
}
