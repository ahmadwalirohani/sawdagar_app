import 'package:firebase_core/firebase_core.dart';

class RetryHelper {
  static Future<T> executeWithRetry<T>(
    Future<T> Function() function, {
    int maxRetries = 3,
    Duration initialDelay = const Duration(seconds: 1),
  }) async {
    for (int attempt = 0; attempt < maxRetries; attempt++) {
      try {
        return await function();
      } on FirebaseException catch (e) {
        if (e.code == 'unavailable' && attempt < maxRetries - 1) {
          final delay = Duration(
            milliseconds: initialDelay.inMilliseconds * (1 << attempt),
          );
          print('Firestore unavailable, retrying in ${delay.inSeconds}s...');
          await Future.delayed(delay);
          continue;
        }
        rethrow;
      } catch (e) {
        rethrow; // Re-throw non-transient errors
      }
    }
    throw Exception('Max retries exceeded');
  }
}
