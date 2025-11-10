import 'dart:async';
import 'dart:convert';
import 'package:afghan_bazar/collections/chat_session_collection.dart';
import 'package:afghan_bazar/helpers/retry-helper.dart';
import 'package:afghan_bazar/models/chat_session_model.dart';
import 'package:flutter/material.dart';
import 'package:afghan_bazar/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatSessionsBloc with ChangeNotifier {
  List<ChatSessionModel> _chats = [];
  bool _hasData = true;
  bool get hasData => _hasData;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription? _firebaseSubscription;
  String? _currentFilter;

  List<ChatSessionModel> getchats() {
    return _chats;
  }

  Future<void> getData(String? type) async {
    try {
      _currentFilter = type;

      Map<String, String> queryParams = {};
      if (type != null) {
        queryParams['type'] = type;
      }

      String queryString = Uri(queryParameters: queryParams).query;
      var response = await AuthService().authGet('chat-sessions?$queryString');

      if (response.statusCode == 200 || response.statusCode == 201) {
        List<dynamic> jsonList = json.decode(response.body);
        ChatSessionCollection data = ChatSessionCollection.fromJson(jsonList);

        _chats = data.chats;
        _hasData = data.chats.isNotEmpty;

        // Initialize Firebase sessions for all chats
        _initializeFirebaseSessions();

        // Start listening to real-time updates
        _startFirebaseListeners();
      } else {
        throw Exception('Failed to load chats. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching chats: $e');
      _hasData = false;
    }

    notifyListeners();
  }

  void _initializeFirebaseSessions() async {
    for (final chat in _chats) {
      final sessionId = chat.sessionId ?? 'chat_${chat.chatId}';

      final roomDoc = await RetryHelper.executeWithRetry(
        () => _firestore.collection('chatSessions').doc(sessionId).get(),
      );

      if (!roomDoc.exists) {
        // Get current user info
        final currentUser = AuthService.getCurrentUser;

        await _firestore.collection('chatSessions').doc(sessionId).set({
          'chatId': chat.chatId,
          'sessionId': sessionId,
          'sessionToken': chat.sessionToken,
          'type': chat.type,
          'participants': {
            currentUser?.id.toString(): {
              'name': currentUser?.name,
              'avatar': currentUser?.image,
            },
            chat.partnerId.toString(): {
              'name': chat.partnerName,
              'email': chat.partnerEmail,
              'avatar': chat.partnerAvatar,
            },
          },
          'adInfo': {
            'adId': chat.adId,
            'adTitle': chat.adTitle,
            'adPrice': chat.adPrice,
            'adPhoto': chat.adPhoto,
          },
          'createdAt': DateTime.now().millisecondsSinceEpoch,
          'lastMessage': null,
          'lastUpdated': DateTime.now().millisecondsSinceEpoch,
        });
      }
    }
  }

  void _startFirebaseListeners() async {
    // Cancel existing subscription
    _firebaseSubscription?.cancel();

    final currentUser = AuthService.getCurrentUser;

    if (currentUser == null) return;
    // Listen to all chat sessions for current user
    _firebaseSubscription = _firestore
        .collection('chatSessions')
        .where('participants.${currentUser.id}', isNull: false)
        .orderBy('lastUpdated', descending: true)
        .snapshots()
        .listen((snapshot) {
          _updateChatsWithFirebaseData(snapshot.docs);
        });
  }

  void _updateChatsWithFirebaseData(List<QueryDocumentSnapshot> firebaseDocs) {
    final updatedChats = List<ChatSessionModel>.from(_chats);

    for (final firebaseDoc in firebaseDocs) {
      final firebaseData = firebaseDoc.data() as Map<String, dynamic>;
      final sessionId = firebaseData['sessionId'];

      // Find corresponding chat in our list
      final existingChatIndex = updatedChats.indexWhere(
        (chat) => (chat.sessionId ?? 'chat_${chat.chatId}') == sessionId,
      );

      if (existingChatIndex != -1) {
        // Update last message and timestamp from Firebase
        final lastMessage = firebaseData['lastMessage'];
        if (lastMessage != null) {
          // You can update any chat properties based on Firebase data
          // For example, update the timestamp to show latest activity
          final updatedChat = updatedChats[existingChatIndex];
          // Note: You might want to add lastMessage field to your ChatSessionModel
          updatedChats[existingChatIndex] = updatedChat;
        }
      }
    }

    // Sort by last updated (from Firebase)
    updatedChats.sort((a, b) {
      final aSessionId = a.sessionId ?? 'chat_${a.chatId}';
      final bSessionId = b.sessionId ?? 'chat_${b.chatId}';

      final aDoc = firebaseDocs.firstWhere(
        (doc) =>
            (doc.data() as Map<String, dynamic>)['sessionId'] == aSessionId,
        orElse: () => firebaseDocs.first,
      );
      final bDoc = firebaseDocs.firstWhere(
        (doc) =>
            (doc.data() as Map<String, dynamic>)['sessionId'] == bSessionId,
        orElse: () => firebaseDocs.first,
      );

      final aTime = (aDoc.data() as Map<String, dynamic>)['lastUpdated'] ?? 0;
      final bTime = (bDoc.data() as Map<String, dynamic>)['lastUpdated'] ?? 0;

      return bTime.compareTo(aTime);
    });

    _chats = updatedChats;
    notifyListeners();
  }

  // Get real-time unread count for a specific chat
  Stream<int> getUnreadCountStream(ChatSessionModel chat) {
    final sessionId = chat.sessionId ?? 'chat_${chat.chatId}';
    final currentUser = AuthService.getCurrentUser;

    return _firestore
        .collection('chatSessions')
        .doc(sessionId)
        .collection('messages')
        .where('senderId', isNotEqualTo: currentUser?.id.toString())
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // Get real-time last message for a specific chat
  Stream<Map<String, dynamic>?> getLastMessageStream(ChatSessionModel chat) {
    final sessionId = chat.sessionId ?? 'chat_${chat.chatId}';

    return _firestore
        .collection('chatSessions')
        .doc(sessionId)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.data()?['lastMessage'] as Map<String, dynamic>?,
        );
  }

  // Mark messages as read
  Future<void> markMessagesAsRead(ChatSessionModel chat) async {
    final sessionId = chat.sessionId ?? 'chat_${chat.chatId}';
    final currentUser = AuthService.getCurrentUser;

    final messages = await _firestore
        .collection('chatSessions')
        .doc(sessionId)
        .collection('messages')
        .where('senderId', isNotEqualTo: currentUser?.id.toString())
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

  @override
  void dispose() {
    _firebaseSubscription?.cancel();
    super.dispose();
  }
}
