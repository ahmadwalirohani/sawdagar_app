import 'package:flutter/material.dart';
import 'package:afghan_bazar/config/config.dart';
import 'package:afghan_bazar/utils/app_name.dart';
import 'package:afghan_bazar/utils/next_screen.dart';
import 'package:afghan_bazar/pages/intro.dart';
import '../widgets/language.dart';
import 'package:easy_localization/easy_localization.dart';

class WelcomePage extends StatefulWidget {
  final String? tag;
  const WelcomePage({super.key, this.tag});

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  var scaffoldKey = GlobalKey<ScaffoldState>();
  // final RoundedLoadingButtonController _googleController =
  //     new RoundedLoadingButtonController();
  // final RoundedLoadingButtonController _facebookController =
  //     new RoundedLoadingButtonController();
  // final RoundedLoadingButtonController _appleController =
  //     new RoundedLoadingButtonController();
  // final Future<bool> _isAvailableFuture = TheAppleSignIn.isAvailable();

  handleSkip() {
    //final sb = context.read<SignInBloc>();
    //sb.setGuestUser();
    //nextScreen(context, DonePage());
  }

  // handleGoogleSignIn() async {
  //  // final SignInBloc sb = Provider.of<SignInBloc>(context, listen: false);
  //   await AppService().checkInternet().then((hasInternet) async {
  //     if (hasInternet == false) {
  //       openSnacbar(context, 'check your internet connection!'.tr());
  //     } else {
  //       await sb.signInWithGoogle().then((_) {
  //         if (sb.hasError == true) {
  //           openSnacbar(context, 'something is wrong. please try again.'.tr());
  //           _googleController.reset();
  //         } else {
  //           sb.checkUserExists().then((value) {
  //             if (value == true) {
  //               sb
  //                   .getUserDatafromFirebase(sb.uid)
  //                   .then((value) => sb.guestSignout())
  //                   .then((value) => sb
  //                       .saveDataToSP()
  //                       .then((value) => sb.setSignIn().then((value) {
  //                             _googleController.success();
  //                             handleAfterSignIn();
  //                           })));
  //             } else {
  //               sb.getTimestamp().then((value) => sb
  //                   .saveToFirebase()
  //                   .then((value) => sb.increaseUserCount())
  //                   .then((value) => sb.guestSignout())
  //                   .then((value) => sb
  //                       .saveDataToSP()
  //                       .then((value) => sb.setSignIn().then((value) {
  //                             _googleController.success();
  //                             handleAfterSignIn();
  //                           }))));
  //             }
  //           });
  //         }
  //       });
  //     }
  //   });
  // }

  // void handleFacebbokLogin() async {
  //   final SignInBloc sb = Provider.of<SignInBloc>(context, listen: false);
  //   await AppService().checkInternet().then((hasInternet) async {
  //     if (hasInternet == false) {
  //       openSnacbar(context, 'check your internet connection!'.tr());
  //     } else {
  //       await sb.signInwithFacebook().then((_) {
  //         if (sb.hasError == true) {
  //           openSnacbar(context, 'error fb login'.tr());
  //           _facebookController.reset();
  //         } else {
  //           sb.checkUserExists().then((value) {
  //             if (value == true) {
  //               sb
  //                   .getUserDatafromFirebase(sb.uid)
  //                   .then((value) => sb.guestSignout())
  //                   .then((value) => sb
  //                       .saveDataToSP()
  //                       .then((value) => sb.setSignIn().then((value) {
  //                             _facebookController.success();
  //                             handleAfterSignIn();
  //                           })));
  //             } else {
  //               sb.getTimestamp().then((value) => sb
  //                   .saveToFirebase()
  //                   .then((value) => sb.increaseUserCount())
  //                   .then((value) => sb.guestSignout().then((value) => sb
  //                       .saveDataToSP()
  //                       .then((value) => sb.setSignIn().then((value) {
  //                             _facebookController.success();
  //                             handleAfterSignIn();
  //                           })))));
  //             }
  //           });
  //         }
  //       });
  //     }
  //   });
  // }

  // handleAppleSignIn() async {
  //   final sb = context.read<SignInBloc>();
  //   await AppService().checkInternet().then((hasInternet) async {
  //     if (hasInternet == false) {
  //       openSnacbar(context, 'check your internet connection!'.tr());
  //     } else {
  //       await sb.signInWithApple().then((_) {
  //         if (sb.hasError == true) {
  //           openSnacbar(context, 'something is wrong. please try again.'.tr());
  //           _appleController.reset();
  //         } else {
  //           sb.checkUserExists().then((value) {
  //             if (value == true) {
  //               sb
  //                   .getUserDatafromFirebase(sb.uid)
  //                   .then((value) => sb.guestSignout())
  //                   .then((value) => sb
  //                       .saveDataToSP()
  //                       .then((value) => sb.setSignIn().then((value) {
  //                             _appleController.success();
  //                             handleAfterSignIn();
  //                           })));
  //             } else {
  //               sb.getTimestamp().then((value) => sb
  //                   .saveToFirebase()
  //                   .then((value) => sb.increaseUserCount())
  //                   .then((value) => sb.saveDataToSP().then((value) => sb
  //                       .guestSignout()
  //                       .then((value) => sb.setSignIn().then((value) {
  //                             _appleController.success();
  //                             handleAfterSignIn();
  //                           })))));
  //             }
  //           });
  //         }
  //       });
  //     }
  //   });
  // }

  handleAfterSignIn() {
    setState(() {
      Future.delayed(Duration(milliseconds: 1000)).then((f) {
        // gotoNextScreen();
      });
    });
  }

  // gotoNextScreen() {
  //   if (widget.tag == null) {
  //     nextScreen(context, DonePage());
  //   } else {
  //     Navigator.pop(context);
  //   }
  // }

  @override
  void initState() {
    Future.delayed(
      Duration(milliseconds: 2000),
    ).then((value) => nextScreenCloseOthers(context, IntroPage()));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            alignment: Alignment.center,
            padding: EdgeInsets.all(0),
            iconSize: 22,
            icon: Icon(Icons.language),
            onPressed: () {
              nextScreenPopup(context, LanguagePopup());
            },
          ),
        ],
      ),
      backgroundColor: Theme.of(context).canvasColor,
      body: SafeArea(
        bottom: true,
        child: SizedBox(
          height: double.infinity,
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Flexible(
                flex: 3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Image(image: AssetImage(Config().splashIcon), height: 130),
                    SizedBox(height: 50),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'welcome to',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w300,
                                color: Theme.of(context).secondaryHeaderColor,
                              ),
                            ).tr(),
                            SizedBox(width: 10),
                            AppName(fontSize: 25),
                            SizedBox(width: 10),
                            Text(
                              'ته',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w300,
                                color: Theme.of(context).secondaryHeaderColor,
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 30,
                            right: 30,
                            top: 5,
                          ),
                          child: Text(
                            '',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).secondaryHeaderColor,
                            ),
                          ).tr(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Flexible(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 10),
                    const SizedBox(height: 10),
                    Container(),
                  ],
                ),
              ),
              //Text("don't have social accounts?").tr(),
              // ElevatedButton(
              //   style: ElevatedButton.styleFrom(
              //     backgroundColor: Colors.blue, // Background color
              //     //  foregroundBuilder: Colors.white, // Text color
              //     padding: EdgeInsets.symmetric(
              //         vertical: 10.0, horizontal: 40.0), // Button padding
              //     shape: RoundedRectangleBorder(
              //       borderRadius: BorderRadius.circular(8.0), // Rounded corners
              //     ),
              //     elevation: 5, // Shadow effect
              //   ),
              //   onPressed: () => handleSkip(),
              //   child: Text(
              //     'Start',
              //     style: TextStyle(fontSize: 18), // Text style
              //   ),
              // ),
              // TextButton(
              //   child: Text(
              //     '',
              //     style: TextStyle(color: Theme.of(context).primaryColor),
              //   ).tr(),
              //   onPressed: () {
              //     // if (widget.tag == null) {
              //     //   nextScreen(context, SignUpPage());
              //     // } else {
              //     //   nextScreen(
              //     //       context,
              //     //       SignUpPage(
              //     //         tag: 'Popup',
              //     //       ));
              //     // }
              //   },
              // ),
              SizedBox(height: 15),
              // PrivacyInfo(),
              SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }
}
