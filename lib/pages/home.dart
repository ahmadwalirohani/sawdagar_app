import 'dart:math';

import 'package:afghan_bazar/pages/account_profile_page.dart';
import 'package:afghan_bazar/pages/login_page.dart';
import 'package:afghan_bazar/pages/my_orders_page.dart';
import 'package:afghan_bazar/pages/sell_product_page.dart';
import 'package:afghan_bazar/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:line_icons/line_icons.dart';
import 'package:afghan_bazar/pages/explore.dart';
import 'package:afghan_bazar/pages/chat_page.dart';
import 'package:easy_localization/easy_localization.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  double _fabScale = 1.0;
  final PageController _pageController = PageController();

  // Colors
  final Color _navBackground =
      Colors.white; // const Color.fromARGB(255, 4, 24, 35);
  final Color _navItemColor = const Color.fromARGB(
    255,
    4,
    24,
    35,
  ); // const Color(0xFFCCCCCC);
  final Color _selectedItemColor = const Color.fromARGB(255, 210, 126, 0);
  final Color _floatingButtonColor = const Color(0xFFFF9900);

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future _onWillPop() async {
    if (_currentIndex != 0) {
      setState(() => _currentIndex = 0);
      _pageController.animateToPage(
        0,
        duration: Duration(milliseconds: 200),
        curve: Curves.easeIn,
      );
    } else {
      await SystemChannels.platform.invokeMethod<void>(
        'SystemNavigator.pop',
        true,
      );
    }
  }

  void onTabTapped(int index) async {
    //await AuthService.isLoggedIn() == true || index == 0
    if (await AuthService.isLoggedIn() == true || index == 0) {
      setState(() {
        _currentIndex = index;
      });
      _pageController.animateToPage(
        index,
        curve: Curves.easeIn,
        duration: Duration(milliseconds: 250),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AuthPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) {
        if (didPop) return;
        _onWillPop();
      },
      child: Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: _buildAnimatedFAB(),
        bottomNavigationBar: _buildModernNavBar(),
        body: PageView(
          controller: _pageController,
          allowImplicitScrolling: false,
          physics: NeverScrollableScrollPhysics(),
          children: <Widget>[
            Explore(),
            MyOrdersPage(),
            MarketplaceSellPage(),
            ChatPage(),
            AccountPage(),
          ],
        ),
      ),
    );
  }

  Widget _buildModernNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: _navBackground,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 3.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, LineIcons.home, "home"),
            _buildNavItem(1, LineIcons.clipboardList, "Orders"),
            const SizedBox(width: 68), // Space for FAB
            _buildNavItem(3, LineIcons.facebookMessenger, "Chats"),
            _buildNavItem(4, LineIcons.user, "Account"),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    bool isSelected = _currentIndex == index;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        splashColor: _selectedItemColor.withOpacity(0.2),
        highlightColor: _selectedItemColor.withOpacity(0.1),
        onTap: () => onTabTapped(index),
        child: SizedBox(
          width: 70,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: isSelected ? _selectedItemColor : _navItemColor,
                  size: 24,
                ),
                Text(
                  label.tr(), // Using localization
                  style: TextStyle(
                    color: isSelected ? _selectedItemColor : _navItemColor,
                    fontSize: 12,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedFAB() {
    return Transform.translate(
      offset: const Offset(0, 0),
      child: Transform.scale(
        scale: _fabScale,
        child: Container(
          height: 55,
          width: 55,
          decoration: BoxDecoration(
            color: _floatingButtonColor,
            shape: BoxShape.circle,
            border: BoxBorder.all(
              width: 4,
              style: BorderStyle.solid,
              color: Colors.white,
            ),
            // boxShadow: [
            //   BoxShadow(
            //     color: Colors.black.withOpacity(0.2),
            //     blurRadius: 8,
            //     spreadRadius: 1,
            //   ),
            // ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(34),
              splashColor: Colors.white.withOpacity(0.3),
              highlightColor: Colors.white.withOpacity(0.2),
              onTap: () {
                setState(() {
                  _currentIndex = 2;
                  _fabScale = 0.9;
                });
                _pageController.animateToPage(
                  2,
                  duration: Duration(milliseconds: 250),
                  curve: Curves.easeIn,
                );
                Future.delayed(const Duration(milliseconds: 100), () {
                  setState(() => _fabScale = 1.0);
                });
              },
              onTapDown: (_) => setState(() => _fabScale = 0.95),
              onTapCancel: () => setState(() => _fabScale = 1.0),
              child: Icon(
                LineIcons.shoppingCart,
                color: Colors.white,
                size: 35,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
