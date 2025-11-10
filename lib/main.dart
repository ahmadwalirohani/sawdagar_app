// @dart=2.12
import 'dart:io';
import 'package:afghan_bazar/firebase_options.dart';
import 'package:afghan_bazar/services/auth_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'app.dart';
import 'constants/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await AuthService.init();

  Directory directory = await getApplicationDocumentsDirectory();
  Hive.init(directory.path);
  await Hive.openBox(Constants.notificationTag);
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark));
  runApp(EasyLocalization(
    supportedLocales: const [
      Locale('en'),
      Locale('ps'),
      Locale('ar'),
      Locale('fa')
    ],
    path: 'assets/translations',
    fallbackLocale: const Locale('en'),
    startLocale: const Locale('en'),
    useOnlyLangCode: true,
    child: MyApp(),
  ));
}

// import 'package:flutter/material.dart';
// import 'package:line_icons/line_icons.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Modern Amazon Nav',
//       theme: ThemeData(
//         useMaterial3: true,
//         colorScheme: ColorScheme.fromSeed(
//           seedColor: const Color(0xFF232F3E),
//           brightness: Brightness.light,
//         ),
//       ),
//       home: const MyHomePage(),
//       debugShowCheckedModeBanner: false,
//     );
//   }
// }

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key});

//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   int _selectedIndex = 0;
//   double _fabScale = 1.0;

//   // Colors
//   final Color _navBackground = const Color(0xFF131A22);
//   final Color _navItemColor = const Color(0xFFCCCCCC);
//   final Color _selectedItemColor = const Color(0xFFFEBE10);
//   final Color _floatingButtonColor = const Color(0xFFFF9900);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(_getPageName(_selectedIndex)),
//         centerTitle: true,
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               _getPageIcon(_selectedIndex),
//               size: 60,
//               color: _selectedItemColor,
//             ),
//             const SizedBox(height: 20),
//             Text(
//               _getPageName(_selectedIndex),
//               style: const TextStyle(fontSize: 24),
//             ),
//           ],
//         ),
//       ),
//       bottomNavigationBar: _buildModernNavBar(),
//       floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
//       floatingActionButton: _buildAnimatedFAB(),
//     );
//   }

//   Widget _buildModernNavBar() {
//     return Container(
//       decoration: BoxDecoration(
//         color: _navBackground,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 10,
//             spreadRadius: 1,
//           ),
//         ],
//       ),
//       child: Padding(
//         padding: const EdgeInsets.only(top: 8.0),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceAround,
//           children: [
//             _buildNavItem(0, LineIcons.home, "Home"),
//             _buildNavItem(1, LineIcons.clipboardList, "Orders"),
//             const SizedBox(width: 68), // Increased space for larger FAB
//             _buildNavItem(3, LineIcons.facebookMessenger, "Chats"),
//             _buildNavItem(4, LineIcons.user, "Account"),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildNavItem(int index, IconData icon, String label) {
//     bool isSelected = _selectedIndex == index;
//     return Material(
//       color: Colors.transparent,
//       child: InkWell(
//         borderRadius: BorderRadius.circular(8),
//         splashColor: _selectedItemColor.withOpacity(0.2),
//         highlightColor: _selectedItemColor.withOpacity(0.1),
//         onTap: () => setState(() => _selectedIndex = index),
//         child: SizedBox(
//           width: 70,
//           child: Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Icon(
//                   icon,
//                   color: isSelected ? _selectedItemColor : _navItemColor,
//                   size: 24,
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   label,
//                   style: TextStyle(
//                     color: isSelected ? _selectedItemColor : _navItemColor,
//                     fontSize: 12,
//                     fontWeight: isSelected
//                         ? FontWeight.w600
//                         : FontWeight.normal,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildAnimatedFAB() {
//     return Transform.translate(
//       offset: const Offset(0, -12),
//       child: Transform.scale(
//         scale: _fabScale,
//         child: Container(
//           height: 68, // 20% larger than before
//           width: 68,
//           decoration: BoxDecoration(
//             color: _floatingButtonColor,
//             shape: BoxShape.circle,
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.2),
//                 blurRadius: 8,
//                 spreadRadius: 1,
//               ),
//             ],
//           ),
//           child: Material(
//             color: Colors.transparent,
//             child: InkWell(
//               borderRadius: BorderRadius.circular(34),
//               splashColor: Colors.white.withOpacity(0.3),
//               highlightColor: Colors.white.withOpacity(0.2),
//               onTap: () {
//                 setState(() {
//                   _selectedIndex = 2;
//                   _fabScale = 0.9;
//                 });
//                 Future.delayed(const Duration(milliseconds: 100), () {
//                   setState(() => _fabScale = 1.0);
//                 });
//               },
//               onTapDown: (_) => setState(() => _fabScale = 0.95),
//               onTapCancel: () => setState(() => _fabScale = 1.0),
//               child: Icon(
//                 LineIcons.shoppingCart,
//                 color: Colors.white,
//                 size: 30, // Larger icon
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   String _getPageName(int index) {
//     switch (index) {
//       case 0:
//         return "Home";
//       case 1:
//         return "Orders";
//       case 2:
//         return "Sell";
//       case 3:
//         return "Chats";
//       case 4:
//         return "Account";
//       default:
//         return "";
//     }
//   }

//   IconData _getPageIcon(int index) {
//     switch (index) {
//       case 0:
//         return LineIcons.home;
//       case 1:
//         return LineIcons.clipboardList;
//       case 2:
//         return LineIcons.shoppingCart;
//       case 3:
//         return LineIcons.facebookMessenger;
//       case 4:
//         return LineIcons.user;
//       default:
//         return LineIcons.question;
//     }
//   }
// }
