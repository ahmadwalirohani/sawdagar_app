import 'package:flutter/material.dart';

void showFullScreenCategoryDialog(
  BuildContext context, {
  required void Function(String selectedCategory) onCategorySelected,
}) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: "Categories",
    pageBuilder: (_, __, ___) {
      return CategoryDialogFullScreen(onCategorySelected: onCategorySelected);
    },
    transitionDuration: const Duration(milliseconds: 300),
    transitionBuilder: (_, animation, __, child) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      );
    },
  );
}

class CategoryDialogFullScreen extends StatefulWidget {
  final void Function(String) onCategorySelected;

  const CategoryDialogFullScreen({super.key, required this.onCategorySelected});

  @override
  _CategoryDialogFullScreenState createState() =>
      _CategoryDialogFullScreenState();
}

class _CategoryDialogFullScreenState extends State<CategoryDialogFullScreen> {
  String? selectedCategory;

  @override
  Widget build(BuildContext context) {
    // List of categories
    final List<CategoryItem> popularCategories = [
      CategoryItem(name: 'Mobiles', imagePath: 'assets/images/ic_mobiles.png'),
      CategoryItem(name: 'Vehicles', imagePath: 'assets/images/ic_motors.png'),
      CategoryItem(name: 'Jobs', imagePath: 'assets/images/ic_jobs.png'),
      CategoryItem(
        name: 'Property for Sales',
        imagePath: 'assets/images/ic_property.png',
      ),
    ];

    final List<CategoryItem> allCategories = [
      ...popularCategories,
      CategoryItem(
        name: 'Services',
        imagePath: 'assets/images/ic_services.png',
      ),
      CategoryItem(name: 'Animals', imagePath: 'assets/images/ic_animals.png'),
      CategoryItem(
        name: 'Property for Rent',
        imagePath: 'assets/images/ic_property_for_rent.png',
      ),
      CategoryItem(
        name: 'Furnitures & Home Decoration',
        imagePath: 'assets/images/ic_furniture.png',
      ),
      CategoryItem(
        name: 'Electronics & Home Appliances',
        imagePath: 'assets/images/ic_electronics.png',
      ),
      CategoryItem(
        name: 'Books, Sports & Hobbies',
        imagePath: 'assets/images/ic_books.png',
      ),
      CategoryItem(
        name: 'Business, Industrial & Agriculture',
        imagePath: 'assets/images/ic_business_industrial.png',
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    "All Categories",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const Divider(height: 0),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      "All Categories",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ..._buildCategoryList(context, allCategories),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildCategoryList(
    BuildContext context,
    List<CategoryItem> items,
  ) {
    return List.generate(items.length, (index) {
      final item = items[index];

      bool isSelected = item.name == selectedCategory; // Check if it's selected

      return Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(vertical: 6),
            tileColor: isSelected
                ? Colors.blue.shade50
                : null, // Highlight selected item
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(item.imagePath, fit: BoxFit.contain),
              ),
            ),
            title: Text(
              item.name,
              style: TextStyle(
                fontWeight: isSelected
                    ? FontWeight.bold
                    : FontWeight.normal, // Bold the selected text
                color: isSelected
                    ? Colors.blue
                    : null, // Change color of selected text
              ),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              setState(() {
                selectedCategory = item.name; // Update selected category
              });
              widget.onCategorySelected(
                item.name,
              ); // Pass the selected category back to the parent
              Navigator.of(context).pop();
            },
          ),
          const Divider(height: 1),
        ],
      );
    });
  }
}

class CategoryItem {
  final String name;
  final String imagePath;

  CategoryItem({required this.name, required this.imagePath});
}
