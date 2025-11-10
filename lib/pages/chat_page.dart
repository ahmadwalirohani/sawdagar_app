import 'package:afghan_bazar/blocs/chat_sessions_bloc.dart';
import 'package:afghan_bazar/models/chat_session_model.dart';
import 'package:afghan_bazar/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:afghan_bazar/pages/chat_messaging_page.dart';
import 'package:provider/provider.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String basehost = AuthService.baseHost;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    final bloc = context.read<ChatSessionsBloc>();
    bloc.getData(null);

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      switch (_tabController.index) {
        case 0:
          bloc.getData(null); // All
          break;
        case 1:
          bloc.getData('buyer');
          break;
        case 2:
          bloc.getData('seller');
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.watch<ChatSessionsBloc>();
    var items = bloc.getchats();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Chats", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 1,
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFFFF9900),
          unselectedLabelColor: Colors.black54,
          indicatorColor: const Color(0xFFFF9900),
          tabs: const [
            Tab(text: "All"),
            Tab(text: "Buying"),
            Tab(text: "Selling"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildChatList(items, "No chats yet."),
          _buildChatList(items, "No buying chats."),
          _buildChatList(items, "No selling chats."),
        ],
      ),
    );
  }

  Widget _buildChatList(List<ChatSessionModel> chats, String emptyMsg) {
    if (chats.isEmpty) {
      return _emptyPage(emptyMsg);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: chats.length,
      itemBuilder: (context, index) {
        final chat = chats[index];
        return _chatCard(chat);
      },
    );
  }

  Widget _chatCard(ChatSessionModel chat) {
    final bloc = context.read<ChatSessionsBloc>();

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 1,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () {
            // Mark as read when opening chat
            bloc.markMessagesAsRead(chat);

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatMessagingPage(chatSession: chat),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Chat image + user avatar overlay
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        "${basehost}/${chat.adPhoto}",
                        width: 55,
                        height: 55,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 55,
                            height: 55,
                            color: Colors.grey[300],
                            child: const Icon(Icons.image, color: Colors.grey),
                          );
                        },
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        radius: 12,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          radius: 10,
                          backgroundImage: NetworkImage(
                            "${basehost}/${chat.partnerAvatar}",
                          ),
                          onBackgroundImageError: (exception, stackTrace) {
                            // Handle image error
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        chat.partnerName!,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        chat.adTitle!,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      // Real-time last message from Firebase
                      StreamBuilder<Map<String, dynamic>?>(
                        stream: bloc.getLastMessageStream(chat),
                        builder: (context, snapshot) {
                          if (snapshot.hasData && snapshot.data != null) {
                            final lastMessage = snapshot.data!;
                            return Text(
                              lastMessage['content'] ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            );
                          }
                          return const SizedBox();
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  children: [
                    Text(
                      _formatTime(chat.createdAt),
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    // Real-time unread count badge
                    StreamBuilder<int>(
                      stream: bloc.getUnreadCountStream(chat),
                      builder: (context, snapshot) {
                        final unreadCount = snapshot.data ?? 0;
                        if (unreadCount > 0) {
                          return Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Color(0xFFFF9900),
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              unreadCount > 9 ? '9+' : unreadCount.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(String createdAt) {
    try {
      final dateTime = DateTime.parse(createdAt);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inDays > 0) {
        return '${difference.inDays}d';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m';
      } else {
        return 'Now';
      }
    } catch (e) {
      return '';
    }
  }

  Widget _emptyPage(String msg) {
    return Center(
      child: Text(
        msg,
        style: const TextStyle(color: Colors.grey, fontSize: 16),
      ),
    );
  }
}
