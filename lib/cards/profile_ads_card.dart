import 'package:afghan_bazar/models/product_ads_model.dart';
import 'package:afghan_bazar/services/auth_service.dart';
import 'package:flutter/material.dart';

class ProfileAdCard extends StatelessWidget {
  final ProductAdsModel adModel;
  final VoidCallback onTap;

  const ProfileAdCard({Key? key, required this.adModel, required this.onTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Fallback to first image if exists or a placeholder image
    String baseHost = AuthService.baseHost;
    String imageUrl = adModel.photos?.isNotEmpty == true
        ? "$baseHost/${adModel.photos![0]}"
        : "https://via.placeholder.com/150";

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      splashColor: Colors.teal.withOpacity(
        0.3,
      ), // Splash color with opacity for wave effect
      highlightColor: Colors.teal.withOpacity(
        0.1,
      ), // Highlight color when tapped
      radius: 30, // Optional: Control the radius of the splash (wave) effect
      child: Material(
        color: Colors.transparent, // Makes sure splash is above the card
        borderRadius: BorderRadius.circular(12),
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Image + Featured badge (badge on top of image)
                Flexible(
                  flex: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// Featured badge above image
                      if (adModel.isFavorite)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          margin: const EdgeInsets.only(bottom: 6),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade700,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            "Featured",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          imageUrl,
                          height: 110,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                /// Content
                Flexible(
                  flex: 6,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${adModel.currency} ${adModel.price}",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        adModel.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        adModel.condition,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        adModel.location ?? "Unknown Location",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        adModel.createdAt ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
