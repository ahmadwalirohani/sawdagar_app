import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:afghan_bazar/blocs/theme_bloc.dart';
import 'package:afghan_bazar/models/custom_color.dart';
import 'package:provider/provider.dart';

import '../utils/next_screen.dart';
import 'full_image.dart';
import 'video_player_widget.dart';

// final String demoText = "<p>Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s</p>" +
// //'''<iframe width="560" height="315" src="https://www.youtube.com/embed/-WRzl9L4z3g" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>'''+
// //'''<video controls src="https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4"></video>''' +
// //'''<iframe src="https://player.vimeo.com/video/226053498?h=a1599a8ee9" width="640" height="360" frameborder="0" allow="autoplay; fullscreen; picture-in-picture" allowfullscreen></iframe>''' +
// "<p>Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s</p>";

class HtmlBodyWidget extends StatelessWidget {
  final String content;
  final bool isVideoEnabled;
  final bool isimageEnabled;
  final bool isIframeVideoEnabled;
  final double? fontSize;

  const HtmlBodyWidget({
    super.key,
    required this.content,
    required this.isVideoEnabled,
    required this.isimageEnabled,
    required this.isIframeVideoEnabled,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Html(
      data: content,
      onLinkTap: (url, _, __) {
        // AppService().openLinkWithCustomTab(context, url!);
      },
      style: {
        "body": Style(
          margin: Margins.zero,
          padding: HtmlPaddings.all(10),

          //Enable the below line and disble the upper line to disble full width image/video

          //padding: EdgeInsets.all(20),
          fontSize: fontSize == null ? FontSize(18.0) : FontSize(17.0),
          lineHeight: LineHeight(1.7),
          fontFamily: 'Open Sans',
          fontWeight: FontWeight.w400,
          color: context.watch<ThemeBloc>().darkTheme == false
              ? CustomColor().bodyTextColorLight
              : CustomColor().bodyTextColorDark,
        ),
        "figure": Style(margin: Margins.zero, padding: HtmlPaddings.zero),

        //Disable this line to disble full width image/video
        "p,h1,h2,h3,h4,h5,h6": Style(margin: Margins.all(20)),
      },
      extensions: [
        TagExtension(
          tagsToExtend: {"iframe"},
          builder: (ExtensionContext eContext) {
            final String videoSource0 = eContext.attributes['src'].toString();
            if (isIframeVideoEnabled == false) return Container();
            if (videoSource0.contains('youtu')) {
              return VideoPlayerWidget(
                videoUrl: videoSource0,
                videoType: 'youtube',
              );
            } else if (videoSource0.contains('vimeo')) {
              return VideoPlayerWidget(
                videoUrl: videoSource0,
                videoType: 'vimeo',
              );
            }
            return Container();
          },
        ),
        TagExtension(
          tagsToExtend: {"video"},
          builder: (ExtensionContext eContext) {
            final String videoSource = eContext.attributes['src'].toString();
            if (isVideoEnabled == false) return Container();
            return VideoPlayerWidget(
              videoUrl: videoSource,
              videoType: 'network',
            );
          },
        ),
        TagExtension(
          tagsToExtend: {"img"},
          builder: (ExtensionContext eContext) {
            String imageUrl = eContext.attributes['src'].toString();
            return InkWell(
              onTap: () =>
                  nextScreen(context, FullScreenImage(imageUrl: imageUrl)),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                placeholder: (context, url) =>
                    const CircularProgressIndicator(),
              ),
            );
          },
        ),
      ],
    );
  }
}
