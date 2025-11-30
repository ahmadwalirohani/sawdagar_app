import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class AdsSlider extends StatefulWidget {
  const AdsSlider({super.key});

  @override
  State<AdsSlider> createState() => _AdsSliderState();
}

class _AdsSliderState extends State<AdsSlider> {
  int _currentIndex = 0;

  final List<String> images = [
    "https://img.freepik.com/free-psd/real-estate-house-sale-social-media-facebook-cover-template_106176-1452.jpg",
    "https://img.freepik.com/free-psd/modern-real-estate-house-sale-web-banner-template_120329-1187.jpg",
    "https://img.freepik.com/free-psd/real-estate-home-sale-facebook-cover-template_120329-1088.jpg",
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: 150, // adjust height
            autoPlay: true,
            enlargeCenterPage: true,
            viewportFraction: 0.9,
            onPageChanged: (index, reason) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
          items: images.map((url) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                url,
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder:
                    (
                      BuildContext context,
                      Object error,
                      StackTrace? stackTrace,
                    ) {
                      // Show an icon as fallback in case of an error
                      return const Icon(
                        Icons
                            .image_not_supported, // You can change this icon as needed
                        size: 100, // Adjust the icon size
                        color: Colors
                            .grey, // You can customize the icon color as well
                      );
                    },
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            images.length,
            (index) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentIndex == index ? 18 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: _currentIndex == index
                    ? const Color(0xFFFFC220)
                    : Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
