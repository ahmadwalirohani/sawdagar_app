// //import 'dart:ffi' as ffi;

// import 'package:dots_indicator/dots_indicator.dart';
// import 'package:flutter/material.dart';
// import 'package:afghan_bazar/blocs/featured_bloc.dart';
// import 'package:afghan_bazar/blocs/theme_bloc.dart';
// import 'package:afghan_bazar/cards/featured_card.dart';
// import 'package:afghan_bazar/models/custom_color.dart';
// import 'package:afghan_bazar/utils/loading_cards.dart';
// import 'package:provider/provider.dart';

// class Featured extends StatefulWidget {
//   const Featured({super.key});

//   @override
//   _FeaturedState createState() => _FeaturedState();
// }

// class _FeaturedState extends State<Featured> {
//   int listIndex = 0;

//   @override
//   Widget build(BuildContext context) {
//     final fb = context.watch<FeaturedBloc>();
//     double w = MediaQuery.of(context).size.width;

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: <Widget>[
//         SizedBox(
//           height: 250,
//           width: w,
//           child: PageView.builder(
//             controller: PageController(initialPage: 0),
//             scrollDirection: Axis.horizontal,
//             itemCount: fb.data.isEmpty ? 1 : fb.data.length,
//             onPageChanged: (index) {
//               setState(() {
//                 listIndex = index;
//               });
//             },
//             itemBuilder: (BuildContext context, int index) {
//               if (fb.data.isEmpty) {
//                 if (fb.hasData == false) {
//                   return _EmptyContent();
//                 } else {
//                   return LoadingFeaturedCard();
//                 }
//               }
//               return FeaturedCard(d: fb.data[index], heroTag: 'featured$index');
//             },
//           ),
//         ),
//         SizedBox(height: 5),
//         Center(
//           child: DotsIndicator(
//             dotsCount: fb.data.isEmpty ? 5 : fb.data.length,
//             position: listIndex.toDouble(),
//             decorator: DotsDecorator(
//               color: Colors.black26,
//               activeColor: Theme.of(context).primaryColorDark,
//               spacing: EdgeInsets.only(left: 6),
//               size: Size.square(5.0),
//               activeSize: Size(20.0, 4.0),
//               activeShape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(5),
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

// class _EmptyContent extends StatelessWidget {
//   const _EmptyContent({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: EdgeInsets.all(15),
//       height: MediaQuery.of(context).size.height,
//       width: MediaQuery.of(context).size.width,
//       decoration: BoxDecoration(
//         color: context.watch<ThemeBloc>().darkTheme == false
//             ? CustomColor().loadingColorLight
//             : CustomColor().loadingColorDark,
//         borderRadius: BorderRadius.circular(5),
//       ),
//       child: Center(child: Text("No Contents found!")),
//     );
//   }
// }

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
                    ? const Color(0xFFFF9900)
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
