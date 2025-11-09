import 'package:flutter/material.dart';

class AppName extends StatelessWidget {
  final double fontSize;
  const AppName({super.key, required this.fontSize});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        text: 'Afghan  ', //first part
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: fontSize,
          fontWeight: FontWeight.w900,
          color: const Color.fromARGB(255, 4, 24, 35),
        ),
        children: <TextSpan>[
          TextSpan(
            text: 'Bazaar', //second part
            style: TextStyle(
              fontFamily: 'Poppins',
              color: const Color(0xFFFF9900),
            ),
          ),
        ],
      ),
    );
  }
}
