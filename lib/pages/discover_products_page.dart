import 'package:afghan_bazar/blocs/product_search_bloc.dart';
import 'package:afghan_bazar/pages/login_page.dart';
import 'package:afghan_bazar/services/auth_service.dart';
import 'package:afghan_bazar/utils/loading_cards.dart';
import 'package:afghan_bazar/widgets/category_list_dialog.dart';
import 'package:afghan_bazar/widgets/product_details.dart';
import 'package:afghan_bazar/widgets/product_filter_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DiscoverProductPage extends StatefulWidget {
  final String? category;

  const DiscoverProductPage({super.key, this.category});

  @override
  State<DiscoverProductPage> createState() => _DiscoverProductPageState();
}

class _DiscoverProductPageState extends State<DiscoverProductPage> {
  final bool _isListView = true;
  ScrollController? controller;
  String baseUrl = AuthService.baseHost;
  String? queryText = null;

  List<String>? _selectedLocations = [];
  String? _minPrice;
  String? _maxPrice;

  String selectedCategoryLabel = "Mobiles";

  void _updateSelectedCategory(String newCategory) {
    setState(() {
      selectedCategoryLabel = newCategory;
    });
    getFilterData(false);
  }

  void _searchFilterProducts(
    List<String>? locations,
    String? minPrice,
    String? maxPrice,
  ) {
    setState(() {
      _selectedLocations = locations;
      _minPrice = minPrice;
      _maxPrice = maxPrice;
    });
    getFilterData(false);
  }

  @override
  void initState() {
    super.initState();
    final productSearchBloc = context.read<ProductSearchBloc>();

    if (widget.category != null) {
      selectedCategoryLabel = widget.category ?? selectedCategoryLabel;
      productSearchBloc.clearData();
    }

    Future.delayed(Duration.zero).then((value) {
      controller = ScrollController()..addListener(_scrollListener);
      productSearchBloc.getData(
        true,
        category: selectedCategoryLabel,
        queryText: queryText,
      );
    });
  }

  @override
  void dispose() {
    controller?.removeListener(_scrollListener);
    ProductSearchBloc().clearData();
    super.dispose();
  }

  void _scrollListener() {
    final db = context.read<ProductSearchBloc>();
    if (!db.isLoading) {
      if (controller!.position.pixels == controller!.position.maxScrollExtent) {
        getFilterData(true);
      }
    }
  }

  void getFilterData(bool isScroll) {
    context.read<ProductSearchBloc>().setLoading(true);
    context.read<ProductSearchBloc>().getData(
      isScroll,
      category: selectedCategoryLabel,
      queryText: queryText,
      location: _selectedLocations?.join(',') ?? '',
      priceMin: _minPrice ?? '',
      priceMax: _maxPrice ?? '',
    );
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.watch<ProductSearchBloc>();
    var ads = bloc.getAds();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        flexibleSpace: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[100],
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 20,
                      color: Colors.black87,
                    ),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.all(8),
                    constraints: BoxConstraints(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!, width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      cursorColor: Colors.blueAccent,
                      decoration: InputDecoration(
                        hintText: "Search products...",
                        hintStyle: TextStyle(color: Colors.grey[500]),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: Colors.grey[500],
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                      ),
                      style: TextStyle(fontSize: 15, color: Colors.black87),
                      onChanged: (value) => {
                        setState(() {
                          queryText = value;
                        }),
                        getFilterData(false),
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        toolbarHeight: 70,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with filters
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // Filter Button
                _buildFilterButton(
                  icon: Icons.tune_rounded,
                  onTap: () => showFilterDialog(
                    context,
                    onFilterSearch: _searchFilterProducts,
                    locations: _selectedLocations,
                    minPrice: _minPrice,
                    maxPrice: _maxPrice,
                  ),
                ),
                const SizedBox(width: 8),

                // Category Filter
                FilterChipWidget(
                  label: selectedCategoryLabel,
                  onTap: () => showFullScreenCategoryDialog(
                    context,
                    onCategorySelected: _updateSelectedCategory,
                  ),
                ),

                const Spacer(),

                // Results Count
                Text(
                  "${ads.length} items",
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Products Grid/List
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                context.read<ProductSearchBloc>().onRefresh();
              },
              color: Colors.blueAccent,
              child: _isListView
                  ? _buildListView(ads, bloc)
                  : _buildGridView(ads),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: 20, color: Colors.grey[700]),
      ),
    );
  }

  Widget _buildListView(List<dynamic> ads, ProductSearchBloc bloc) {
    return ListView.builder(
      itemCount: ads.isNotEmpty ? ads.length + 1 : 5,
      controller: controller,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemBuilder: (context, index) {
        if (index < ads.length) {
          final ad = ads[index];
          return _buildProductCard(ad, context);
        } else {
          return Opacity(
            opacity: bloc.isLoading ? 1.0 : 0.0,
            child: LoadingCard(height: 120),
          );
        }
      },
    );
  }

  Widget _buildProductCard(dynamic ad, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductDetails(product: ad),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image
                _buildProductImage(ad),
                const SizedBox(width: 12),

                // Product Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Price
                      Text(
                        ad.price,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Title
                      Text(
                        ad.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),

                      // Location & Date
                      _buildMetaInfo(ad),
                    ],
                  ),
                ),

                // Favorite Button
                _buildFavoriteButton(ad, context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductImage(dynamic ad) {
    return Stack(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey[100],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              ad.photos?.first,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[200],
                  child: Icon(
                    Icons.photo_outlined,
                    color: Colors.grey[400],
                    size: 32,
                  ),
                );
              },
            ),
          ),
        ),
        if (ad.isFavorite)
          Positioned(
            top: 6,
            left: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.amber[400]!, Colors.amber[600]!],
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                "Featured",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMetaInfo(dynamic ad) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.location_on_outlined, size: 14, color: Colors.grey[500]),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                ad.location ?? 'No location',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(Icons.access_time_outlined, size: 14, color: Colors.grey[500]),
            const SizedBox(width: 4),
            Text(
              ad.createdAt ?? '',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFavoriteButton(dynamic ad, BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            context.read<ProductSearchBloc>().toggleFavorite(
              ad,
              onUnauthorized: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AuthPage()),
              ),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              shape: BoxShape.circle,
            ),
            child: Icon(
              ad.isFavorite
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              color: ad.isFavorite ? Colors.red[400] : Colors.grey[400],
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGridView(List<dynamic> ads) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      padding: EdgeInsets.all(16),
      itemCount: ads.length,
      controller: controller,
      itemBuilder: (context, index) {
        final ad = ads[index];
        return _buildGridProductCard(ad, context);
      },
    );
  }

  Widget _buildGridProductCard(dynamic ad, BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductDetails(product: ad),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Section
              Expanded(
                flex: 2,
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                        color: Colors.grey[100],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                        child: Image.network(
                          ad.photos?.first,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[200],
                              child: Icon(
                                Icons.photo_outlined,
                                color: Colors.grey[400],
                                size: 32,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    if (ad.isFavorite)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.amber[400]!, Colors.amber[600]!],
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            "Featured",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Info Section
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        ad.price,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        ad.title,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FilterChipWidget extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const FilterChipWidget({super.key, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
            const SizedBox(width: 6),
            Icon(Icons.expand_more_rounded, size: 18, color: Colors.grey[600]),
          ],
        ),
      ),
    );
  }
}
