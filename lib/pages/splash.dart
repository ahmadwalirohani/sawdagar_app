import 'package:afghan_bazar/pages/intro.dart';
import 'package:flutter/material.dart';
import 'package:afghan_bazar/config/config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/next_screen.dart';
import 'home.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  afterSplash() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? isFirstLaunch = prefs.getBool('isFirstLaunch');
    print(isFirstLaunch);
    //  final SignInBloc sb = context.read<SignInBloc>();
    Future.delayed(Duration(milliseconds: 1500)).then((value) async {
      await prefs.setBool('isFirstLaunch', false);
      if (isFirstLaunch == null || isFirstLaunch) {
        gotoIntroPage();
      } else {
        gotoHomePage();
      }
    });
  }

  Future<bool> _isFirstLaunch() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? isFirstLaunch = prefs.getBool('isFirstLaunch');

    if (isFirstLaunch == null || isFirstLaunch) {
      await prefs.setBool('isFirstLaunch', false);
      return true; // Show intro screen
    }
    return false; // Do not show intro screen
  }

  gotoHomePage() {
    nextScreenReplace(context, HomePage());
  }

  gotoIntroPage() {
    nextScreenCloseOthers(context, IntroPage());
  }

  @override
  void initState() {
    afterSplash();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).canvasColor,
      body: Center(
        child: Image(
          image: AssetImage(Config().splashIcon),
          height: 120,
          width: 120,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
