import 'package:flutter/material.dart';

class ProductCategories extends StatelessWidget {
  final List<CategoryItem> categories;
  final double itemWidth;
  final double itemHeight;
  final int itemsPerRow;
  final bool showDivider;

  const ProductCategories({
    Key? key,
    required this.categories,
    this.itemWidth = 80,
    this.itemHeight = 90,
    this.itemsPerRow = 5, // Items per row (total rows will be 2)
    this.showDivider = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Split categories into two rows
    final halfLength = (categories.length / 2).ceil();
    final firstRow = categories.sublist(0, halfLength);
    final secondRow = categories.sublist(halfLength);

    return Column(
      children: [
        SizedBox(
          height: itemHeight * 2,
          // Height for two rows
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // First row
                  Row(
                    children: firstRow
                        .map((category) => _buildCategoryCard(category))
                        .toList(),
                  ),
                  // Second row
                  Row(
                    children: secondRow
                        .map((category) => _buildCategoryCard(category))
                        .toList(),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        if (showDivider) const Divider(thickness: 1),
      ],
    );
  }

  Widget _buildCategoryCard(CategoryItem category) {
    return SizedBox(
      width: itemWidth,
      height: itemHeight,

      child: Column(
        children: [
          Card(
            elevation: 1,

            margin: const EdgeInsets.all(4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => category.onTap?.call(),
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      category.imagePath,
                      width: 50,
                      height: 50,
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 5),
            child: Text(
              category.name,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class CategoryItem {
  final String name;
  final String imagePath;
  final VoidCallback? onTap;

  CategoryItem({required this.name, required this.imagePath, this.onTap});
}
