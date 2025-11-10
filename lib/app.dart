import 'package:afghan_bazar/blocs/chat_sessions_bloc.dart';
import 'package:afghan_bazar/blocs/favorites_ads_bloc.dart';
import 'package:afghan_bazar/blocs/my_ads_bloc.dart';
import 'package:afghan_bazar/blocs/my_orders_bloc.dart';
import 'package:afghan_bazar/blocs/product_related_ads_bloc.dart';
import 'package:afghan_bazar/blocs/product_search_bloc.dart';
import 'package:afghan_bazar/blocs/trending_ads_bloc.dart';
import 'package:afghan_bazar/blocs/user_published_ads_bloc.dart';
import 'package:flutter/material.dart';
import 'package:afghan_bazar/blocs/category_tab6_bloc.dart';
import 'package:afghan_bazar/pages/splash.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'blocs/categories_bloc.dart';
import 'blocs/category_tab3_bloc.dart';
import 'blocs/category_tab4_bloc.dart';
import 'blocs/weekly_bloc.dart';
import 'blocs/featured_bloc.dart';
import 'blocs/popular_articles_bloc.dart';
import 'blocs/recent_articles_bloc.dart';
import 'blocs/related_articles_bloc.dart';
import 'blocs/search_bloc.dart';
import 'blocs/tab_index_bloc.dart';
import 'blocs/theme_bloc.dart';
import 'models/theme_model.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ThemeBloc>(
      create: (_) => ThemeBloc(),
      child: Consumer<ThemeBloc>(
        builder: (_, mode, child) {
          return MultiProvider(
            providers: [
              ChangeNotifierProvider<TrendingAdsBloc>(
                create: (context) => TrendingAdsBloc(),
              ),
              ChangeNotifierProvider<FavoritesAdsBloc>(
                create: (context) => FavoritesAdsBloc(),
              ),
              // ChangeNotifierProvider<BookmarkBloc>(
              //   create: (context) => BookmarkBloc(),
              // ),
              ChangeNotifierProvider<ChatSessionsBloc>(
                create: (context) => ChatSessionsBloc(),
              ),
              ChangeNotifierProvider<FeaturedBloc>(
                create: (context) => FeaturedBloc(),
              ),
              ChangeNotifierProvider<PopularBloc>(
                create: (context) => PopularBloc(),
              ),
              ChangeNotifierProvider<RecentBloc>(
                create: (context) => RecentBloc(),
              ),
              ChangeNotifierProvider<CategoriesBloc>(
                create: (context) => CategoriesBloc(),
              ),
              // ChangeNotifierProvider<AdsBloc>(create: (context) => AdsBloc()),
              ChangeNotifierProvider<RelatedBloc>(
                create: (context) => RelatedBloc(),
              ),
              ChangeNotifierProvider<TabIndexBloc>(
                create: (context) => TabIndexBloc(),
              ),
              ChangeNotifierProvider<ProductSearchBloc>(
                create: (context) => ProductSearchBloc(),
              ),
              ChangeNotifierProvider<MyOrdersBloc>(
                create: (context) => MyOrdersBloc(),
              ),
              ChangeNotifierProvider<CategoryTab6Bloc>(
                create: (context) => CategoryTab6Bloc(),
              ),
              ChangeNotifierProvider<UserPublishedAdsBloc>(
                create: (context) => UserPublishedAdsBloc(),
              ),
              ChangeNotifierProvider<ProductRelatedAdsBloc>(
                create: (context) => ProductRelatedAdsBloc(),
              ),
              ChangeNotifierProvider<MyAdsBloc>(
                create: (context) => MyAdsBloc(),
              ),
              ChangeNotifierProvider<CategoryTab3Bloc>(
                create: (context) => CategoryTab3Bloc(),
              ),
              ChangeNotifierProvider<CategoryTab4Bloc>(
                create: (context) => CategoryTab4Bloc(),
              ),
              ChangeNotifierProvider<WeeklyBloc>(
                create: (context) => WeeklyBloc(),
              ),
            ],

            child: MaterialApp(
              supportedLocales: [
                Locale('en'),
                Locale('ps'),
                Locale('ar'),
                Locale('fa'),
              ],
              localizationsDelegates: context.localizationDelegates,
              locale: context.locale,
              //navigatorObservers: [firebaseObserver],
              theme: ThemeModel().lightMode,
              darkTheme: ThemeModel().darkMode,
              themeMode: mode.darkTheme == true
                  ? ThemeMode.dark
                  : ThemeMode.light,
              debugShowCheckedModeBanner: false,
              home: /*HomePage()), */ SplashPage(),
            ),
          );
        },
      ),
    );
  }
}
