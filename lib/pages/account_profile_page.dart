import 'package:afghan_bazar/pages/coming_soon_page.dart';
import 'package:afghan_bazar/pages/favorite_items_page.dart';
import 'package:afghan_bazar/pages/my_ads_page.dart';
import 'package:afghan_bazar/pages/setting_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Flexible AppBar with background image + profile
          SliverAppBar(
            pinned: true,
            expandedHeight: 200,
            backgroundColor: Colors.blue.shade300,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Background image
                  Image.asset(
                    "assets/images/dark-honeycomb.png", // put your own image here
                    fit: BoxFit.cover,
                  ),
                  // Container(
                  //   color: Colors.black.withOpacity(0.3),
                  // ),

                  // Profile info
                  Positioned(
                    bottom: 20,
                    left: 16,
                    right: 16,
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 35,
                          backgroundColor: Colors.amber,
                          child: Icon(
                            Icons.person,
                            size: 40,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Khan",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {},
                              child: const Text(
                                "View public profile",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        // Notification button
                        CircleAvatar(
                          backgroundColor: Colors.white,
                          child: IconButton(
                            icon: const Icon(
                              Icons.notifications_none,
                              color: Colors.black,
                            ),
                            onPressed: () {},
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Body content
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 20),

                // Quick actions row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _quickAction(
                        Icons.receipt_long,
                        "My Ads",
                        () => {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MyAdsPage(),
                            ),
                          ),
                        },
                      ),
                      _quickAction(
                        Icons.favorite_border,
                        "Favourites",
                        () => {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FavoriteItemsPage(),
                            ),
                          ),
                        },
                      ),
                      _quickAction(
                        Icons.shopping_cart_outlined,
                        "Cart",
                        () => {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ComingSoonPage(),
                            ),
                          ),
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // // Discounted Packages Banner
                // Container(
                //   margin: const EdgeInsets.symmetric(horizontal: 16),
                //   padding: const EdgeInsets.all(16),
                //   decoration: BoxDecoration(
                //     color: Colors.lightBlue.shade50,
                //     borderRadius: BorderRadius.circular(12),
                //   ),
                //   child: Row(
                //     children: [
                //       const Icon(Icons.local_offer, color: Colors.teal),
                //       const SizedBox(width: 12),
                //       Expanded(
                //         child: Column(
                //           crossAxisAlignment: CrossAxisAlignment.start,
                //           children: const [
                //             Text(
                //               "Buy Discounted Packages",
                //               style: TextStyle(fontWeight: FontWeight.bold),
                //             ),
                //             SizedBox(height: 4),
                //             Text(
                //                 "More Credits, More Savings.\nGrab Discounted Packages Today!"),
                //           ],
                //         ),
                //       ),
                //       const Icon(Icons.arrow_forward_ios,
                //           size: 16, color: Colors.black54),
                //     ],
                //   ),
                // ),
                const SizedBox(height: 20),

                // List options
                _listTile(
                  Icons.credit_card,
                  "Payment Options",
                  "Manage saved payment methods.",
                  () => {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ComingSoonPage()),
                    ),
                  },
                ),

                _listTile(
                  Icons.settings,
                  "Settings",
                  "Privacy and manage account.",
                  () => {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserSettingsPage(),
                      ),
                    ),
                  },
                ),
                _listTile(
                  Icons.help_outline,
                  "Help & Support",
                  "Help center and legal terms.",
                  () => {},
                ),
                _listTile(Icons.logout, "Logout", "", () => {}),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickAction(IconData icon, String title, Function onTap) {
    return Column(
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => onTap(),
          child: Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.black87),
          ),
        ),
        const SizedBox(height: 6),
        Text(title, style: const TextStyle(fontSize: 14)),
      ],
    );
  }

  Widget _listTile(
    IconData icon,
    String title,
    String subtitle,
    Function onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: Colors.black87),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: subtitle.isNotEmpty ? Text(subtitle) : null,
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.black54,
      ),
      onTap: () => onTap(),
    );
  }
}
