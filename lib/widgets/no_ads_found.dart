import 'package:flutter/material.dart';

class NoAdsFound extends StatelessWidget {
  final String message;
  const NoAdsFound({super.key, this.message = "No ads found."});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.info_outline, size: 40, color: Colors.grey),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(color: Colors.grey[700], fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
