import 'package:afghan_bazar/blocs/theme_bloc.dart';
import 'package:afghan_bazar/pages/coming_soon_page.dart';
import 'package:afghan_bazar/pages/favorite_items_page.dart';
import 'package:afghan_bazar/pages/help_support_page.dart';
import 'package:afghan_bazar/pages/my_ads_page.dart';
import 'package:afghan_bazar/pages/setting_page.dart';
import 'package:afghan_bazar/services/auth_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          // Enhanced AppBar with gradient using your brand colors
          SliverAppBar(
            pinned: true,
            expandedHeight: 240,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF0053E2), Color(0xFF0039A6)],
                  ),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Subtle pattern overlay
                    _buildBackgroundPattern(),

                    // Profile info with glassmorphism effect
                    Positioned(
                      bottom: 20,
                      left: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            // Profile avatar with status indicator
                            Stack(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(0xFFFFC220),
                                        Color(0xFFFF9900),
                                      ],
                                    ),
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white,
                                    ),
                                    child: const CircleAvatar(
                                      radius: 30,
                                      backgroundColor: Color(0xFFFFC220),
                                      child: Icon(
                                        Icons.person,
                                        size: 35,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                // Online status indicator
                                Positioned(
                                  bottom: 2,
                                  right: 2,
                                  child: Container(
                                    width: 14,
                                    height: 14,
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade400,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Khan",
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "ID:12",
                                    style: TextStyle(
                                      color: const Color(0xFFFFC220),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Theme and Language switcher buttons
                            Row(
                              children: [
                                // Language selector
                                Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withOpacity(0.2),
                                  ),
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.language,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    onPressed: () =>
                                        _showLanguageDialog(context),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Theme toggler
                                Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withOpacity(0.2),
                                  ),
                                  child: IconButton(
                                    icon: Icon(
                                      context.watch<ThemeBloc>().darkTheme !=
                                                  null &&
                                              context
                                                      .watch<ThemeBloc>()
                                                      .darkTheme !=
                                                  true
                                          ? Icons.dark_mode
                                          : Icons.light_mode,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      context.read<ThemeBloc>().toggleTheme();
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Notification button
                                Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withOpacity(0.2),
                                  ),
                                  child: IconButton(
                                    icon: Badge(
                                      smallSize: 8,
                                      backgroundColor: Colors.red.shade400,
                                      child: const Icon(
                                        Icons.notifications_none,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                    onPressed: () {},
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Body content
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 24),

                // Quick actions with improved design
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.dashboard,
                            size: 18,
                            color: colorScheme.onSurface.withOpacity(0.6),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Quick Actions",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _quickAction(
                            context,
                            Icons.receipt_long,
                            "My Ads",
                            const Color(0xFF0053E2), // Blue
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MyAdsPage(),
                              ),
                            ),
                          ),
                          _quickAction(
                            context,
                            Icons.favorite_border,
                            "Favourites",
                            Colors.pink.shade500,
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FavoriteItemsPage(),
                              ),
                            ),
                          ),
                          _quickAction(
                            context,
                            Icons.shopping_cart_outlined,
                            "Cart",
                            const Color(0xFFFFC220), // Orange
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ComingSoonPage(),
                              ),
                            ),
                          ),
                          _quickAction(
                            context,
                            Icons.history,
                            "History",
                            Colors.green.shade600,
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ComingSoonPage(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Statistics section
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _statItem(
                        context,
                        "12",
                        "Active Ads",
                        Icons.sell_outlined,
                        const Color(0xFF0053E2), // Blue
                      ),
                      _statItem(
                        context,
                        "47",
                        "Favorites",
                        Icons.favorite_border,
                        Colors.pink,
                      ),
                      _statItem(
                        context,
                        "89%",
                        "Rating",
                        Icons.star_border,
                        const Color(0xFFFFC220), // Orange
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // List options with improved design
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _listTile(
                        context,
                        Icons.credit_card,
                        "Payment Options",
                        "Manage saved payment methods",
                        const Color(0xFF0053E2), // Blue
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ComingSoonPage(),
                          ),
                        ),
                      ),
                      _divider(context),
                      _listTile(
                        context,
                        Icons.settings,
                        "Settings",
                        "Privacy and manage account",
                        theme.iconTheme.color ?? Colors.grey.shade700,
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UserSettingsPage(),
                          ),
                        ),
                      ),
                      _divider(context),
                      _listTile(
                        context,
                        Icons.help_outline,
                        "Help & Support",
                        "Help center and legal terms",
                        const Color(0xFFFFC220), // Orange
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HelpSupportPage(),
                            ),
                          );
                        },
                      ),
                      _divider(context),
                      _listTile(
                        context,
                        Icons.logout,
                        "Logout",
                        "Sign out from your account",
                        Colors.red.shade500,
                        () => _showLogoutDialog(context),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // Footer
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Text(
                    "Version 1.0.0",
                    style: TextStyle(
                      color: colorScheme.onSurface.withOpacity(0.5),
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final theme = Theme.of(context);
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: theme.colorScheme.surface,
          title: Text(
            "Select Language",
            style: TextStyle(color: theme.colorScheme.onSurface),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _languageOption(context, "English", "en"),
              _languageOption(context, "Pashto", "ps"),
              _languageOption(context, "Arabic", "ar"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                "Cancel",
                style: TextStyle(color: theme.colorScheme.primary),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _languageOption(BuildContext context, String language, String code) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(Icons.language, color: theme.colorScheme.primary),
      title: Text(
        language,
        style: TextStyle(color: theme.colorScheme.onSurface),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: theme.colorScheme.onSurface.withOpacity(0.6),
      ),
      onTap: () async {
        Navigator.of(context).pop();
        if (language == 'English') {
          context.setLocale(const Locale('en'));
        } else if (language == 'Pashto') {
          context.setLocale(const Locale('ps'));
        } else if (language == 'Arabic') {
          context.setLocale(const Locale('ar'));
        }
      },
    );
  }

  Widget _buildBackgroundPattern() {
    return Opacity(
      opacity: 0.1,
      child: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/dark-honeycomb.png"),
            fit: BoxFit.cover,
            repeat: ImageRepeat.repeat,
          ),
        ),
      ),
    );
  }

  Widget _quickAction(
    BuildContext context,
    IconData icon,
    String title,
    Color color,
    Function onTap,
  ) {
    final theme = Theme.of(context);
    return Column(
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => onTap(),
          child: Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withOpacity(0.1), color.withOpacity(0.2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _statItem(
    BuildContext context,
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _listTile(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    Color color,
    Function onTap,
  ) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          color: theme.colorScheme.onSurface,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 13,
          color: theme.colorScheme.onSurface.withOpacity(0.6),
        ),
      ),
      trailing: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: theme.colorScheme.onSurface.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.arrow_forward_ios,
          size: 14,
          color: theme.colorScheme.onSurface.withOpacity(0.6),
        ),
      ),
      onTap: () => onTap(),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  Widget _divider(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(
        height: 1,
        color: theme.colorScheme.onSurface.withOpacity(0.1),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: theme.colorScheme.surface,
          title: Text(
            "Logout",
            style: TextStyle(color: theme.colorScheme.onSurface),
          ),
          content: Text(
            "Are you sure you want to logout?",
            style: TextStyle(color: theme.colorScheme.onSurface),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                "Cancel",
                style: TextStyle(color: theme.colorScheme.primary),
              ),
            ),
            TextButton(
              onPressed: () {
                AuthService.logout();
                Navigator.of(context).pop();
                // Add logout logic here
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text("Logout"),
            ),
          ],
        );
      },
    );
  }
}
