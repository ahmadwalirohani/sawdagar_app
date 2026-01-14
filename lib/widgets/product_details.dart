import 'dart:convert';
import 'package:afghan_bazar/models/chat_session_model.dart';
import 'package:afghan_bazar/pages/chat_messaging_page.dart';
import 'package:afghan_bazar/pages/my_orders_page.dart';
import 'package:afghan_bazar/blocs/product_related_ads_bloc.dart';
import 'package:afghan_bazar/pages/seller_info_page.dart';
import 'package:afghan_bazar/services/auth_service.dart';
import 'package:afghan_bazar/widgets/order_confirmation_dialog.dart';
import 'package:afghan_bazar/widgets/product_card.dart';
import 'package:chewie/chewie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:afghan_bazar/widgets/report_ads_dialog.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:afghan_bazar/models/product_ads_model.dart';
import 'package:video_player/video_player.dart';

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
  bool isMyAd = false;

  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  bool _isVideoPlaying = false;
  bool _isVideo = false;
  List<String> _mediaUrls = []; // This will contain both images and video URLs

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

  Future<void> _loadUserInfo() async {
    if (await AuthService.isLoggedIn()) {
      final prefs = await SharedPreferences.getInstance();
      var userInfo = json.decode(prefs.getString('user_info') ?? '');

      setState(() {
        isMyAd = userInfo['id'] == widget.product.userId;
      });
    }
  }

  void initState() {
    super.initState();
    _loadUserInfo();
    // Combine your photos with video URL
    _mediaUrls = [...widget.product.photos ?? []];
    if (widget.product.videoPath != null) {
      _mediaUrls.insert(
        0,
        widget.product.videoPath!,
      ); // Add video at the beginning or wherever you want
    }

    // Initialize video controller if first item is video
    _initializeVideoIfNeeded(0);
    // load data once when page opens
    context.read<ProductRelatedAdsBloc>().getData(
      product.id,
      product.title,
      product.category ?? '',
      product.location ?? '',
      product.condition,
    );
  }

  Future<void> _disposeVideoControllers() async {
    if (_chewieController != null) {
      _chewieController!.pause();
      _chewieController!.dispose();
      _chewieController = null;
    }

    if (_videoController != null) {
      _videoController!.pause();
      await _videoController!.dispose();
      _videoController = null;
    }
  }

  Future<void> _shareProduct() async {
    final RenderBox? box = context.findRenderObject() as RenderBox?;
    final sharePosition = box!.localToGlobal(Offset.zero) & box!.size;

    final product = widget.product; // Your product object
    final currentImage = _mediaUrls[_currentIndex];

    // Show a dialog with share options
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.text_fields),
                title: const Text('Share Product Details'),
                onTap: () async {
                  Navigator.pop(context);
                  await _shareProductDetails(
                    product,
                    currentImage,
                    sharePosition,
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.image),
                title: const Text('Share Image Only'),
                onTap: () async {
                  Navigator.pop(context);
                  await _shareImageOnly(currentImage, sharePosition);
                },
              ),
              ListTile(
                leading: const Icon(Icons.link),
                title: const Text('Copy Link'),
                onTap: () {
                  Navigator.pop(context);
                  _copyProductLink(product);
                },
              ),
              ListTile(
                leading: const Icon(Icons.qr_code),
                title: const Text('Generate QR Code'),
                onTap: () {
                  Navigator.pop(context);
                  _showQRCode(product);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _shareProductDetails(
    ProductAdsModel? product,
    String currentImage,
    Rect? sharePosition,
  ) async {
    String shareText =
        """
🛍️ ${product?.title ?? 'Amazing Product'}

${product?.description ?? ''}

${product?.price != null ? '💵 Price: \$${product!.price}' : ''}
${product?.price != null ? '🔥 Discounted: \$${product!.price}' : ''}

⭐ ${'4.5'}/5 stars


🔗 View product: ${currentImage}
""";

    await Share.share(
      shareText,
      subject: product?.title ?? 'Check out this product!',
      sharePositionOrigin: sharePosition,
    );
  }

  Future<void> _shareImageOnly(String imageUrl, Rect? sharePosition) async {
    await Share.share(
      'Check out this product image!\n$imageUrl',
      subject: 'Product Image',
      sharePositionOrigin: sharePosition,
    );
  }

  void _copyProductLink(ProductAdsModel? product) async {
    final link = _mediaUrls[0];
    await Clipboard.setData(ClipboardData(text: link));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Link copied to clipboard!')),
      );
    }
  }

  void _showQRCode(ProductAdsModel? product) {
    final link = _mediaUrls[0];
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Scan to view product'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // You can use qr_flutter package for QR code generation
              // QrImageView(data: link, size: 200),
              const SizedBox(height: 16),
              Text(
                product?.title ?? 'Product QR Code',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _initializeVideoIfNeeded(int index) async {
    await _disposeVideoControllers();

    if (_isVideoUrl(_mediaUrls[index])) {
      _isVideo = true;
      _videoController = VideoPlayerController.network(_mediaUrls[index])
        ..initialize().then((_) {
          setState(() {});
          _chewieController = ChewieController(
            videoPlayerController: _videoController!,
            autoPlay: false,
            looping: true,
            showControls: true,
            materialProgressColors: ChewieProgressColors(
              playedColor: Colors.blue,
              handleColor: Colors.blueAccent,
              backgroundColor: Colors.grey,
              bufferedColor: Colors.grey.shade300,
            ),
          );
          setState(() {});
        });
    } else {
      _isVideo = false;
      if (_chewieController != null) {
        _chewieController!.dispose();
        _chewieController = null;
      }
      if (_videoController != null && _videoController!.value.isInitialized) {
        _videoController!.pause();
        _videoController!.dispose();
      }
    }
  }

  bool _isVideoUrl(String url) {
    final videoExtensions = [
      '.mp4',
      '.mov',
      '.avi',
      '.wmv',
      '.flv',
      '.webm',
      '.mkv',
    ];
    final uri = Uri.parse(url);
    final path = uri.path.toLowerCase();
    return videoExtensions.any((ext) => path.endsWith(ext));
  }

  @override
  void dispose() {
    _pageController.dispose();
    if (_chewieController != null) _chewieController!.dispose();
    if (_videoController != null && _videoController!.value.isInitialized)
      _videoController?.dispose();
    super.dispose();
  }

  void _onSellerProfileView() async {
    try {
      var response = await AuthService().authGet(
        'seller-ratings/${widget.product.userId}',
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        Map<String, dynamic> jsonList = json.decode(response.body);

        Map<String, dynamic> distJson = jsonList['rating_distribution'];

        Map<int, int> ratingDistribution = distJson.map(
          (key, value) => MapEntry(int.parse(key), value as int),
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SellerProfilePage(
              userId: product.userId,
              name: product.userName ?? '',
              location: 'N/A',
              memberSince: product.userCreatedAt ?? '',
              publishedAds: product.activeAds ?? 0,
              imageUrl: "${product.userImage!}",
              averageRating: (jsonList['average_rating'] as num).toDouble(),
              totalRatings: jsonList['total_ratings'],
              hasUserRated: jsonList['has_user_rated'],
              ratingDistribution: ratingDistribution,
            ),
          ),
        );
      } else {
        throw Exception(
          'Failed to seller info. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error fetching ads: $e');
    }
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
          // Enhanced Image Carousel
          SliverAppBar(
            expandedHeight: 380,
            pinned: true,
            backgroundColor: const Color.fromARGB(0, 0, 83, 226),
            leading: Container(
              margin: const EdgeInsets.only(left: 8, top: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 20,
                ),
                padding: const EdgeInsets.all(6),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            actions: [
              // Video Play/Pause Button
              if (_isVideo)
                Container(
                  margin: const EdgeInsets.only(right: 8, top: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(
                      _chewieController?.isPlaying ?? false
                          ? Icons.pause
                          : Icons.play_arrow,
                      color: Colors.white,
                      size: 20,
                    ),
                    padding: const EdgeInsets.all(6),
                    onPressed: () {
                      if (_chewieController != null) {
                        if (_chewieController!.isPlaying) {
                          _chewieController!.pause();
                        } else {
                          _chewieController!.play();
                        }
                        setState(() {});
                      }
                    },
                  ),
                ),
              Container(
                margin: const EdgeInsets.only(right: 8, top: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  shape: BoxShape.circle,
                ),
                // child: IconButton(
                //   icon: const Icon(Icons.share, color: Colors.white, size: 20),
                //   padding: const EdgeInsets.all(6),
                //   onPressed: () {
                //     _shareProduct();
                //   },
                // ),
              ),
            ],
            toolbarHeight: 56,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  // Enhanced Media Carousel (Images + Video)
                  GestureDetector(
                    onTap: () {
                      if (!_isVideo) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ImageZoomScreen(
                              images: photos,
                              initialIndex: _currentIndex > 0
                                  ? _currentIndex - 1
                                  : 0,
                            ),
                          ),
                        );
                      }
                    },
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() {
                          _currentIndex = index;
                          _initializeVideoIfNeeded(index);
                        });
                      },
                      itemCount: _mediaUrls.length,
                      itemBuilder: (context, index) {
                        final mediaUrl = _mediaUrls[index];

                        if (_isVideoUrl(mediaUrl)) {
                          // Video Player
                          return Container(
                            color: Colors.black,
                            child: Stack(
                              children: [
                                if (_chewieController != null &&
                                    _currentIndex == index)
                                  Chewie(controller: _chewieController!)
                                else
                                  Center(
                                    child: CircularProgressIndicator(
                                      color: Colors.blue,
                                    ),
                                  ),

                                // Video overlay with play button if not playing
                              ],
                            ),
                          );
                        } else {
                          // Image
                          return Hero(
                            tag: 'image_$mediaUrl',
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.black.withOpacity(0.1),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                              child: Image.network(
                                mediaUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  color: Colors.grey.shade100,
                                  alignment: Alignment.center,
                                  child: Icon(
                                    Icons.broken_image,
                                    size: 60,
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ),

                  // Media Type Indicator
                  Positioned(
                    top: 80,
                    left: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _isVideo ? Icons.videocam : Icons.photo,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _isVideo ? 'Video' : 'Image',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Enhanced Media Counter
                  Positioned(
                    top: 80,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${_currentIndex + 1}/${_mediaUrls.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),

                  // Enhanced Thumbnails
                  if (_mediaUrls.length > 1)
                    Positioned(
                      bottom: 20,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 70,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _mediaUrls.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            final mediaUrl = _mediaUrls[index];
                            final isVideo = _isVideoUrl(mediaUrl);

                            return GestureDetector(
                              onTap: () {
                                _pageController.animateToPage(
                                  index,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _currentIndex == index
                                        ? Colors.white
                                        : Colors.transparent,
                                    width: _currentIndex == index ? 3 : 0,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Stack(
                                    children: [
                                      if (isVideo)
                                        // Video thumbnail with play icon
                                        Container(
                                          color: Colors.black,
                                          child: Center(
                                            child: Icon(
                                              Icons.play_circle_filled,
                                              color: Colors.white.withOpacity(
                                                0.8,
                                              ),
                                              size: 30,
                                            ),
                                          ),
                                        )
                                      else
                                        // Image thumbnail
                                        Image.network(
                                          mediaUrl,
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          height: double.infinity,
                                          errorBuilder: (_, __, ___) =>
                                              Container(
                                                color: Colors.grey.shade100,
                                                alignment: Alignment.center,
                                                child: Icon(
                                                  Icons.broken_image,
                                                  size: 60,
                                                  color: Colors.grey.shade400,
                                                ),
                                              ),
                                        ),

                                      // Video indicator badge
                                      if (isVideo)
                                        Positioned(
                                          top: 4,
                                          right: 4,
                                          child: Container(
                                            padding: const EdgeInsets.all(2),
                                            decoration: BoxDecoration(
                                              color: Colors.black.withOpacity(
                                                0.7,
                                              ),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              Icons.videocam,
                                              color: Colors.white,
                                              size: 12,
                                            ),
                                          ),
                                        ),

                                      if (_currentIndex == index)
                                        Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            color: Colors.white.withOpacity(
                                              0.2,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          // Enhanced Content Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  // Featured Badge
                  if (product.status == "featured")
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star, size: 14, color: Colors.white),
                          SizedBox(width: 4),
                          Text(
                            "Featured",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 16),

                  // Title and Price
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          height: 1.3,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "${product.price} ${product.currency}",
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF00C853),
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Location and Date
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.location_on,
                            size: 18,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  if (product.latitude != null &&
                                      product.longitude != null) {
                                    _launchGoogleMaps(
                                      product.latitude!,
                                      product.longitude!,
                                    );
                                  }
                                },
                                child: Text(
                                  product.location ?? "Unknown",
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.blue,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    size: 14,
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
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Expandable Details Section
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          onTap: () {
                            setState(() => _showMore = !_showMore);
                          },
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.info_outline,
                              color: Colors.blue,
                              size: 20,
                            ),
                          ),
                          title: const Text(
                            "Product Details",
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                          trailing: Icon(
                            _showMore
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            color: Colors.blue,
                          ),
                        ),
                        if (_showMore) ...[
                          const Divider(height: 1),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                if (product.condition != null)
                                  _buildDetailRow(
                                    "Condition",
                                    product.condition!,
                                    Icons.construction,
                                  ),
                                if (product.availableLocations != null &&
                                    product.availableLocations!.isNotEmpty)
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 12),
                                      const Text(
                                        "Available Locations:",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: product.availableLocations!
                                            .map(
                                              (loc) => Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 6,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: Colors.green.shade50,
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                  border: Border.all(
                                                    color:
                                                        Colors.green.shade100,
                                                  ),
                                                ),
                                                child: Text(
                                                  loc,
                                                  style: TextStyle(
                                                    color:
                                                        Colors.green.shade800,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                            )
                                            .toList(),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Description
                  const Text(
                    "Description",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      product.description ?? "No description provided",
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.6,
                        color: Colors.black87,
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Enhanced Seller Info
                  const Text(
                    "Seller Information",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue.shade50, Colors.white],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.blue.shade100),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.blue.shade200,
                              width: 2,
                            ),
                          ),
                          child: ClipOval(
                            child: product.userImage != null
                                ? Image.network(
                                    product.userImage!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        decoration: BoxDecoration(
                                          color: Colors.grey[300],
                                          shape: BoxShape
                                              .circle, // or BoxShape.rectangle for square
                                        ),
                                        child: Icon(
                                          Icons
                                              .person, // or Icons.image, Icons.broken_image, etc.
                                          color: Colors.grey[600],
                                          size: 24,
                                        ),
                                      );
                                    },
                                  )
                                : Container(
                                    color: Colors.grey.shade200,
                                    child: const Icon(
                                      Icons.person,
                                      size: 28,
                                      color: Colors.grey,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.userName ?? "Unknown",
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    size: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    "Member since ${product.userCreatedAt ?? 'N/A'}",
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Icon(
                                    Icons.shopping_bag,
                                    size: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    "${product.activeAds} active ads",
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            onPressed: _onSellerProfileView,
                            icon: const Icon(
                              Icons.person_outline,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Report Button
                  Center(
                    child: OutlinedButton.icon(
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
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey.shade700,
                        side: BorderSide(color: Colors.grey.shade400),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.flag, size: 16),
                      label: const Text(
                        "Report this Ad",
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Related Ads
                  ProductSection(
                    title: "Related Ads",
                    onViewAll: () {},
                    isShowViewAll: false,
                    products: items,
                  ),

                  const SizedBox(height: 32),

                  // Safety Tips
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.orange.shade50, Colors.red.shade50],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.orange,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.security,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              "Safety First!",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Colors.orange,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildSafetyTip("Meet in public, crowded places"),
                        _buildSafetyTip(
                          "Never go alone - take someone with you",
                        ),
                        _buildSafetyTip(
                          "Inspect the product thoroughly before buying",
                        ),
                        _buildSafetyTip(
                          "Never pay in advance or transfer money",
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),

      bottomNavigationBar: !isMyAd
          ? BottomButtons(
              productAdId: product.id,
              productCreaterId: product.userId,
              productPrice: product.price,
            )
          : null,
    );
  }

  Widget _buildDetailRow(String title, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSafetyTip(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6, right: 8),
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Colors.orange,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade800,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BottomButtons extends StatefulWidget {
  final int? productAdId;
  final int? productCreaterId;
  final String productPrice;

  const BottomButtons({
    super.key,
    this.productAdId,
    this.productPrice = '0',
    this.productCreaterId,
  });

  @override
  _BottomButtonsState createState() => _BottomButtonsState();
}

class _BottomButtonsState extends State<BottomButtons> {
  bool _isOrderLoading = false;
  bool _isChatLoading = false;

  void _onOrderSubmit() async {
    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => OrderConfirmationDialog(
        productPrice: widget.productPrice,
        productTitle:
            "Product Title", // You'll need to pass the actual product title
        onOrderConfirm: (data) {
          // This will be called when the user confirms the order
          _processOrder(data);
        },
      ),
    );

    if (confirmed == true) {
      // Order was confirmed, show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Order placed successfully!'),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _processOrder(Map<String, dynamic> data) async {
    setState(() {
      _isOrderLoading = true;
    });

    try {
      final response = await AuthService().authPost(
        "order/create",
        body: jsonEncode({
          'ad_id': widget.productAdId,
          'price': widget.productPrice,
          'quantity': 1,
          ...data,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        await Future.delayed(const Duration(seconds: 2));

        if (!mounted) return;

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MyOrdersPage()),
        );
      } else {
        _showErrorSnackBar('Failed to create order');
      }
    } catch (e) {
      print(e);
      _showErrorSnackBar('Error creating order');
    } finally {
      if (mounted) setState(() => _isOrderLoading = false);
    }
  }

  void _onChatSubmit() async {
    setState(() {
      _isChatLoading = true;
    });

    try {
      final response = await AuthService().authPost(
        "chat-session/create",
        body: jsonEncode({
          'ad_id': widget.productAdId,
          "reciver_id": widget.productCreaterId,
          "type": 'buyer',
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);
        final chatSession = ChatSessionModel.fromJson(responseData);

        await _initializeFirebaseSession(chatSession);

        if (!mounted) return;

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatMessagingPage(chatSession: chatSession),
          ),
        );
      } else {
        print('Failed to create chat session: ${response.body}');
        _showErrorSnackBar('Failed to start chat');
      }
    } catch (e) {
      print('Error creating chat session: $e');
      _showErrorSnackBar('Error starting chat');
    } finally {
      if (mounted) setState(() => _isChatLoading = false);
    }
  }

  Future<void> _initializeFirebaseSession(ChatSessionModel chatSession) async {
    try {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      final sessionId = chatSession.sessionId ?? 'chat_${chatSession.chatId}';

      final roomDoc = await firestore
          .collection('chatSessions')
          .doc(sessionId)
          .get();

      if (!roomDoc.exists) {
        final currentUser = AuthService.getCurrentUser;

        await firestore.collection('chatSessions').doc(sessionId).set({
          'chatId': chatSession.chatId,
          'sessionId': sessionId,
          'sessionToken': chatSession.sessionToken,
          'type': chatSession.type,
          'participants': {
            currentUser?.id.toString(): {
              'name': currentUser?.name,
              'avatar': currentUser?.image,
            },
            chatSession.partnerId.toString(): {
              'name': chatSession.partnerName,
              'email': chatSession.partnerEmail,
              'avatar': chatSession.partnerAvatar,
            },
          },
          'adInfo': {
            'adId': chatSession.adId,
            'adTitle': chatSession.adTitle,
            'adPrice': chatSession.adPrice,
            'adPhoto': chatSession.adPhoto,
          },
          'createdAt': DateTime.now().millisecondsSinceEpoch,
          'lastMessage': null,
          'lastUpdated': DateTime.now().millisecondsSinceEpoch,
        });
      }
    } catch (e) {
      print('Error initializing Firebase session: $e');
      // Continue anyway - Firebase session might initialize later
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Call Button - Minimal Icon Button
            _buildIconButton(
              icon: Icons.phone_outlined,
              color: Colors.blue,
              onPressed: _showCallOptions,
            ),

            const SizedBox(width: 12),

            // Chat Button - Primary Action
            Expanded(
              child: _buildActionButton(
                icon: Icons.chat_bubble_outline_rounded,
                text: "Chat",
                isLoading: _isChatLoading,
                isPrimary: true,
                onPressed: _onChatSubmit,
              ),
            ),

            const SizedBox(width: 12),

            // Order Button - Accent Action
            Expanded(
              child: _buildActionButton(
                icon: Icons.shopping_bag_outlined,
                text: "Order Now",
                isLoading: _isOrderLoading,
                isPrimary: false,
                onPressed: _onOrderSubmit,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2), width: 1.5),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, color: color, size: 22),
        padding: EdgeInsets.zero,
        splashRadius: 20,
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String text,
    required bool isLoading,
    required bool isPrimary,
    required VoidCallback onPressed,
  }) {
    final backgroundColor = isPrimary
        ? const Color(0xFF0053E2)
        : const Color(0xFFFFC220);

    return Container(
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          if (!isLoading)
            BoxShadow(
              color: backgroundColor.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 18,
                    color: isPrimary ? Colors.white : Colors.black,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isPrimary ? Colors.white : Colors.black,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  void _showCallOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          margin: const EdgeInsets.all(20),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),

                // Content
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.grey.shade200,
                              width: 1,
                            ),
                          ),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.phone_rounded,
                              color: Colors.blue,
                              size: 24,
                            ),
                            SizedBox(width: 12),
                            Text(
                              "Contact Seller",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Options
                      _buildCallOption(
                        icon: Icons.phone_rounded,
                        title: "Voice Call",
                        subtitle: "Call the seller directly",
                        color: Colors.blue,
                        onTap: () {
                          Navigator.pop(context);
                          // Implement phone call
                        },
                      ),

                      _buildCallOption(
                        icon: Icons.message_rounded,
                        title: "Send Message",
                        subtitle: "Send SMS to seller",
                        color: Colors.green,
                        onTap: () {
                          Navigator.pop(context);
                          // Implement SMS
                        },
                      ),

                      _buildCallOption(
                        icon: Icons.videocam_rounded,
                        title: "Video Call",
                        subtitle: "Start video conversation",
                        color: Colors.purple,
                        onTap: () {
                          Navigator.pop(context);
                          // Implement video call
                        },
                      ),

                      // Close button
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.grey.shade600,
                              side: BorderSide(color: Colors.grey.shade300),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text(
                              "Cancel",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCallOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1A1A1A),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
      ),
      trailing: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.arrow_forward_ios_rounded,
          size: 14,
          color: Colors.grey.shade600,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
                  imageProvider: NetworkImage("${widget.images[index]}"),
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
