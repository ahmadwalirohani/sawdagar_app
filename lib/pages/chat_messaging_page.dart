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
import 'package:intl/intl.dart'; // Add this import

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

  // Color Scheme
  final Color _primaryColor = const Color(0xFF0053E2);
  final Color _accentColor = const Color(0xFFFFC220);
  final Color _bgColor = Colors.white;
  final Color _surfaceColor = const Color(0xFFF8FAFD);
  final Color _textPrimary = const Color(0xFF1A1A1A);
  final Color _textSecondary = const Color(0xFF6B7280);
  final Color _borderColor = const Color(0xFFE5E7EB);

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
    final currentUser = AuthService.getCurrentUser;

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

    final messageRef = _firestore
        .collection('chatSessions')
        .doc(sessionId)
        .collection('messages')
        .doc(message.id);
    batch.set(messageRef, firebaseMessage);

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
      backgroundColor: _surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 4,
              width: 40,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: _borderColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.photo, color: _primaryColor),
              ),
              title: Text(
                'Photo from gallery',
                style: TextStyle(color: _textPrimary),
              ),
              onTap: () async {
                Navigator.pop(ctx);
                await _pickImage();
              },
            ),
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.camera_alt, color: _primaryColor),
              ),
              title: Text(
                'Take a photo',
                style: TextStyle(color: _textPrimary),
              ),
              onTap: () async {
                Navigator.pop(ctx);
                await _pickImage(fromCamera: true);
              },
            ),
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.attach_file, color: _primaryColor),
              ),
              title: Text(
                'File (PDF/Doc/etc.)',
                style: TextStyle(color: _textPrimary),
              ),
              onTap: () async {
                Navigator.pop(ctx);
                await _pickFile();
              },
            ),
            const SizedBox(height: 8),
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
      uri: picked.path,
    );

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
        // Open network URL
      } else if (await File(uri).exists()) {
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
    return "Active 7h ago";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(68),
        child: Container(
          decoration: BoxDecoration(
            color: _bgColor,
            border: Border(bottom: BorderSide(color: _borderColor, width: 1)),
          ),
          child: AppBar(
            backgroundColor: _bgColor,
            elevation: 0,
            automaticallyImplyLeading: false,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_rounded, color: _textPrimary),
              onPressed: () => Navigator.pop(context),
            ),
            centerTitle: false,
            title: Row(
              children: [
                Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: _borderColor, width: 1.5),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      _other.imageUrl ?? 'https://i.pravatar.cc/300',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: const Color(0xFFE9ECEF),
                        alignment: Alignment.center,
                        child: const Icon(Icons.supervised_user_circle_sharp),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _other.firstName ?? "User",
                        style: TextStyle(
                          color: _textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _getLastSeenText(),
                        style: TextStyle(color: _textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.more_vert_rounded, color: _textPrimary),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: _surfaceColor,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    builder: (ctx) => Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          height: 4,
                          width: 40,
                          margin: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _borderColor,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        _actionTile(
                          icon: Icons.delete_outline_rounded,
                          title: "Delete Chat",
                          color: Colors.red,
                          onTap: _deleteChat,
                        ),
                        _actionTile(
                          icon: Icons.report_outlined,
                          title: "Report User",
                          color: Colors.orange,
                          onTap: _reportUser,
                        ),
                        _actionTile(
                          icon: Icons.block_outlined,
                          title: "Block User",
                          color: _textSecondary,
                          onTap: _blockUser,
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(width: 4),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Ad Preview Card
            GestureDetector(
              onTap: () => _onProduct(widget.chatSession.adId ?? 0),
              child: Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _surfaceColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _borderColor),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        widget.chatSession.adPhoto != null
                            ? '${widget.chatSession.adPhoto}'
                            : 'https://i.pravatar.cc/300',
                        height: 48,
                        width: 48,
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
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: _textPrimary,
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
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: _primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: _primaryColor,
                        size: 14,
                      ),
                    ),
                  ],
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
                showUserNames: false,
                dateFormat: DateFormat('HH:mm'),
                timeFormat: DateFormat('HH:mm'),
                typingIndicatorOptions: TypingIndicatorOptions(
                  typingUsers: _isTyping ? [_other] : const [],
                ),
                theme: DefaultChatTheme(
                  primaryColor: _primaryColor,
                  secondaryColor: _accentColor,
                  backgroundColor: _bgColor,
                  inputBackgroundColor: _surfaceColor,
                  inputTextColor: _textPrimary,
                  inputTextDecoration: InputDecoration(
                    hintStyle: TextStyle(color: _textSecondary),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: _borderColor),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: _borderColor),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: _primaryColor),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    filled: true,
                    fillColor: _surfaceColor,
                  ),
                  sentMessageBodyTextStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                  ),
                  receivedMessageBodyTextStyle: TextStyle(
                    color: _textPrimary,
                    fontSize: 15,
                  ),
                  sentMessageCaptionTextStyle: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                  ),
                  receivedMessageCaptionTextStyle: TextStyle(
                    color: _textSecondary,
                  ),
                  sentMessageLinkTitleTextStyle: const TextStyle(
                    color: Colors.white,
                  ),
                  receivedMessageLinkTitleTextStyle: TextStyle(
                    color: _textPrimary,
                  ),
                  sentMessageLinkDescriptionTextStyle: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                  ),
                  receivedMessageLinkDescriptionTextStyle: TextStyle(
                    color: _textSecondary,
                  ),
                  userAvatarTextStyle: TextStyle(
                    color: _textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionTile({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(title, style: TextStyle(color: _textPrimary)),
      onTap: onTap,
    );
  }

  void _deleteChat() async {
    final sessionId =
        widget.chatSession.sessionId ?? 'chat_${widget.chatSession.chatId}';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Delete Chat',
          style: TextStyle(color: _textPrimary, fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Are you sure you want to delete this chat?',
          style: TextStyle(color: _textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: _textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _firestore
                  .collection('chatSessions')
                  .doc(sessionId)
                  .delete();
              Navigator.pop(context);
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _reportUser() {
    print("Report user: ${_other.firstName}");
  }

  void _blockUser() {
    print("Block user: ${_other.firstName}");
  }
}
