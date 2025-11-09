import 'package:flutter/material.dart';
import 'package:afghan_bazar/blocs/sign_in_bloc.dart';
import 'package:afghan_bazar/utils/icons.dart';
import 'package:provider/provider.dart';

class BuildLoveIcon extends StatelessWidget {
  final String collectionName;
  final String? uid;
  final String? timestamp;

  const BuildLoveIcon({
    super.key,
    required this.collectionName,
    required this.uid,
    required this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    final sb = context.watch<SignInBloc>();
    String type = 'loved items';
    if (sb.isSignedIn == false) return LoveIcon().normal;
    return StreamBuilder(
      stream: Stream.empty(),
      builder: (context, AsyncSnapshot snap) {
        if (uid == null) return LoveIcon().normal;
        if (!snap.hasData) return LoveIcon().normal;
        List d = snap.data[type];

        if (d.contains(timestamp)) {
          return LoveIcon().bold;
        } else {
          return LoveIcon().normal;
        }
      },
    );
  }
}
