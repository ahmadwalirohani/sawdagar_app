import 'package:afghan_bazar/pages/favorite_items_page.dart';
import 'package:afghan_bazar/tabs/main_page.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:afghan_bazar/blocs/featured_bloc.dart';
import 'package:afghan_bazar/blocs/popular_articles_bloc.dart';
import 'package:afghan_bazar/blocs/recent_articles_bloc.dart';
import 'package:afghan_bazar/blocs/tab_index_bloc.dart';
import 'package:afghan_bazar/config/config.dart';
import 'package:afghan_bazar/utils/app_name.dart';
import 'package:afghan_bazar/widgets/drawer.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

class Explore extends StatefulWidget {
  const Explore({super.key});

  @override
  _ExploreState createState() => _ExploreState();
}

class _ExploreState extends State<Explore>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  var scaffoldKey = GlobalKey<ScaffoldState>();
  TabController? _tabController;

  final List<Tab> _tabs = [
    Tab(text: "explore".tr()),
    Tab(text: Config().initialCategories[0].toString().tr()),
    Tab(text: Config().initialCategories[1].toString().tr()),
    Tab(text: Config().initialCategories[2].toString().tr()),
    Tab(text: Config().initialCategories[3].toString().tr()),
    Tab(text: Config().initialCategories[4].toString().tr()),
    Tab(text: Config().initialCategories[5].toString().tr()),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController!.addListener(() {
      context.read<TabIndexBloc>().setTabIndex(_tabController!.index);
    });
    Future.delayed(Duration(milliseconds: 0)).then((value) {
      context.read<FeaturedBloc>().getData(context.locale);
      context.read<PopularBloc>().getData(context.locale);
      context.read<RecentBloc>().getData(mounted);
    });
  }

  @override
  void dispose() {
    _tabController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      drawer: DrawerMenu(),
      key: scaffoldKey,
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              automaticallyImplyLeading: false,
              centerTitle: false,
              titleSpacing: 0,
              title: AppName(fontSize: 19.0),
              leading: IconButton(
                icon: Icon(
                  Icons.menu, //Feather.menu,
                  size: 25,
                ),
                onPressed: () {
                  scaffoldKey.currentState!.openDrawer();
                },
              ),
              elevation: 1,
              actions: <Widget>[
                IconButton(
                  icon: const Icon(
                    Icons.favorite_border, // AntDesign.search1,
                    size: 22,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FavoriteItemsPage(),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: Icon(LineIcons.bell, size: 25),
                  onPressed: () {
                    // nextScreen(context, Notifications());
                  },
                ),
                SizedBox(width: 5),
              ],
              pinned: true,
              floating: true,
              forceElevated: innerBoxIsScrolled,
            ),
          ];
        },
        body: MainPage(),
        //  Builder(
        //   builder: (BuildContext context) {
        //     final innerScrollController = PrimaryScrollController.of(context);
        //     return TabMedium(
        //       sc: innerScrollController,
        //       tc: _tabController,
        //       locale: context.locale,
        //     );
        //   },
        // ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
