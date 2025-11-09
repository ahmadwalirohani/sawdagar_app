import 'package:flutter/material.dart';
//import 'package:flutter_icons/flutter_icons.dart';
import 'package:afghan_bazar/blocs/sign_in_bloc.dart';
import 'package:afghan_bazar/blocs/theme_bloc.dart';
import 'package:afghan_bazar/config/config.dart';
import 'package:afghan_bazar/models/custom_color.dart';
import 'package:line_icons/line_icons.dart';

import 'package:afghan_bazar/services/app_service.dart';
import 'package:afghan_bazar/utils/app_name.dart';
import 'package:afghan_bazar/utils/next_screen.dart';
import 'package:afghan_bazar/widgets/language.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

class DrawerMenu extends StatelessWidget {
  const DrawerMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final sb = context.watch<SignInBloc>();
    final List titles = [
      //'bookmarks',
      'language',
      'about us',
      'contact us',
      'facebook page',
      'youtube channel',
      'twitter',
    ];

    final List icons = [
      Icons.bookmark, // Feather.bookmark,
      Icons.wrong_location, // Feather.globe,
      Icons.info, // Feather.info,
      Icons.lock, // Feather.lock,
      Icons.email, // Feather.mail,
      Icons.facebook, // Feather.facebook,
      Icons.youtube_searched_for, // Feather.youtube,
      Icons.book, // Feather.twitter
    ];

    return Drawer(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            DrawerHeader(
              child: Container(
                alignment: Alignment.center,
                //color: context.watch<ThemeBloc>().darkTheme == false ? CustomColor().drawerHeaderColorLight : CustomColor().drawerHeaderColorDark,
                padding: EdgeInsets.all(15),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AppName(fontSize: 25.0),
                    Text(
                      'Version: ${sb.appVersion}',
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              child: ListView.separated(
                physics: NeverScrollableScrollPhysics(),
                padding: EdgeInsets.only(bottom: 30),
                itemCount: titles.length + 1,
                shrinkWrap: true,
                separatorBuilder: (ctx, idx) => Divider(height: 0),
                itemBuilder: (BuildContext context, int index) {
                  return index == titles.length
                      ? ListTile(
                          title: Text(
                            context.watch<ThemeBloc>().darkTheme != null &&
                                    context.watch<ThemeBloc>().darkTheme != true
                                ? 'dark mode'
                                : 'light mode',
                          ).tr(),
                          leading: Container(
                            height: 30,
                            width: 30,
                            decoration: BoxDecoration(
                              color: Colors.grey[600],
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Icon(
                              LineIcons.sun,
                              size: 22,
                              color: Colors.white,
                            ),
                          ),
                          trailing: Switch.adaptive(
                            activeColor: Theme.of(context).primaryColor,
                            value: context.watch<ThemeBloc>().darkTheme!,
                            onChanged: (bool) {
                              context.read<ThemeBloc>().toggleTheme();
                            },
                          ),
                        )
                      : ListTile(
                          title: Text(
                            titles[index],
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ).tr(),
                          leading: CircleAvatar(
                            radius: 20,
                            backgroundColor:
                                context.watch<ThemeBloc>().darkTheme == false
                                ? CustomColor().drawerHeaderColorLight
                                : CustomColor().drawerHeaderColorDark,
                            child: Icon(icons[index], color: Colors.grey[600]),
                          ),
                          onTap: () async {
                            Navigator.pop(context);
                            // if (index == 0) {
                            //   nextScreen(context, BookmarkPage());
                            // } else
                            if (index == 0) {
                              nextScreenPopup(context, LanguagePopup());
                            } else if (index == 1) {
                              AppService().openLinkWithCustomTab(
                                context,
                                Config().ourWebsiteUrl,
                              );
                            } else if (index == 2) {
                              AppService().openEmailSupport(context);
                              // AppService().openLinkWithCustomTab(
                              //     context, Config().privacyPolicyUrl);
                            } else if (index == 3) {
                              AppService().openLink(
                                context,
                                Config.facebookPageUrl,
                              );
                            } else if (index == 4) {
                              AppService().openLink(
                                context,
                                Config.youtubeChannelUrl,
                              );
                            } else if (index == 5) {
                              AppService().openLink(context, Config.twitterUrl);
                            } else if (index == 6) {}
                          },
                        );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
