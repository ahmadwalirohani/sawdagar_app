import 'package:afghan_bazar/blocs/user_published_ads_bloc.dart';
import 'package:afghan_bazar/cards/profile_ads_card.dart';
import 'package:afghan_bazar/widgets/product_details.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SellerProfilePage extends StatefulWidget {
  final String name;
  final String memberSince;
  final int publishedAds;
  final String location;
  final int userId;
  final String? imageUrl; // Optional image URL for the profile

  // Constructor to pass values, including an optional imageUrl
  const SellerProfilePage({
    super.key,
    required this.name,
    required this.memberSince,
    required this.publishedAds,
    required this.location,
    required this.userId,
    this.imageUrl, // Optional parameter for the image URL
  });

  @override
  State<SellerProfilePage> createState() => _SellerProfilePageState();
}

class _SellerProfilePageState extends State<SellerProfilePage> {
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    // load data once when page opens
    final bloc = context.read<UserPublishedAdsBloc>().getData(widget.userId);
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget build(BuildContext context) {
    final bloc = context.watch<UserPublishedAdsBloc>();
    var items = bloc.getAds();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Public Profile"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 20),
          iconSize: 20,
          padding: const EdgeInsets.all(8),
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          onPressed: () => Navigator.pop(context),
        ),
        actions: const [Icon(Icons.more_vert)],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      widget.imageUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(35),
                              child: Image.network(
                                widget.imageUrl!,
                                height: 70,
                                width: 70,
                                fit: BoxFit.cover,
                              ),
                            )
                          : const CircleAvatar(
                              radius: 35,
                              backgroundColor: Colors.teal,
                              child: Icon(
                                Icons.person,
                                size: 40,
                                color: Colors.white,
                              ),
                            ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.name,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.calendar_today, size: 16),
                                const SizedBox(width: 6),
                                Text("Member Since ${widget.memberSince}"),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.assignment, size: 16),
                                const SizedBox(width: 6),
                                Text("Published Ads: ${widget.publishedAds}"),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.share, color: Colors.grey),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Published Ads",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          // Use SliverList for the ads
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final item = items[index];
              return ProfileAdCard(
                adModel: item,
                onTap: () => {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductDetails(
                        product: item, // Placeholder
                      ),
                    ),
                  ),
                },
              );
            }, childCount: items.length),
          ),
        ],
      ),
    );
  }
}
