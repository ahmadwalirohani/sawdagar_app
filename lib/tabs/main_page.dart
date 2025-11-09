import 'package:afghan_bazar/blocs/trending_ads_bloc.dart';
import 'package:afghan_bazar/pages/discover_products_page.dart';
import 'package:flutter/material.dart';
import 'package:afghan_bazar/widgets/ads_slider.dart';
import 'package:afghan_bazar/widgets/product_categories.dart';
import 'package:afghan_bazar/widgets/product_card.dart';
import 'package:provider/provider.dart';

import '../widgets/search_bar.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  void initState() {
    super.initState();
    // load data once when page opens
    final bloc = context.read<TrendingAdsBloc>();
    bloc.getData(category: "Mobiles");
    bloc.getData(category: "Vehicles");
    bloc.getData(category: "Bikes");
    bloc.getData(category: "Houses");
    bloc.getData(category: "Fashion");
    bloc.getData(category: "Jobs");
  }

  Widget build(BuildContext context) {
    final bloc = context.watch<TrendingAdsBloc>();

    final List<CategoryItem> categories = [
      CategoryItem(
        name: 'Mobiles',
        imagePath: 'assets/images/ic_mobiles.png',
        onTap: () => {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DiscoverProductPage(category: 'Mobiles'),
            ),
          ),
        },
      ),
      CategoryItem(
        name: 'Services',
        imagePath: 'assets/images/ic_services.png',
        onTap: () => {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DiscoverProductPage(category: 'Services'),
            ),
          ),
        },
      ),
      CategoryItem(
        name: 'Vehicles',
        imagePath: 'assets/images/ic_motors.png',
        onTap: () => {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DiscoverProductPage(category: 'Vehicles'),
            ),
          ),
        },
      ),
      CategoryItem(
        name: 'Jobs',
        imagePath: 'assets/images/ic_jobs.png',
        onTap: () => {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DiscoverProductPage(category: 'Jobs'),
            ),
          ),
        },
      ),
      CategoryItem(
        name: 'Property for Sales',
        imagePath: 'assets/images/ic_property.png',
        onTap: () => {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  DiscoverProductPage(category: 'Property for Sales'),
            ),
          ),
        },
      ),
      CategoryItem(
        name: 'Animals',
        imagePath: 'assets/images/ic_animals.png',
        onTap: () => {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DiscoverProductPage(category: 'Animals'),
            ),
          ),
        },
      ),
      CategoryItem(
        name: 'Property for Rent',
        imagePath: 'assets/images/ic_property_for_rent.png',
        onTap: () => {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  DiscoverProductPage(category: 'Property for Rent'),
            ),
          ),
        },
      ),
      CategoryItem(
        name: 'Furnitures & Home Decoration',
        imagePath: 'assets/images/ic_furniture.png',
        onTap: () => {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  DiscoverProductPage(category: 'Furnitures & Home Decoration'),
            ),
          ),
        },
      ),
      CategoryItem(
        name: 'Electornices & Home Applainces',
        imagePath: 'assets/images/ic_electronics.png',
        onTap: () => {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DiscoverProductPage(
                category: 'Electornices & Home Applainces',
              ),
            ),
          ),
        },
      ),
      CategoryItem(
        name: 'Fashion and Beauty',
        imagePath: 'assets/images/ic_fashion.png',
        onTap: () => {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  DiscoverProductPage(category: 'Fashion and Beauty'),
            ),
          ),
        },
      ),
      CategoryItem(
        name: 'Bikes',
        imagePath: 'assets/images/ic_bikes.png',
        onTap: () => {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DiscoverProductPage(category: 'Bikes'),
            ),
          ),
        },
      ),

      CategoryItem(
        name: 'Books ,Sports &  Hobbies',
        imagePath: 'assets/images/ic_books.png',
        onTap: () => {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  DiscoverProductPage(category: 'Books ,Sports &  Hobbies'),
            ),
          ),
        },
      ),
      CategoryItem(
        name: 'Bussiness ,Industrial & Agriculture',
        imagePath: 'assets/images/ic_business_industrial.png',
        onTap: () => {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DiscoverProductPage(
                category: 'Bussiness ,Industrial & Agriculture',
              ),
            ),
          ),
        },
      ),
      CategoryItem(
        name: 'Kids',
        imagePath: 'assets/images/ic_for_kids.png',
        onTap: () => {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DiscoverProductPage(category: 'Kids'),
            ),
          ),
        },
      ),
    ];

    return RefreshIndicator(
      onRefresh: () async {
        context.read<TrendingAdsBloc>().onRefresh('Mobiles');
      },
      child: SingleChildScrollView(
        key: PageStorageKey('key0'),
        padding: EdgeInsets.all(0),
        physics: AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            CustomSearchBar(),
            AdsSlider(),
            const SizedBox(height: 10),
            ProductCategories(
              categories: categories,
              itemsPerRow:
                  4, // Shows 4 items per row (2 rows total for 8 items)
              itemWidth: 80, // Makes cards more compact
              itemHeight: 105,
            ),
            ProductSection(
              title: "Mobile Phones",

              onViewAll: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DiscoverProductPage(category: 'Mobiles'),
                  ),
                );
              },
              products: bloc.getAds("Mobiles"),
            ),
            ProductSection(
              title: "Cars",
              onViewAll: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DiscoverProductPage(category: 'Vehicles'),
                  ),
                );
              },
              products: bloc.getAds("Vehicles"),
            ),
            ProductSection(
              title: "Bikes & Motorcycles",
              onViewAll: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DiscoverProductPage(category: 'Bikes'),
                  ),
                );
              },
              products: bloc.getAds("Bikes"),
            ),
            ProductSection(
              title: "Houses",
              onViewAll: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DiscoverProductPage(category: 'Houses'),
                  ),
                );
              },
              products: bloc.getAds("Houses"),
            ),
            ProductSection(
              title: "Fashion & Beauty",
              onViewAll: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DiscoverProductPage(category: 'Mobiles'),
                  ),
                );
              },
              products: bloc.getAds("Fashion"),
            ),
            ProductSection(
              title: "Jobs",
              onViewAll: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DiscoverProductPage(category: 'Mobiles'),
                  ),
                );
              },
              products: bloc.getAds("Jobs"),
            ),
          ],
        ),
      ),
    );
  }
}
