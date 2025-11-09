import 'package:flutter/material.dart';
import 'package:afghan_bazar/blocs/sign_in_bloc.dart';
import 'package:afghan_bazar/utils/icons.dart';
import 'package:provider/provider.dart';

class BuildBookmarkIcon extends StatelessWidget {
  final String collectionName;
  final String? uid;
  final String? timestamp;

  const BuildBookmarkIcon({
    super.key,
    required this.collectionName,
    required this.uid,
    required this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    final sb = context.watch<SignInBloc>();
    String type = 'bookmarked items';
    if (sb.isSignedIn == false) return BookmarkIcon().normal;
    return StreamBuilder(
      stream: Stream.empty(),
      builder: (context, AsyncSnapshot snap) {
        if (uid == null) return BookmarkIcon().normal;
        if (!snap.hasData) return BookmarkIcon().normal;
        List d = snap.data[type];

        if (d.contains(timestamp)) {
          return BookmarkIcon().bold;
        } else {
          return BookmarkIcon().normal;
        }
      },
    );
  }
}
