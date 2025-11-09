import 'package:flutter/material.dart';

class PrivacyInfo extends StatelessWidget {
  const PrivacyInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'By SigningUp/Logging In, You agree to our',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InkWell(
              onTap: () => {
                //  AppService().openLinkWithCustomTab(context, Config().privacyPolicyUrl)
              },
              child: const Text(
                'Terms of Services',
                style: TextStyle(
                  decoration: TextDecoration.underline,
                  color: Colors.blue,
                ),
              ),
            ),
            const SizedBox(width: 5),
            const Text('and'),
            const SizedBox(width: 5),
            InkWell(
              onTap: () => {
                // AppService().openLinkWithCustomTab(context, Config().privacyPolicyUrl)
              },
              child: const Text(
                'Privacy Policy',
                style: TextStyle(
                  decoration: TextDecoration.underline,
                  color: Colors.blue,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
