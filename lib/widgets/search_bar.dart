import 'package:afghan_bazar/pages/discover_products_page.dart';
import 'package:flutter/material.dart';
import 'package:afghan_bazar/utils/next_screen.dart';
import 'package:easy_localization/easy_localization.dart';

class CustomSearchBar extends StatelessWidget {
  const CustomSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      width: MediaQuery.of(context).size.width,
      child: GestureDetector(
        onTap: () {
          nextScreen(context, DiscoverProductPage());
        },
        child: Container(
          height: 42, // reduced height
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8), // slightly tighter radius
            border: Border.all(color: Colors.grey.shade300, width: 1),
          ),
          child: Row(
            children: [
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Search here'.tr(),
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 14, // smaller font
                  ),
                ),
              ),
              Container(
                height: 42,
                width: 42,
                decoration: const BoxDecoration(
                  color: const Color(0xFFFF9900),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                ),
                child: const Icon(
                  Icons.search,
                  color: Colors.white,
                  size: 20, // slightly smaller icon
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
