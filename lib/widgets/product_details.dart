import 'dart:convert';
import 'package:afghan_bazar/pages/my_orders_page.dart';
import 'package:afghan_bazar/blocs/product_related_ads_bloc.dart';
import 'package:afghan_bazar/pages/seller_info_page.dart';
import 'package:afghan_bazar/services/auth_service.dart';
import 'package:afghan_bazar/widgets/product_card.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:afghan_bazar/widgets/report_ads_dialog.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:afghan_bazar/models/product_ads_model.dart';

class ProductDetails extends StatefulWidget {
  final ProductAdsModel product;

  const ProductDetails({super.key, required this.product});

  @override
  State<ProductDetails> createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  final baseHost = AuthService.baseHost;
  bool _showMore = false;

  ProductAdsModel get product => widget.product;

  // Function to launch Google Maps with the given latitude and longitude
  Future<void> _launchGoogleMaps(String latitude, String longitude) async {
    final String googleMapsUrl =
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    if (await canLaunch(googleMapsUrl)) {
      await launch(googleMapsUrl);
    } else {
      throw 'Could not launch $googleMapsUrl';
    }
  }

  void initState() {
    super.initState();
    // load data once when page opens
    final bloc = context.read<ProductRelatedAdsBloc>().getData(
      product.id,
      product.title,
      product.category ?? '',
      product.location ?? '',
      product.condition,
    );
  }

  @override
  Widget build(BuildContext context) {
    final photos = product.photos ?? [];
    final bloc = context.watch<ProductRelatedAdsBloc>();
    var items = bloc.getAds();

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // Image carousel
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            backgroundColor: const Color.fromARGB(255, 4, 24, 35),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
              iconSize: 20,
              padding: const EdgeInsets.all(8),
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.favorite_border,
                  color: Colors.white,
                  size: 20,
                ),
                iconSize: 20,
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.share, color: Colors.white, size: 20),
                iconSize: 20,
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                onPressed: () {},
              ),
            ],
            toolbarHeight: 48,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  // Image Carousel with PageView
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ImageZoomScreen(
                            images: photos,
                            initialIndex: _currentIndex,
                          ),
                        ),
                      );
                    },
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() => _currentIndex = index);
                      },
                      itemCount: photos.length,
                      itemBuilder: (context, index) {
                        return Hero(
                          tag: 'image_${photos[index]}',
                          child: Image.network(
                            "${baseHost}/${photos[index]}",
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: Colors.grey.shade300,
                              alignment: Alignment.center,
                              child: const Icon(Icons.broken_image, size: 60),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Mini Image Thumbnails Indicator
                  Positioned(
                    bottom: 16,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 60,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Center(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              photos.length,
                              (index) => GestureDetector(
                                onTap: () {
                                  _pageController.animateToPage(
                                    index,
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                },
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: _currentIndex == index
                                          ? Colors.white
                                          : Colors.transparent,
                                      width: _currentIndex == index ? 3 : 0,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.3),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: Stack(
                                      children: [
                                        Image.network(
                                          "${baseHost}/${photos[index]}",
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          height: double.infinity,
                                          errorBuilder: (_, __, ___) =>
                                              Container(
                                                color: Colors.grey.shade400,
                                                child: const Icon(
                                                  Icons.broken_image,
                                                  size: 20,
                                                  color: Colors.white,
                                                ),
                                              ),
                                        ),
                                        // Overlay for better border visibility
                                        if (_currentIndex == index)
                                          Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                              border: Border.all(
                                                color: Colors.white,
                                                width: 2,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Image Counter
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        '${_currentIndex + 1}/${photos.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ), // Details Content
          // Details
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (product.status == "featured")
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8D24A),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        "Featured",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  const SizedBox(height: 12),

                  Text(
                    product.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Text(
                    "${product.price} ${product.currency}",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 18,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            // Check if latitude and longitude are available
                            if (product.latitude != null &&
                                product.longitude != null) {
                              _launchGoogleMaps(
                                product.latitude!,
                                product.longitude!,
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Location not available"),
                                ),
                              );
                            }
                          },
                          child: Text(
                            product.location ?? "Unknown",
                            style: TextStyle(
                              color: Colors
                                  .blue
                                  .shade700, // Make text blue to indicate it's clickable
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        product.createdAt ?? "N/A",
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // See more toggle
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () {
                        setState(() => _showMore = !_showMore);
                      },
                      icon: Icon(
                        _showMore
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: Colors.blueGrey,
                      ),
                      label: Text(
                        _showMore ? "Hide details" : "See more",
                        style: const TextStyle(color: Colors.blueGrey),
                      ),
                    ),
                  ),

                  if (_showMore) ...[
                    const SizedBox(height: 8),
                    // Condition badge
                    if (product.condition != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blueAccent),
                        ),
                        child: Text(
                          "Condition: ${product.condition}",
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.blueAccent,
                          ),
                        ),
                      ),
                    const SizedBox(height: 10),
                    // Available locations
                    if (product.availableLocations != null &&
                        product.availableLocations!.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Available in:",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 6,
                            children: product.availableLocations!
                                .map(
                                  (loc) => Chip(
                                    label: Text(loc),
                                    backgroundColor: Colors.grey.shade200,
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                      ),
                    const SizedBox(height: 20),
                  ],

                  const Text(
                    "Description",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.description ?? "No description provided",
                    style: const TextStyle(fontSize: 14, height: 1.5),
                  ),
                  const SizedBox(height: 30),

                  // Seller info
                  const Text(
                    "Seller Information",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white,
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundImage: product.userImage != null
                              ? NetworkImage("$baseHost${product.userImage!}")
                              : null,
                          backgroundColor: Colors.grey.shade200,
                          child: product.userImage == null
                              ? const Icon(Icons.person, size: 28)
                              : null,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.userName ?? "Unknown",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Member since ${product.userCreatedAt ?? 'N/A'}",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "${product.activeAds} active ads",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SellerProfilePage(
                                  userId: product.userId,
                                  name: product.userName ?? '',
                                  location: 'N/A',
                                  memberSince: product.userCreatedAt ?? '',
                                  publishedAds: product.activeAds ?? 0,
                                  imageUrl: "$baseHost${product.userImage!}",
                                ),
                              ),
                            );
                          },
                          child: const Text("View Profile"),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  OutlinedButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return ReportAdDialog(
                            onSubmit: (reason, comment) async {
                              await AuthService().authPost(
                                'report-ads',
                                body: jsonEncode({
                                  'productAdId': product.id,
                                  'reason': reason,
                                  'description': comment,
                                }),
                              );
                            },
                          );
                        },
                      );
                    },
                    icon: const Icon(
                      Icons.flag,
                      color: Colors.black87,
                      size: 15,
                    ),
                    label: const Text(
                      "Report this Ad",
                      style: TextStyle(fontSize: 13, color: Colors.black87),
                    ),
                  ),

                  const Divider(height: 40, thickness: 1),

                  ProductSection(
                    title: "Related Ads",
                    onViewAll: () {},
                    isShowViewAll: false,
                    products: items,
                  ),
                  const Divider(height: 20, thickness: 1),

                  const Text(
                    "Your safety matters to us!",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color.fromARGB(255, 4, 24, 35),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text("• Only meet in public / crowded places."),
                  const Text(
                    "• Never go alone to meet a buyer / seller, always take someone with you.",
                  ),
                  const Text(
                    "• Check and inspect the product properly before purchasing it.",
                  ),
                  const Text(
                    "• Never pay anything in advance or transfer money before inspecting the product.",
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),

      bottomNavigationBar: BottomButtons(
        productAdId: product.id,
        productPrice: product.price,
      ),
    );
  }
}

class BottomButtons extends StatefulWidget {
  int? productAdId;
  String productPrice;

  BottomButtons({super.key, this.productAdId, this.productPrice = '0'});

  @override
  _BottomButtonsState createState() => _BottomButtonsState();
}

class _BottomButtonsState extends State<BottomButtons> {
  bool _isLoading = false; // Manage loading state

  void _submit() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await AuthService().authPost(
        "order/create",
        body: jsonEncode({
          'ad_id': widget.productAdId,
          'price': widget.productPrice,
          'quantity': 1,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // short delay so user sees success banner
        await Future.delayed(const Duration(seconds: 2));

        if (!mounted) return;

        // navigate & remove this page from stack
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MyOrdersPage()),
        );
      } else {
        print(response.body);
      }
    } catch (e) {
      print(e);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade300, width: 1)),
      ),
      child: Row(
        children: [
          // Call Button (Outlined)
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(
                Icons.phone_outlined,
                color: Colors.black87,
                size: 15,
              ),
              label: const Text(
                "Call",
                style: TextStyle(fontSize: 13, color: Colors.black87),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.black87, width: 1.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                padding: const EdgeInsets.symmetric(vertical: 2),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Chat Button (Filled)
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(
                Icons.chat_bubble_outline,
                color: Colors.white,
                size: 15,
              ),
              label: const Text(
                "Chat",
                style: TextStyle(fontSize: 13, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(
                  255,
                  4,
                  24,
                  35,
                ), // Dark green
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                padding: const EdgeInsets.symmetric(vertical: 2),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SizedBox(
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _submit,
                icon: _isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(
                        Icons.shopping_bag,
                        color: Colors.white,
                        size: 15,
                      ),
                label: _isLoading
                    ? const Text(
                        "Loading...",
                        style: TextStyle(fontSize: 13, color: Colors.white),
                      )
                    : const Text(
                        "Order",
                        style: TextStyle(fontSize: 13, color: Colors.white),
                      ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 4, 24, 35),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ImageZoomScreen extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const ImageZoomScreen({
    Key? key,
    required this.images,
    required this.initialIndex,
  }) : super(key: key);

  @override
  _ImageZoomScreenState createState() => _ImageZoomScreenState();
}

class _ImageZoomScreenState extends State<ImageZoomScreen> {
  late PageController _pageController;
  late int _currentIndex;
  final baseHost = AuthService.baseHost;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Zoomable PageView
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() => _currentIndex = index);
            },
            itemCount: widget.images.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onDoubleTap: () {
                  // Optional: Add zoom functionality here
                  // You can use photo_view package for advanced zooming:
                  // PhotoView(imageProvider: AssetImage(widget.images[index]))
                },
                child: PhotoView(
                  imageProvider: NetworkImage(
                    "$baseHost/${widget.images[index]}",
                  ),
                  minScale: PhotoViewComputedScale.contained,
                  maxScale: PhotoViewComputedScale.covered * 2.0,
                  heroAttributes: PhotoViewHeroAttributes(
                    tag: 'image_${widget.images[index]}',
                  ),
                ),
              );
            },
          ),

          // Close button
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 28),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          // Image counter in zoom view
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '${_currentIndex + 1}/${widget.images.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Dots indicator at bottom
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 20,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.images.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentIndex == index ? 12 : 8,
                  height: _currentIndex == index ? 12 : 8,
                  decoration: BoxDecoration(
                    color: _currentIndex == index
                        ? Colors.white
                        : Colors.white54,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
