import 'package:afghan_bazar/pages/favorite_items_page.dart';
import 'package:afghan_bazar/tabs/main_page.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class Explore extends StatefulWidget {
  const Explore({super.key});

  @override
  _ExploreState createState() => _ExploreState();
}

class _ExploreState extends State<Explore>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  var scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      key: scaffoldKey,
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              automaticallyImplyLeading: false,
              centerTitle: false,
              title: SizedBox(
                height: 30,
                child: Image.asset(
                  context.locale.languageCode == 'en'
                      ? 'assets/images/hor-eng-colorful.png'
                      : 'assets/images/hor-pa-colorful.png', // Your logo path
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Text(
                      'Sawdagar',
                      style: TextStyle(
                        fontSize: 19.0,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
              ),
              elevation: 1,
              actions: <Widget>[
                IconButton(
                  icon: const Icon(Icons.favorite_border, size: 22),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FavoriteItemsPage(),
                      ),
                    );
                  },
                ),
                // IconButton(
                //   icon: Icon(LineIcons.bell, size: 25),
                //   onPressed: () {
                //     Navigator.push(
                //       context,
                //       MaterialPageRoute(
                //         builder: (context) => NotificationsPage(),
                //       ),
                //     );
                //   },
                // ),
                SizedBox(width: 5),
              ],
              pinned: true,
              floating: true,
              forceElevated: innerBoxIsScrolled,
            ),
          ];
        },
        body: MainPage(),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
