import 'package:afghan_bazar/blocs/trending_ads_bloc.dart';
import 'package:afghan_bazar/pages/login_page.dart';
import 'package:afghan_bazar/services/auth_service.dart';
import 'package:afghan_bazar/widgets/no_ads_found.dart';
import 'package:afghan_bazar/widgets/product_details.dart';
import 'package:flutter/material.dart';
import 'package:afghan_bazar/models/product_ads_model.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ProductCard extends StatelessWidget {
  final ProductAdsModel product;
  final VoidCallback? onTap;
  final VoidCallback? onFavorite;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    // Default image (fallback) in case product.photos is empty or null
    String imageUrl = product.photos?.isNotEmpty == true
        ? product.photos![0]
        : 'https://via.placeholder.com/150';

    // Format price
    final priceFormatter = NumberFormat("#,##0", "en_US");
    final formattedPrice = product.price != null
        ? "${priceFormatter.format(double.parse(product.price))} ${product.currency ?? ''}"
        : "Price not available";

    // Format created date (assuming product.createdAt is DateTime or String ISO)
    String createdDate = "";
    if (product.createdAt != null) {
      try {
        final date = DateTime.parse(product.createdAt ?? '');
        createdDate = DateFormat("dd MMM yyyy").format(date);
      } catch (_) {}
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 260,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10), // less radius
          border: Border.all(
            color: Colors.grey.shade300,
            width: 1, // subtle border
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image + Featured
              SizedBox(
                height: 160,
                width: double.infinity,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: const Color(0xFFE9ECEF),
                          alignment: Alignment.center,
                          child: const Icon(Icons.image_not_supported_outlined),
                        ),
                      ),
                    ),
                    if (product.status == 'active')
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8D24A),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Featured',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // Details
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            formattedPrice, // 👈 formatted price
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: Color.fromARGB(255, 4, 24, 35),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () {
                            context.read<TrendingAdsBloc>().toggleFavorite(
                              product,
                              onUnauthorized: () => {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AuthPage(),
                                  ),
                                ),
                              },
                            );
                          },
                          icon: Icon(
                            product.isFavorite
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: const Color(0xFFF8D24A),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color.fromARGB(255, 4, 24, 35),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      product.location ?? 'Location not provided',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Condition: ${product.condition}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (createdDate.isNotEmpty)
                      Text(
                        "Posted on $createdDate", // 👈 created date
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProductSection extends StatelessWidget {
  final String title;
  final List<ProductAdsModel> products;
  final VoidCallback? onViewAll;
  final bool? isShowViewAll;

  const ProductSection({
    super.key,
    required this.title,
    required this.products,
    this.onViewAll,
    this.isShowViewAll = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Title Row
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: (isShowViewAll != null && isShowViewAll == true)
                ? 12
                : 5,
            vertical: (isShowViewAll != null && isShowViewAll == true) ? 5 : 5,
          ),
          child: Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              // if (isShowViewAll != null && isShowViewAll == true)
              //   TextButton(
              //     onPressed: onViewAll,
              //     child: const Text("View more"),
              //   ),
            ],
          ),
        ),
        // Horizontal Cards
        products.isEmpty
            ? const NoAdsFound(message: "No ads found in this category")
            : SizedBox(
                height: 300,
                child: ListView.separated(
                  padding: EdgeInsets.symmetric(
                    horizontal: (isShowViewAll != null && isShowViewAll == true)
                        ? 12
                        : 1,
                  ),
                  scrollDirection: Axis.horizontal,
                  itemCount: products.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, i) => ProductCard(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductDetails(
                            product: products[i], // Placeholder
                          ),
                        ),
                      );
                    },
                    product:
                        products[i], // Pass the product model to ProductCard
                  ),
                ),
              ),
      ],
    );
  }
}
