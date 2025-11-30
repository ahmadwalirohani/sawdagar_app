import 'package:flutter/material.dart';

class Config {
  final String appName = 'Sawdagar';
  final String splashIcon = 'assets/images/splash.png';
  final String supportEmail = '';
  final String privacyPolicyUrl = '';
  final String ourWebsiteUrl = '';
  final String iOSAppId = '000000';

  //social links
  static const String facebookPageUrl = '';
  static const String youtubeChannelUrl = '';
  static const String twitterUrl = '';

  //app theme color
  final Color appColor = const Color.fromARGB(255, 255, 194, 32);

  //Intro images
  final String introImage1 = 'assets/images/slide1.png';
  final String introImage2 = 'assets/images/slide2.png';
  final String introImage3 = 'assets/images/slide3.png';

  //animation files
  final String doneAsset = 'assets/animation_files/done.json';

  //Language Setup
  final List<String> languages = ['English', 'Pashto', 'Dari'];

  //initial categories - 4 only (Hard Coded : which are added already on your admin panel)
  final List initialCategories = [
    'Afghanistan',
    'Asia',
    'World',
    'analysis',
    'articles',
    'programs',
  ];
}
