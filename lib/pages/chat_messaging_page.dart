import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_filex/open_filex.dart';
import 'package:uuid/uuid.dart';

class ChatMessagingPage extends StatefulWidget {
  const ChatMessagingPage({super.key});

  @override
  State<ChatMessagingPage> createState() => _ChatMessagingPageState();
}

class _ChatMessagingPageState extends State<ChatMessagingPage> {
  final _uuid = const Uuid();
  final _me = const types.User(id: 'user-1', firstName: 'You');
  final _other = const types.User(id: 'user-2', firstName: 'Support');

  List<types.Message> _messages = [];
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _seedMessages();
  }

  void _seedMessages() {
    final welcome = types.TextMessage(
      id: _uuid.v4(),
      author: _other,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      text: 'سلام! How can I help you today? 😀',
    );
    setState(() => _messages = [welcome]);
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
    final picker = ImagePicker();
    final XFile? picked = await picker.pickImage(
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
    _addMessage(message);
    _simulateReply('Nice photo! 📷');
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
    _addMessage(message);
    _simulateReply('Got the file ✅');
  }

  void _onSendPressed(types.PartialText partial) {
    final message = types.TextMessage(
      id: _uuid.v4(),
      author: _me,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      text: partial.text.trim(),
    );
    _addMessage(message);
    _simulateReply();
  }

  void _addMessage(types.Message message) {
    setState(() => _messages = [message, ..._messages]);
  }

  void _simulateReply([String? forcedText]) async {
    setState(() => _isTyping = true);
    await Future.delayed(const Duration(milliseconds: 900));
    setState(() => _isTyping = false);

    final text = forcedText ?? 'Thanks for your message!';
    final reply = types.TextMessage(
      id: _uuid.v4(),
      author: _other,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      text: text,
    );
    _addMessage(reply);
  }

  void _onMessageTap(BuildContext context, types.Message message) async {
    if (message is types.FileMessage || message is types.ImageMessage) {
      final uri = (message is types.FileMessage)
          ? message.uri
          : (message as types.ImageMessage).uri;
      if (uri.isNotEmpty) {
        await OpenFilex.open(uri);
      }
    }
  }

  void _onPreviewDataFetched(
    types.TextMessage message,
    types.PreviewData data,
  ) {
    final index = _messages.indexWhere((m) => m.id == message.id);
    final updated = (message).copyWith(previewData: data);
    setState(() => _messages[index] = updated);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: Container(
          decoration: BoxDecoration(
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
              icon: Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
            titleSpacing: 0,
            title: Row(
              children: [
                Container(
                  height: 45,
                  width: 45,
                  margin: EdgeInsets.only(left: 4, right: 10),
                  decoration: BoxDecoration(
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
                    backgroundImage: NetworkImage('https://i.pravatar.cc/300'),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "User 73A4mH",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Last active 7 hours ago",
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              PopupMenuButton<int>(
                icon: Icon(Icons.more_vert, color: Colors.black),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                color: Colors.white,
                elevation: 6,
                padding: EdgeInsets.zero,
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 1,
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: Row(
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
                  PopupMenuDivider(height: 1),
                  PopupMenuItem(
                    value: 2,
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: Row(
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
                  PopupMenuDivider(height: 1),
                  PopupMenuItem(
                    value: 3,
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: Row(
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
                      print("Delete Chat");
                      break;
                    case 2:
                      print("Report User");
                      break;
                    case 3:
                      print("Block User");
                      break;
                  }
                },
              ),
              SizedBox(width: 8),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // The widget you want to add below AppBar
            Material(
              color: Colors.grey.shade100,
              child: InkWell(
                onTap: () {
                  print("Car preview clicked!");
                },
                splashColor: Colors.grey.withOpacity(0.2),
                highlightColor: Colors.transparent,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          "https://i.pravatar.cc/300", // Replace with NetworkImage if needed
                          height: 50,
                          width: 50,
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Suzuki Alto 2008",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 4),
                            Text(
                              "Af 13.50 Lacs",
                              style: TextStyle(
                                color: Colors.green.shade700,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right, color: Colors.grey, size: 24),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: Chat(
                //             : BoxDecoration(
                //   image: DecorationImage(
                //     image: AssetImage('assets/chat_bg.png'), // <- correct path
                //     fit: BoxFit.cover,
                //   ),
                // ),
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
