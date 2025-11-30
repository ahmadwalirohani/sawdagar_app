import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:line_icons/line_icons.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:afghan_bazar/pages/explore.dart';
import 'package:afghan_bazar/pages/my_orders_page.dart';
import 'package:afghan_bazar/pages/sell_product_page.dart';
import 'package:afghan_bazar/pages/chat_page.dart';
import 'package:afghan_bazar/pages/account_profile_page.dart';
import 'package:afghan_bazar/pages/login_page.dart';
import 'package:afghan_bazar/services/auth_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> with TickerProviderStateMixin {
  int _currentIndex = 0;
  double _fabScale = 1.0;

  final PageController _pageController = PageController();

  /// Lazy loaded pages
  final List<Widget?> _pages = List.generate(5, (_) => null);

  late AnimationController _waveController;
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  // Theme-aware colors
  Color _getNavBackground(BuildContext context) {
    final theme = Theme.of(context);
    return theme.colorScheme.surface;
  }

  Color _getNavItemColor(BuildContext context) {
    final theme = Theme.of(context);
    return theme.colorScheme.onSurface.withOpacity(0.6);
  }

  Color _getSelectedItemColor(BuildContext context) {
    return const Color(0xFF0053E2); // Your brand blue
  }

  Color _getFloatingButtonColor(BuildContext context) {
    return const Color(0xFFFFC220); // Your brand orange/yellow
  }

  Gradient _getFabGradient(BuildContext context) {
    return const LinearGradient(
      colors: [Color(0xFFFFC220), Color(0xFFFFB20D)], // Orange gradient
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  Color _getNavShadowColor(BuildContext context) {
    final theme = Theme.of(context);
    return Colors.black.withOpacity(
      theme.brightness == Brightness.dark ? 0.4 : 0.15,
    );
  }

  @override
  void initState() {
    super.initState();

    _waveController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(_glowController);

    _loadPage(0); // Load home page initially
  }

  @override
  void dispose() {
    _pageController.dispose();
    _waveController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  /// Lazy loads the page ONLY when needed
  void _loadPage(int index) {
    if (_pages[index] != null) return;

    switch (index) {
      case 0:
        _pages[0] = const Explore();
        break;
      case 1:
        _pages[1] = const MyOrdersPage();
        break;
      case 2:
        _pages[2] = const MarketplaceSellPage();
        break;
      case 3:
        _pages[3] = const ChatPage();
        break;
      case 4:
        _pages[4] = const AccountPage();
        break;
    }
  }

  Future<void> _handleBack() async {
    if (_currentIndex != 0) {
      _animateToPage(0);
    } else {
      await SystemChannels.platform.invokeMethod('SystemNavigator.pop');
    }
  }

  void _animateToPage(int index) {
    _loadPage(index);

    setState(() => _currentIndex = index);

    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _onTabTapped(int index) async {
    if (await AuthService.isLoggedIn() || index == 0) {
      _waveController.forward(from: 0.0);
      _animateToPage(index);
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (_) => AuthPage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) _handleBack();
      },
      child: Scaffold(
        backgroundColor: theme.colorScheme.surface,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: _buildFAB(context),
        bottomNavigationBar: _buildBottomNavBar(context),
        body: PageView.builder(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 5,
          onPageChanged: (index) {
            setState(() => _currentIndex = index);
          },
          itemBuilder: (_, index) {
            _loadPage(index);
            return _pages[index]!;
          },
        ),
      ),
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: _getNavBackground(context),
        boxShadow: [
          BoxShadow(
            color: _getNavShadowColor(context),
            blurRadius: 20,
            offset: const Offset(0, -2),
          ),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: isDark
            ? Border.all(color: theme.colorScheme.outline.withOpacity(0.1))
            : null,
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(context, 0, LineIcons.home, "home"),
          _navItem(context, 1, LineIcons.clipboardList, "Orders"),
          const SizedBox(width: 68),
          _navItem(context, 3, LineIcons.facebookMessenger, "Chats"),
          _navItem(context, 4, LineIcons.user, "Account"),
        ],
      ),
    );
  }

  Widget _navItem(
    BuildContext context,
    int index,
    IconData icon,
    String label,
  ) {
    final bool selected = _currentIndex == index;
    final selectedColor = _getSelectedItemColor(context);
    final navItemColor = _getNavItemColor(context);

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => _onTabTapped(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? selectedColor.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              duration: const Duration(milliseconds: 300),
              scale: selected ? 1.2 : 1.0,
              child: Icon(
                icon,
                color: selected ? selectedColor : navItemColor,
                size: 22,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: TextStyle(
                color: selected ? selectedColor : navItemColor,
                fontSize: selected ? 12 : 11,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
              child: Text(label.tr()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAB(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final fabColor = _getFloatingButtonColor(context);

    return Transform.translate(
      offset: const Offset(0, -10),
      child: AnimatedBuilder(
        animation: _glowAnimation,
        builder: (_, child) {
          return Transform.scale(
            scale: _fabScale * _glowAnimation.value,
            child: child,
          );
        },
        child: Container(
          height: 68,
          width: 68,
          decoration: BoxDecoration(
            gradient: _getFabGradient(context),
            shape: BoxShape.circle,
            border: Border.all(
              color: isDark ? theme.colorScheme.surface : Colors.white,
              width: 4,
            ),
            boxShadow: [
              BoxShadow(
                color: fabColor.withOpacity(isDark ? 0.5 : 0.4),
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
              if (isDark)
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(34),
            onTap: () {
              setState(() => _currentIndex = 2);
              _animateToPage(2);
              _fabScale = 1.0;
            },
            onTapDown: (_) => setState(() => _fabScale = 0.85),
            onTapCancel: () => setState(() => _fabScale = 1.0),
            child: const Icon(
              LineIcons.shoppingCart,
              color: Colors.white,
              size: 30,
            ),
          ),
        ),
      ),
    );
  }
}
