import 'package:afghan_bazar/blocs/my_ads_bloc.dart';
import 'package:afghan_bazar/models/product_ads_model.dart';
import 'package:afghan_bazar/pages/edit_product_screen.dart';
import 'package:afghan_bazar/services/auth_service.dart';
import 'package:afghan_bazar/widgets/product_details.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum ProductStatus { active, sold, ordered, expired }

class MyAdsPage extends StatefulWidget {
  const MyAdsPage({Key? key}) : super(key: key);

  @override
  State<MyAdsPage> createState() => _MyAdsPageState();
}

class _MyAdsPageState extends State<MyAdsPage> {
  String sortBy = 'date_desc';
  String searchText = '';
  ProductStatus? status;

  @override
  void initState() {
    super.initState();

    final ads = context.read<MyAdsBloc>();

    // Fetch data with the optional category
    ads.getData(
      true,
      status: status.toString(),
      sortBy: sortBy,
      queryText: searchText,
    );
  }

  void filterRequest() {
    context.read<MyAdsBloc>().getData(
      true,
      status: status?.name,
      sortBy: sortBy,
      queryText: searchText,
    );
  }

  @override
  void dispose() {
    MyAdsBloc().clearData();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.watch<MyAdsBloc>();
    var ads = bloc.getAds();
    return Scaffold(
      appBar: AppBar(
        title: Text('My Ads'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (v) => {
              setState(() {
                sortBy = v;
              }),

              filterRequest(),
            }, // vm.setSort(s),
            itemBuilder: (_) => [
              PopupMenuItem(value: 'date_desc', child: Text('Newest')),
              PopupMenuItem(value: 'date_asc', child: Text('Oldest')),
              PopupMenuItem(value: 'price_asc', child: Text('Price ↑')),
              PopupMenuItem(value: 'price_desc', child: Text('Price ↓')),
            ],
            icon: Icon(Icons.sort),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 8.0,
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          onChanged: (v) => {
                            setState(() {
                              searchText = v;
                            }),
                            filterRequest(),
                          },
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.search),
                            hintText: 'Search by title or id',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      DropdownButton<ProductStatus?>(
                        value: status,
                        hint: Text('Status'),
                        items:
                            [
                                  null,
                                  ProductStatus.active,
                                  ProductStatus.ordered,
                                  ProductStatus.sold,
                                  ProductStatus.expired,
                                ]
                                .map(
                                  (s) => DropdownMenuItem(
                                    value: s,
                                    child: Text(
                                      s == null
                                          ? 'All'
                                          : s.toString().split('.').last,
                                    ),
                                  ),
                                )
                                .toList(),
                        onChanged: (ProductStatus? s) => {
                          setState(() {
                            status = s;
                          }),
                          filterRequest(),
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                ],
              ),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: Duration(milliseconds: 350),
                child: bloc.isLoading
                    ? Center(child: CircularProgressIndicator())
                    : !ads.isNotEmpty
                    ? Center(child: Text('No ads found'))
                    : _AdsList(ads: ads),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdsList extends StatelessWidget {
  List<ProductAdsModel> ads;
  _AdsList({required this.ads});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.all(12),
      itemBuilder: (c, i) => ItemsCard(ad: ads[i]),
      separatorBuilder: (_, __) => SizedBox(height: 10),
      itemCount: ads.length,
    );
  }
}

class ItemsCard extends StatefulWidget {
  final ProductAdsModel ad;

  const ItemsCard({Key? key, required this.ad}) : super(key: key);

  @override
  _ItemsCardState createState() => _ItemsCardState();
}

class _ItemsCardState extends State<ItemsCard> {
  late bool _isFavorite;
  final baseHost = AuthService.baseHost;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.ad.isFavorite;
  }

  @override
  Widget build(BuildContext context) {
    final ad = widget.ad;

    return InkWell(
      onTap: () {
        // Navigate to ProductDetails page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetails(
              product: ad, // Placeholder
            ),
          ),
        );
      },
      splashColor: Colors.teal.withOpacity(0.2),
      borderRadius: BorderRadius.circular(12),
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row for image + details + menu
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image + Badge
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          (ad.photos?.isNotEmpty ?? false)
                              ? "${ad.photos!.first}"
                              : "https://via.placeholder.com/100",
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (
                                BuildContext context,
                                Object error,
                                StackTrace? stackTrace,
                              ) {
                                return const Icon(
                                  Icons.image_outlined,
                                  size: 100,
                                  color: Colors.grey,
                                );
                              },
                        ),
                      ),
                      if (ad.status.toLowerCase() == "featured")
                        Positioned(
                          top: 6,
                          left: 6,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.amber,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              "FEATURED",
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 12),

                  // Text info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${ad.currency} ${ad.price}",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          ad.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 14),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            ad.condition,
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 13,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            ad.location ?? 'No location',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 13,
                            ),
                          ),
                        ),
                        if (ad.createdAt != null)
                          Text(
                            ad.createdAt!,
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Menu button
                  PopupMenuButton<String>(
                    onSelected: (s) async {
                      if (s == 'edit') {
                        // Navigate to edit screen
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                EditProductScreen(product: ad),
                          ),
                        );

                        // If product was updated, refresh the list
                        if (result == true) {
                          // Trigger refresh of ads list
                          final myAdsBloc = context.read<MyAdsBloc>();
                          myAdsBloc.getData(
                            true,
                            status: null,
                            sortBy: 'date_desc',
                            queryText: '',
                          );
                        }
                      } else if (s == 'delete') {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (c) => AlertDialog(
                            title: const Text('Delete ad?'),
                            content: Text(
                              'Are you sure you want to delete "${ad.title}"?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(c, false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(c, true),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );
                        if (confirmed == true) {
                          // Call delete API
                          final myAdsBloc = context.read<MyAdsBloc>();
                          final success = await myAdsBloc.deleteAd(ad.id!);

                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '"${ad.title}" deleted successfully',
                                ),
                              ),
                            );

                            // Refresh the list
                            myAdsBloc.getData(
                              true,
                              status: null,
                              sortBy: 'date_desc',
                              queryText: '',
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Failed to delete ad'),
                              ),
                            );
                          }
                        }
                      } else if (s == 'stats') {
                        // showModalBottomSheet(
                        //   context: context,
                        //   isScrollControlled: true,
                        //   builder: (c) => FractionallySizedBox(
                        //     heightFactor: 0.85,
                        //     child: ProductStatsSheet(product: ad),
                        //   ),
                        // );
                      }
                    },
                    itemBuilder: (_) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      // const PopupMenuItem(
                      //   value: 'stats',
                      //   child: Row(
                      //     children: [
                      //       Icon(Icons.analytics),
                      //       SizedBox(width: 8),
                      //       Text('View Stats'),
                      //     ],
                      //   ),
                      // ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete),
                            SizedBox(width: 8),
                            Text('Delete'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // ---- MINIMALIST BOOST BUTTON (bottom-right) ----
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text("Boost Ad"),
                        content: const Text(
                          "Boosting this ad will increase its visibility and show it as 'Featured'. Continue?",
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text("Cancel"),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "This feature is not yet implemented. Comming Soon",
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                            ),
                            child: const Text("Boost Now"),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.flash_on,
                    size: 16,
                    color: Colors.white,
                  ),
                  label: const Text(
                    "Boost",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 1,
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
