import 'package:afghan_bazar/blocs/favorites_ads_bloc.dart';
import 'package:afghan_bazar/models/product_ads_model.dart';
import 'package:afghan_bazar/services/api_service.dart';
import 'package:afghan_bazar/services/auth_service.dart';
import 'package:afghan_bazar/widgets/product_details.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FavoriteItemsPage extends StatefulWidget {
  const FavoriteItemsPage({Key? key}) : super(key: key);

  @override
  State<FavoriteItemsPage> createState() => _FavoriteItemsPageState();
}

class _FavoriteItemsPageState extends State<FavoriteItemsPage> {
  @override
  void initState() {
    super.initState();
    // load data once when page opens
    final bloc = context.read<FavoritesAdsBloc>().getData(mounted);
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget build(BuildContext context) {
    final bloc = context.watch<FavoritesAdsBloc>();
    var items = bloc.getAds();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favourites', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        leading: const BackButton(color: Colors.black),
      ),
      body: ListView.separated(
        itemCount: items.length,
        padding: const EdgeInsets.all(12),
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = items[index];
          return FavoriteItemCard(ad: item);
        },
      ),
    );
  }
}

class FavoriteItemCard extends StatefulWidget {
  final ProductAdsModel ad;

  const FavoriteItemCard({Key? key, required this.ad}) : super(key: key);

  @override
  _FavoriteItemCardState createState() => _FavoriteItemCardState();
}

class _FavoriteItemCardState extends State<FavoriteItemCard> {
  late bool _isFavorite;
  final baseHost = AuthService.baseHost;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.ad.isFavorite;
  }

  void _toggleFavorite(int id) async {
    // Call setState only for the UI update
    setState(() {
      _isFavorite = !_isFavorite;
    });

    // Then await the async operation
    await ApiService.addOrRemoveFavorite(id);
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
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image + Badge
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      (ad.photos?.isNotEmpty ?? false)
                          ? "${baseHost}/${ad.photos!.first}"
                          : "https://via.placeholder.com/100",
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
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
                        style: TextStyle(color: Colors.grey[700], fontSize: 13),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        ad.location ?? 'No location',
                        style: TextStyle(color: Colors.grey[700], fontSize: 13),
                      ),
                    ),
                    if (ad.createdAt != null)
                      Text(
                        ad.createdAt!,
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      ),
                  ],
                ),
              ),
              // Favorite Icon
              IconButton(
                onPressed: () => _toggleFavorite(ad.id),
                icon: Icon(
                  _isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: _isFavorite ? Colors.red : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
