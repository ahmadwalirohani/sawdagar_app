import 'package:afghan_bazar/blocs/product_search_bloc.dart';
import 'package:afghan_bazar/blocs/trending_ads_bloc.dart';
import 'package:afghan_bazar/pages/login_page.dart';
import 'package:afghan_bazar/services/auth_service.dart';
import 'package:afghan_bazar/utils/loading_cards.dart';
import 'package:afghan_bazar/widgets/category_list_dialog.dart';
import 'package:afghan_bazar/widgets/product_details.dart';
import 'package:afghan_bazar/widgets/product_filter_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DiscoverProductPage extends StatefulWidget {
  final String? category; // Added category as an optional parameter

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

  String selectedCategoryLabel = "Mobiles"; // Default label

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

    Future.delayed(Duration(milliseconds: 0)).then((value) {
      controller = ScrollController()..addListener(_scrollListener);

      // Fetch data with the optional category
      productSearchBloc.getData(
        true,
        category: selectedCategoryLabel,
        queryText: queryText,
      );
    });
  }

  @override
  void dispose() {
    controller!.removeListener(_scrollListener);
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        flexibleSpace: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 22,
                    color: Colors.black87,
                  ),
                  onPressed: () {
                    Navigator.pop(context); // replace with your logic
                  },
                ),
                Expanded(
                  child: Container(
                    height: 46,
                    margin: EdgeInsets.only(left: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                        color: Colors.grey.shade400,
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: TextField(
                      cursorColor: Colors.blueAccent,
                      decoration: InputDecoration(
                        hintText: "Search something...",
                        hintStyle: TextStyle(color: Colors.grey.shade600),
                        prefixIcon: Icon(
                          Icons.search,
                          color: Colors.grey.shade600,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                      ),
                      style: TextStyle(fontSize: 16, color: Colors.black87),
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
          // Filters
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => {
                    showFilterDialog(
                      context,
                      onFilterSearch: _searchFilterProducts,
                      locations: _selectedLocations,
                      minPrice: _minPrice,
                      maxPrice: _maxPrice,
                    ),
                  },
                  icon: Icon(Icons.filter_list),
                  constraints:
                      BoxConstraints(), // Removes default size constraints
                ),
                const SizedBox(width: 8),
                FilterChipWidget(
                  label: selectedCategoryLabel,
                  onTap: () => {
                    showFullScreenCategoryDialog(
                      context,
                      onCategorySelected: _updateSelectedCategory,
                    ),
                  },
                ),
                // const SizedBox(width: 8),
                // FilterChipWidget(
                //   label: "Afghanistan",
                //   onTap: () => {showLocationDialog(context)},
                // ),
                const Spacer(),
              ],
            ),
          ),

          // // Delivery toggle
          // Container(
          //   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          //   color: Colors.grey[100],
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //     children: [
          //       Row(
          //         children: [
          //           const Icon(Icons.local_shipping, color: Colors.blue),
          //           const SizedBox(width: 6),
          //           const Text(
          //             "Buy with Delivery",
          //             style: TextStyle(fontWeight: FontWeight.w500),
          //           ),
          //           const SizedBox(width: 6),
          //           Container(
          //             padding: const EdgeInsets.symmetric(
          //               horizontal: 6,
          //               vertical: 2,
          //             ),
          //             decoration: BoxDecoration(
          //               color: Colors.red[100],
          //               borderRadius: BorderRadius.circular(5),
          //             ),
          //             child: const Text(
          //               "New",
          //               style: TextStyle(color: Colors.red, fontSize: 12),
          //             ),
          //           ),
          //         ],
          //       ),
          //       Switch(value: false, onChanged: (val) {}),
          //     ],
          //   ),
          // ),
          Row(
            children: [
              // Text with mixed styling
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "Showing: ",
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize: 13,
                            color: Colors.black,
                          ),
                        ),
                        TextSpan(
                          text:
                              "${ads.length} Results for $selectedCategoryLabel",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // View toggle buttons with elevated design
              Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // // List view button
                      // Container(
                      //   decoration: BoxDecoration(
                      //     color: _isListView ? Colors.blue[50] : Colors.white,
                      //     borderRadius: BorderRadius.only(
                      //       topLeft: Radius.circular(8),
                      //       bottomLeft: Radius.circular(8),
                      //     ),
                      //     boxShadow: [
                      //       BoxShadow(
                      //         color: Colors.black.withOpacity(0.05),
                      //         blurRadius: 2,
                      //         offset: Offset(0, 1),
                      //       ),
                      //     ],
                      //   ),
                      //   child: IconButton(
                      //     onPressed: () {
                      //       setState(() {
                      //         _isListView = true;
                      //       });
                      //     },
                      //     icon: Icon(
                      //       Icons.list,
                      //       size: 20,
                      //       color: _isListView ? Colors.blue : Colors.black54,
                      //     ),
                      //     padding: EdgeInsets.all(8),
                      //     style: IconButton.styleFrom(
                      //       shape: RoundedRectangleBorder(
                      //         borderRadius: BorderRadius.only(
                      //           topLeft: Radius.circular(8),
                      //           bottomLeft: Radius.circular(8),
                      //         ),
                      //       ),
                      //     ),
                      //   ),
                      // ),

                      // // Divider
                      // Container(width: 1, height: 24, color: Colors.grey[300]),

                      // Tiles view button
                      // Container(
                      //   decoration: BoxDecoration(
                      //     color: !_isListView ? Colors.blue[50] : Colors.white,
                      //     borderRadius: BorderRadius.only(
                      //       topRight: Radius.circular(8),
                      //       bottomRight: Radius.circular(8),
                      //     ),
                      //     boxShadow: [
                      //       BoxShadow(
                      //         color: Colors.black.withOpacity(0.05),
                      //         blurRadius: 2,
                      //         offset: Offset(0, 1),
                      //       ),
                      //     ],
                      //   ),
                      //   child: IconButton(
                      //     onPressed: () {
                      //       setState(() {
                      //         _isListView = false;
                      //       });
                      //     },
                      //     icon: Icon(
                      //       Icons.grid_view,
                      //       size: 20,
                      //       color: !_isListView ? Colors.blue : Colors.black54,
                      //     ),
                      //     padding: EdgeInsets.all(8),
                      //     style: IconButton.styleFrom(
                      //       shape: RoundedRectangleBorder(
                      //         borderRadius: BorderRadius.only(
                      //           topRight: Radius.circular(8),
                      //           bottomRight: Radius.circular(8),
                      //         ),
                      //       ),
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Ads list with toggle functionality
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                context.read<ProductSearchBloc>().onRefresh();
              },
              child: _isListView
                  ? ListView.builder(
                      //itemCount: ads.length,
                      itemCount: ads.isNotEmpty ? ads.length + 1 : 5,
                      controller: controller,
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        if (index < ads.length) {
                          final ad = ads[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: InkWell(
                              // Added InkWell for ripple effect
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProductDetails(
                                      product: ad, // Placeholder
                                    ),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(10),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Image with Featured
                                  Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(10),
                                          bottomLeft: Radius.circular(10),
                                        ),
                                        child: Image.network(
                                          '${baseUrl}/${ad.photos?.first}',
                                          width: 120,
                                          height: 120,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                                return Container(
                                                  width: 120,
                                                  height: 120,
                                                  color: Colors.grey[300],
                                                  child: Icon(
                                                    Icons.broken_image,
                                                    color: Colors.grey[700],
                                                  ),
                                                );
                                              },
                                        ),
                                      ),
                                      if (ad.isFavorite)
                                        Positioned(
                                          top: 6,
                                          left: 6,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.amber,
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: const Text(
                                              "Featured",
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  // Info Section
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Price
                                          Text(
                                            ad.price,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          // Title
                                          Text(
                                            ad.title,
                                            style: const TextStyle(
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          // Location and Time
                                          Text(
                                            ad.location ?? '',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                          Text(
                                            ad.createdAt ?? '',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),

                                          // Seller Info
                                          // const SizedBox(height: 8),
                                          // Row(
                                          //   children: [
                                          //     CircleAvatar(
                                          //       radius: 16,
                                          //       backgroundImage: NetworkImage(
                                          //         ad.userImage ?? '',
                                          //       ), // Image URL or asset path
                                          //     ),
                                          //     const SizedBox(width: 8),
                                          //     Text(
                                          //       ad.userName ??
                                          //           '', // Seller name
                                          //       style: const TextStyle(
                                          //         fontSize: 11,
                                          //         fontWeight: FontWeight.w500,
                                          //       ),
                                          //     ),
                                          //   ],
                                          // ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  // Favorite button with separate InkWell
                                  InkWell(
                                    onTap: () {
                                      // Handle favorite button click separately
                                      context
                                          .read<ProductSearchBloc>()
                                          .toggleFavorite(
                                            ad,
                                            onUnauthorized: () => {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      AuthPage(),
                                                ),
                                              ),
                                            },
                                          );
                                      // Add to favorites logic here
                                    },
                                    borderRadius: BorderRadius.circular(20),

                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Icon(
                                        ad.isFavorite
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                        color: const Color(0xFFF8D24A),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        } else {
                          return Opacity(
                            opacity: bloc.isLoading ? 1.0 : 0.0,
                            child: LoadingCard(height: 250),
                          );
                        }
                      },
                    )
                  : GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.7,
                      ),
                      padding: EdgeInsets.all(12),
                      itemCount: ads.length,
                      controller: controller,
                      itemBuilder: (context, index) {
                        final ad = ads[index];
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: InkWell(
                            // Added InkWell for ripple effect
                            onTap: () {
                              // Handle item click here
                              print('Item $index clicked');
                              // Navigator.push(context, MaterialPageRoute(builder: (context) => DetailPage(ad: ad)));
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Image with Featured - FIXED HEIGHT
                                Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(12),
                                        topRight: Radius.circular(12),
                                      ),
                                      child: Image.asset(
                                        'assets/images/i_car.jpg',
                                        width: double.infinity,
                                        height: 120, // Fixed height
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    if (ad.isFavorite)
                                      Positioned(
                                        top: 6,
                                        left: 6,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.amber,
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                          ),
                                          child: const Text(
                                            "Featured",
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 10,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),

                                // Info Section - REMOVED Expanded, used Flexible with constraints
                                Flexible(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          ad.price,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Flexible(
                                          // Wrap text in Flexible to prevent overflow
                                          child: Text(
                                            ad.title,
                                            style: const TextStyle(
                                              fontSize: 12,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          ad.location ?? '',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        Text(
                                          ad.createdAt ?? '',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        // Seller Info
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            CircleAvatar(
                                              radius: 16,
                                              backgroundImage: NetworkImage(
                                                ad.userImage ?? '',
                                              ), // Image URL or asset path
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              ad.userName ?? '', // Seller name
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                // Favorite button - FIXED positioning with separate InkWell
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                      right: 8.0,
                                      bottom: 8.0, // Increased bottom padding
                                    ),
                                    child: InkWell(
                                      onTap: () {
                                        // Handle favorite button click separately
                                        print('Favorite button $index clicked');
                                        // Add to favorites logic here
                                      },
                                      borderRadius: BorderRadius.circular(20),
                                      child: Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Icon(
                                          Icons.favorite_border,
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
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
      onTap: onTap, // Makes it clickable
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade400), // Border added
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_drop_down, size: 20),
          ],
        ),
      ),
    );
  }
}
