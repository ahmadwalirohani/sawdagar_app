import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:afghan_bazar/collections/product_ads_collection.dart';
import 'package:afghan_bazar/widgets/product_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_filex/open_filex.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:afghan_bazar/models/chat_session_model.dart';
import 'package:afghan_bazar/services/auth_service.dart';

class ChatMessagingPage extends StatefulWidget {
  final ChatSessionModel chatSession;

  const ChatMessagingPage({super.key, required this.chatSession});

  @override
  State<ChatMessagingPage> createState() => _ChatMessagingPageState();
}

class _ChatMessagingPageState extends State<ChatMessagingPage> {
  final _uuid = const Uuid();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _imagePicker = ImagePicker();

  late types.User _me;
  late types.User _other;
  List<types.Message> _messages = [];
  bool _isTyping = false;
  StreamSubscription<List<types.Message>>? _messagesSubscription;
  String basehost = AuthService.baseHost;

  @override
  void initState() {
    super.initState();
    _initializeUsers();
    _initializeFirebaseSession();
    _listenToMessages();
  }

  @override
  void dispose() {
    _messagesSubscription?.cancel();
    super.dispose();
  }

  void _initializeUsers() {
    // Get current user from your auth service
    final currentUser = AuthService.getCurrentUser; // Implement this

    _me = types.User(
      id: currentUser?.id.toString() ?? '',
      firstName: currentUser?.name,
      imageUrl: currentUser?.image != null ? '${currentUser?.image}' : null,
    );

    _other = types.User(
      id: widget.chatSession.partnerId.toString(),
      firstName: widget.chatSession.partnerName ?? 'User',
      imageUrl: widget.chatSession.partnerAvatar != null
          ? '${widget.chatSession.partnerAvatar}'
          : null,
    );
  }

  Future<void> _initializeFirebaseSession() async {
    final sessionId =
        widget.chatSession.sessionId ?? 'chat_${widget.chatSession.chatId}';

    final roomDoc = await _firestore
        .collection('chatSessions')
        .doc(sessionId)
        .get();

    if (!roomDoc.exists) {
      final currentUser = AuthService.getCurrentUser;

      await _firestore.collection('chatSessions').doc(sessionId).set({
        'chatId': widget.chatSession.chatId,
        'sessionId': sessionId,
        'sessionToken': widget.chatSession.sessionToken,
        'type': widget.chatSession.type,
        'participants': {
          currentUser?.id.toString(): {
            'name': currentUser?.name,
            'avatar': currentUser?.image,
          },
          _other.id: {'name': _other.firstName, 'avatar': _other.imageUrl},
        },
        'adInfo': {
          'adId': widget.chatSession.adId,
          'adTitle': widget.chatSession.adTitle,
          'adPrice': widget.chatSession.adPrice,
          'adPhoto': widget.chatSession.adPhoto,
        },
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'lastMessage': null,
        'lastUpdated': DateTime.now().millisecondsSinceEpoch,
      });
    }
  }

  void _listenToMessages() {
    final sessionId =
        widget.chatSession.sessionId ?? 'chat_${widget.chatSession.chatId}';

    _messagesSubscription = _firestore
        .collection('chatSessions')
        .doc(sessionId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => _convertFirebaseToChatMessage(doc.data()))
              .where((message) => message != null)
              .cast<types.Message>()
              .toList(),
        )
        .listen((messages) {
          setState(() => _messages = messages);
        });
  }

  types.Message? _convertFirebaseToChatMessage(Map<String, dynamic> data) {
    try {
      final author = data['senderId'] == _me.id ? _me : _other;
      final timestamp = data['timestamp'] as int;
      final messageType = data['messageType'] ?? 'text';

      switch (messageType) {
        case 'text':
          return types.TextMessage(
            id: data['id'],
            author: author,
            createdAt: timestamp,
            text: data['content'] ?? '',
          );

        case 'image':
          return types.ImageMessage(
            id: data['id'],
            author: author,
            createdAt: timestamp,
            name: data['name'] ?? 'image',
            size: data['size'] ?? 0,
            uri: data['mediaUrl'] ?? data['uri'] ?? '',
          );

        case 'file':
          return types.FileMessage(
            id: data['id'],
            author: author,
            createdAt: timestamp,
            name: data['name'] ?? 'file',
            size: data['size'] ?? 0,
            uri: data['mediaUrl'] ?? data['uri'] ?? '',
            mimeType: data['mimeType'],
          );

        default:
          return null;
      }
    } catch (e) {
      print('Error converting message: $e');
      return null;
    }
  }

  Map<String, dynamic> _convertChatToFirebaseMessage(types.Message message) {
    final baseData = {
      'id': message.id,
      'senderId': message.author.id,
      'senderName': message.author.firstName,
      'senderAvatar': message.author.imageUrl,
      'timestamp': message.createdAt,
      'isRead': false,
    };

    if (message is types.TextMessage) {
      return {...baseData, 'content': message.text, 'messageType': 'text'};
    } else if (message is types.ImageMessage) {
      return {
        ...baseData,
        'content': 'Sent an image',
        'messageType': 'image',
        'name': message.name,
        'size': message.size,
        'mediaUrl': message.uri,
      };
    } else if (message is types.FileMessage) {
      return {
        ...baseData,
        'content': 'Sent a file',
        'messageType': 'file',
        'name': message.name,
        'size': message.size,
        'mediaUrl': message.uri,
        'mimeType': message.mimeType,
      };
    }

    return baseData;
  }

  Future<void> _sendMessage(types.Message message) async {
    final sessionId =
        widget.chatSession.sessionId ?? 'chat_${widget.chatSession.chatId}';
    final firebaseMessage = _convertChatToFirebaseMessage(message);

    final batch = _firestore.batch();

    // Add message to subcollection
    final messageRef = _firestore
        .collection('chatSessions')
        .doc(sessionId)
        .collection('messages')
        .doc(message.id);
    batch.set(messageRef, firebaseMessage);

    // Update last message in chat session
    final sessionRef = _firestore.collection('chatSessions').doc(sessionId);
    batch.update(sessionRef, {
      'lastMessage': firebaseMessage,
      'lastUpdated': DateTime.now().millisecondsSinceEpoch,
    });

    await batch.commit();
  }

  Future<void> _handleAttachmentPressed() async {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo),
              title: const Text('Photo from gallery'),
              onTap: () async {
                Navigator.pop(ctx);
                await _pickImage();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take a photo'),
              onTap: () async {
                Navigator.pop(ctx);
                await _pickImage(fromCamera: true);
              },
            ),
            ListTile(
              leading: const Icon(Icons.attach_file),
              title: const Text('File (PDF/Doc/etc.)'),
              onTap: () async {
                Navigator.pop(ctx);
                await _pickFile();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage({bool fromCamera = false}) async {
    final XFile? picked = await _imagePicker.pickImage(
      source: fromCamera ? ImageSource.camera : ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1600,
    );
    if (picked == null) return;

    final file = File(picked.path);
    final size = await file.length();

    final message = types.ImageMessage(
      id: _uuid.v4(),
      author: _me,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      name: picked.name,
      size: size,
      uri: picked.path, // For local display
    );

    // Upload file to Firebase Storage first, then send message
    // For now, we'll send local path (you should implement Firebase Storage upload)
    await _sendMessage(message);
  }

  Future<void> _pickFile() async {
    final res = await FilePicker.platform.pickFiles();
    if (res == null || res.files.isEmpty) return;

    final f = res.files.single;
    final message = types.FileMessage(
      id: _uuid.v4(),
      author: _me,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      name: f.name,
      size: f.size,
      uri: f.path ?? '',
      mimeType: f.extension,
    );

    await _sendMessage(message);
  }

  void _onSendPressed(types.PartialText partial) {
    final message = types.TextMessage(
      id: _uuid.v4(),
      author: _me,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      text: partial.text.trim(),
    );

    _sendMessage(message);
  }

  void _onMessageTap(BuildContext context, types.Message message) async {
    if (message is types.FileMessage || message is types.ImageMessage) {
      final uri = (message is types.FileMessage)
          ? message.uri
          : (message as types.ImageMessage).uri;

      if (uri.startsWith('http')) {
        // Open network URL in browser/download
        // You can use url_launcher package
      } else if (await File(uri).exists()) {
        // Open local file
        await OpenFilex.open(uri);
      }
    }
  }

  void _onPreviewDataFetched(
    types.TextMessage message,
    types.PreviewData data,
  ) {
    final index = _messages.indexWhere((m) => m.id == message.id);
    if (index != -1) {
      final updated = (message).copyWith(previewData: data);
      setState(() => _messages[index] = updated);
    }
  }

  void _onProduct(int id) async {
    try {
      var response = await AuthService().authGet('ads-details?ad_id=$id');

      if (response.statusCode == 200 || response.statusCode == 201) {
        List<dynamic> jsonList = json.decode(response.body);

        ProductAdsCollection data = ProductAdsCollection.fromJson(jsonList);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetails(product: data.ads[0]),
          ),
        );
      } else {
        throw Exception('Failed to load ads. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching ads: $e');
    }
  }

  String _getLastSeenText() {
    // Implement your last seen logic here
    return "Last active 7 hours ago";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            automaticallyImplyLeading: false,
            leadingWidth: 40,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
            titleSpacing: 0,
            title: Row(
              children: [
                Container(
                  height: 45,
                  width: 45,
                  margin: const EdgeInsets.only(left: 4, right: 10),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(
                      _other.imageUrl ?? 'https://i.pravatar.cc/300',
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _other.firstName ?? "User",
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _getLastSeenText(),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              PopupMenuButton<int>(
                icon: const Icon(Icons.more_vert, color: Colors.black),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                color: Colors.white,
                elevation: 6,
                padding: EdgeInsets.zero,
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 1,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.delete, color: Colors.redAccent, size: 18),
                        SizedBox(width: 10),
                        Text(
                          "Delete Chat",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(height: 1),
                  PopupMenuItem(
                    value: 2,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.report, color: Colors.orange, size: 18),
                        SizedBox(width: 10),
                        Text(
                          "Report User",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(height: 1),
                  PopupMenuItem(
                    value: 3,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.block, color: Colors.grey, size: 18),
                        SizedBox(width: 10),
                        Text(
                          "Block User",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                onSelected: (value) {
                  switch (value) {
                    case 1:
                      _deleteChat();
                      break;
                    case 2:
                      _reportUser();
                      break;
                    case 3:
                      _blockUser();
                      break;
                  }
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Ad Preview Section
            Material(
              color: Colors.grey.shade100,
              child: InkWell(
                onTap: () => _onProduct(widget.chatSession.adId ?? 0),
                splashColor: Colors.grey.withOpacity(0.2),
                highlightColor: Colors.transparent,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          widget.chatSession.adPhoto != null
                              ? '${widget.chatSession.adPhoto}'
                              : 'https://i.pravatar.cc/300',
                          height: 50,
                          width: 50,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.chatSession.adTitle ?? "No Title",
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Af ${widget.chatSession.adPrice ?? 'N/A'}",
                              style: TextStyle(
                                color: Colors.green.shade700,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right,
                        color: Colors.grey,
                        size: 24,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Chat UI
            Expanded(
              child: Chat(
                messages: _messages,
                onSendPressed: _onSendPressed,
                onAttachmentPressed: _handleAttachmentPressed,
                onMessageTap: _onMessageTap,
                onPreviewDataFetched: _onPreviewDataFetched,
                user: _me,
                isAttachmentUploading: false,
                showUserAvatars: true,
                showUserNames: true,
                typingIndicatorOptions: TypingIndicatorOptions(
                  typingUsers: _isTyping ? [_other] : const [],
                ),
                theme: const DefaultChatTheme(
                  primaryColor: Color(0xFFFF9900),
                  secondaryColor: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteChat() async {
    final sessionId =
        widget.chatSession.sessionId ?? 'chat_${widget.chatSession.chatId}';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Chat'),
        content: const Text('Are you sure you want to delete this chat?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              // Implement delete logic
              await _firestore
                  .collection('chatSessions')
                  .doc(sessionId)
                  .delete();
              Navigator.pop(context); // Go back to chat list
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _reportUser() {
    // Implement report user logic
    print("Report user: ${_other.firstName}");
  }

  void _blockUser() {
    // Implement block user logic
    print("Block user: ${_other.firstName}");
  }
}
