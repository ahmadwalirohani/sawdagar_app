import 'dart:convert';

import 'package:afghan_bazar/blocs/user_published_ads_bloc.dart';
import 'package:afghan_bazar/cards/profile_ads_card.dart';
import 'package:afghan_bazar/services/auth_service.dart';
import 'package:afghan_bazar/widgets/product_details.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SellerProfilePage extends StatefulWidget {
  final String name;
  final String memberSince;
  final int publishedAds;
  final String location;
  final int userId;
  final String? imageUrl;
  final double averageRating;
  final int totalRatings;
  final bool hasUserRated;
  final Map<int, int> ratingDistribution; // Add rating distribution

  const SellerProfilePage({
    super.key,
    required this.name,
    required this.memberSince,
    required this.publishedAds,
    required this.location,
    required this.userId,
    this.imageUrl,
    this.averageRating = 0.0,
    this.totalRatings = 0,
    this.hasUserRated = false,
    this.ratingDistribution = const {
      5: 0,
      4: 0,
      3: 0,
      2: 0,
      1: 0,
    }, // Default empty distribution
  });

  @override
  State<SellerProfilePage> createState() => _SellerProfilePageState();
}

class _SellerProfilePageState extends State<SellerProfilePage> {
  bool isFavorite = false;
  late double _averageRating;
  late int _totalRatings;
  late bool _hasUserRated;
  late Map<int, int> _ratingDistribution;

  @override
  void initState() {
    super.initState();
    // Initialize with widget values
    _averageRating = widget.averageRating;
    _totalRatings = widget.totalRatings;
    _hasUserRated = widget.hasUserRated;
    _ratingDistribution = Map.from(widget.ratingDistribution);

    // Load data once when page opens
    final bloc = context.read<UserPublishedAdsBloc>().getData(widget.userId);
  }

  void _showRatingDialog() {
    double userRating = 0;
    TextEditingController feedbackController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rate Seller'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('How would you rate this seller?'),
            const SizedBox(height: 16),
            // Star rating widget
            StatefulBuilder(
              builder: (context, setState) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return IconButton(
                      icon: Icon(
                        index < userRating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 30,
                      ),
                      onPressed: () {
                        setState(() {
                          userRating = (index + 1).toDouble();
                        });
                      },
                    );
                  }),
                );
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: feedbackController,
              decoration: const InputDecoration(
                labelText: 'Feedback (Optional)',
                border: OutlineInputBorder(),
                hintText: 'Share your experience with this seller...',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _submitRating(userRating, feedbackController.text);
              Navigator.pop(context);
            },
            child: const Text('Submit Rating'),
          ),
        ],
      ),
    );
  }

  void _submitRating(double rating, String feedback) async {
    final response = await AuthService().authPost(
      'ratings',
      body: jsonEncode({
        'seller_id': widget.userId,
        'rating': rating,
        'feedback': feedback,
      }),
    );

    if (response.statusCode == 201) {
      // Calculate new average rating
      double newAverage =
          ((_averageRating * _totalRatings) + rating) / (_totalRatings + 1);

      // Update rating distribution
      int ratingKey = rating.toInt();
      int currentCount = _ratingDistribution[ratingKey] ?? 0;

      setState(() {
        _averageRating = double.parse(newAverage.toStringAsFixed(1));
        _totalRatings += 1;
        _hasUserRated = true;
        _ratingDistribution[ratingKey] = currentCount + 1;
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Thank you for your ${rating.toInt()}-star rating!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed to rate")));
    }
  }

  Widget _buildRatingStars(double rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        if (index < rating.floor()) {
          return const Icon(Icons.star, color: Colors.amber, size: 20);
        } else if (index == rating.floor() && rating % 1 >= 0.5) {
          return const Icon(Icons.star_half, color: Colors.amber, size: 20);
        } else {
          return const Icon(Icons.star_border, color: Colors.amber, size: 20);
        }
      }),
    );
  }

  Widget _buildRatingBar(int starCount, int count, int totalRatings) {
    double percentage = totalRatings > 0 ? (count / totalRatings) * 100 : 0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$starCount',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const Icon(Icons.star, color: Colors.amber, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: LinearProgressIndicator(
              value: totalRatings > 0 ? count / totalRatings : 0,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                _getProgressBarColor(starCount),
              ),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$count (${percentage.toStringAsFixed(1)}%)',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Color _getProgressBarColor(int starCount) {
    switch (starCount) {
      case 5:
        return Colors.green;
      case 4:
        return Colors.lightGreen;
      case 3:
        return Colors.amber;
      case 2:
        return Colors.orange;
      case 1:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
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
                                errorBuilder: (_, __, ___) => Container(
                                  color: const Color(0xFFE9ECEF),
                                  alignment: Alignment.center,
                                  child: const Icon(
                                    Icons.supervised_user_circle_sharp,
                                  ),
                                ),
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

                  // Rating Section
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Seller Rating",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),

                        if (_totalRatings > 0) ...[
                          Row(
                            children: [
                              // Average Rating
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _averageRating.toStringAsFixed(1),
                                    style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.amber,
                                    ),
                                  ),
                                  _buildRatingStars(_averageRating),
                                  const SizedBox(height: 4),
                                  Text(
                                    "$_totalRatings ${_totalRatings == 1 ? 'rating' : 'ratings'}",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 16),

                              // Rating Distribution
                              Expanded(
                                child: Column(
                                  children: [
                                    // Rating bars for each star
                                    _buildRatingBar(
                                      5,
                                      _ratingDistribution[5] ?? 0,
                                      _totalRatings,
                                    ),
                                    _buildRatingBar(
                                      4,
                                      _ratingDistribution[4] ?? 0,
                                      _totalRatings,
                                    ),
                                    _buildRatingBar(
                                      3,
                                      _ratingDistribution[3] ?? 0,
                                      _totalRatings,
                                    ),
                                    _buildRatingBar(
                                      2,
                                      _ratingDistribution[2] ?? 0,
                                      _totalRatings,
                                    ),
                                    _buildRatingBar(
                                      1,
                                      _ratingDistribution[1] ?? 0,
                                      _totalRatings,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          // Rating Description
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: _getRatingColor(
                                _averageRating,
                              ).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _getRatingIcon(_averageRating),
                                  color: _getRatingColor(_averageRating),
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _getRatingDescription(_averageRating),
                                  style: TextStyle(
                                    color: _getRatingColor(_averageRating),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ] else ...[
                          const Center(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.star_outline,
                                  size: 40,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  "No ratings yet",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  "Be the first to rate this seller",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 16),

                        // Rate Button (only show if user hasn't rated yet)
                        if (!_hasUserRated) ...[
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _showRatingDialog,
                              icon: const Icon(Icons.star, size: 20),
                              label: const Text('Rate This Seller'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.amber,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ),
                        ] else ...[
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.green[50],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  color: Colors.green[600],
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "You've rated this seller",
                                  style: TextStyle(
                                    color: Colors.green[700],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
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
                      builder: (context) => ProductDetails(product: item),
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

  String _getRatingDescription(double rating) {
    if (rating >= 4.5) return "Excellent seller! Highly recommended";
    if (rating >= 4.0) return "Very good seller. Great experience";
    if (rating >= 3.5) return "Good seller. Satisfactory service";
    if (rating >= 3.0) return "Average seller. Meets expectations";
    if (rating >= 2.0) return "Needs improvement in some areas";
    return "Poor experience. Needs significant improvement";
  }

  Color _getRatingColor(double rating) {
    if (rating >= 4.0) return Colors.green;
    if (rating >= 3.0) return Colors.amber;
    return Colors.red;
  }

  IconData _getRatingIcon(double rating) {
    if (rating >= 4.0) return Icons.thumb_up;
    if (rating >= 3.0) return Icons.thumbs_up_down;
    return Icons.thumb_down;
  }
}
