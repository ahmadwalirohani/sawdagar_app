import 'package:afghan_bazar/pages/chat_messaging_page.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  var scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration(milliseconds: 0)).then((value) {
      // context.read<FeaturedBloc>().getData(context.locale);
      // context.read<PopularBloc>().getData(context.locale);
      // context.read<RecentBloc>().getData(mounted);
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: const Text('Chats', style: TextStyle(color: Colors.black)),
          bottom: const TabBar(
            labelColor: Color(0xFFFF9900),
            unselectedLabelColor: Colors.black54,
            indicatorColor: Color(0xFFFF9900),
            labelStyle: TextStyle(fontWeight: FontWeight.bold),
            tabs: [
              Tab(text: 'All'),
              Tab(text: 'Buying'),
              Tab(text: 'Selling'),
            ],
          ),
        ),
        body: Column(
          children: [
            // // Filter chips
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            //   child: Wrap(
            //     spacing: 10,
            //     children: const [
            //       FilterChipWidget(label: "All", selected: true),
            //       FilterChipWidget(label: "Unread Chats"),
            //       FilterChipWidget(label: "Favourites"),
            //     ],
            //   ),
            // ),

            // // Notification banner
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 12),
            //   child: Card(
            //     color: const Color(0xFFFFFAE5),
            //     shape: RoundedRectangleBorder(
            //       borderRadius: BorderRadius.circular(8),
            //     ),
            //     child: ListTile(
            //       contentPadding: const EdgeInsets.all(12),
            //       leading: const Icon(
            //         Icons.notifications_off,
            //         color: Colors.amber,
            //       ),
            //       title: const Text(
            //         'Missing Important Updates?',
            //         style: TextStyle(fontWeight: FontWeight.bold),
            //       ),
            //       subtitle: const Text(
            //         'Push notifications are off. Turn on notifications and never miss an update.',
            //       ),
            //       trailing: GestureDetector(
            //         onTap: () {},
            //         child: const Icon(Icons.close),
            //       ),
            //     ),
            //   ),
            // ),
            const SizedBox(height: 10),

            // Tab views
            Expanded(
              child: TabBarView(
                children: [
                  ChatListTab(tabType: 'all'),
                  ChatListTab(tabType: 'buying'),
                  ChatListTab(tabType: 'selling'),
                ],
              ),
            ),
          ],
        ),

        // Bottom navigation
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class ChatListTab extends StatelessWidget {
  final String tabType;

  const ChatListTab({Key? key, required this.tabType}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Simulate different data for each tab
    final chatItems = <Map<String, String>>[
      {
        'user': 'User 73A4mH',
        'title': 'Suzuki Alto 2008',
        'msg': 'Is the price firm?',
        'time': '10:42',
        'avatar': 'https://i.pravatar.cc/300',
        'userImg': 'https://i.pravatar.cc/300',
        'type': 'buying',
      },
      {
        'user': 'User 53B9kL',
        'title': 'MacBook Pro 2021',
        'msg': 'Still available?',
        'time': '09:10',
        'avatar': 'https://i.pravatar.cc/300',
        'userImg': 'https://i.pravatar.cc/300',
        'type': 'selling',
      },
    ];

    final filtered = tabType == 'all'
        ? chatItems
        : chatItems.where((e) => e['type'] == tabType).toList();

    if (filtered.isEmpty) {
      return const Center(child: Text('No chats yet.'));
    }

    return ListView.builder(
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final chat = filtered[index];
        return ChatListItem(
          userName: chat['user']!,
          adTitle: chat['title']!,
          message: chat['msg']!,
          time: chat['time']!,
          avatarUrl: chat['avatar']!,
          userImage: chat['userImg']!,
        );
      },
    );
  }
}

class FilterChipWidget extends StatelessWidget {
  final String label;
  final bool selected;

  const FilterChipWidget({Key? key, required this.label, this.selected = false})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      selected: selected,
      label: Text(label),
      onSelected: (_) {},
      selectedColor: const Color.fromARGB(38, 255, 153, 0),
      backgroundColor: Colors.grey.shade200,
      labelStyle: TextStyle(
        color: selected
            ? const Color.fromARGB(255, 4, 24, 35)
            : const Color.fromARGB(255, 4, 24, 35),
        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
      ),
      side: BorderSide.none,
    );
  }
}

class ChatListItem extends StatelessWidget {
  final String userName;
  final String adTitle;
  final String message;
  final String time;
  final String avatarUrl; // Square item image
  final String userImage; // Small circle seller image

  const ChatListItem({
    Key? key,
    required this.userName,
    required this.adTitle,
    required this.message,
    required this.time,
    required this.avatarUrl,
    required this.userImage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ChatMessagingPage()),
            );
          },
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          leading: Stack(
            children: [
              // Square item image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  avatarUrl,
                  width: 52,
                  height: 52,
                  fit: BoxFit.cover,
                ),
              ),
              // Seller circular image at bottom right
              Positioned(
                bottom: 0,
                right: 0,
                child: CircleAvatar(
                  radius: 12,
                  backgroundColor: Colors.white,
                  child: CircleAvatar(
                    radius: 10,
                    backgroundImage: NetworkImage(userImage),
                  ),
                ),
              ),
            ],
          ),
          title: Text(
            userName,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                adTitle,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(message),
            ],
          ),
          trailing: Text(
            time,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ),
        const Divider(height: 1, thickness: 1, indent: 16, endIndent: 16),
      ],
    );
  }
}
