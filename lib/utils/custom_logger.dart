import 'package:flutter/foundation.dart';

class CustomLogger {
  static void logRequest(String method, String url, {Map<String, String>? headers, String? body}) {
    if (kDebugMode) {
      debugPrint('➔➔➔➔➔➔➔➔➔➔➔➔➔➔➔➔➔➔➔➔➔➔➔➔➔➔➔➔➔➔➔➔➔➔➔➔');
      debugPrint('[HTTP REQUEST] $method $url');
      if (headers != null && headers.isNotEmpty) {
        debugPrint('Headers: $headers');
      }
      if (body != null && body.isNotEmpty) {
        debugPrint('Body: $body');
      }
      debugPrint('➔➔➔➔➔➔➔➔➔➔➔➔➔➔➔➔➔➔➔➔➔➔➔➔➔➔➔➔➔➔➔➔➔➔➔➔');
    }
  }

  static void logResponse(String method, String url, int statusCode, String responseBody) {
    if (kDebugMode) {
      debugPrint('➔➔➔➔➔➔➔➔➔➔➔➔➔➔➔➔➔➔➔➔➔➔➔➔➔➔➔➔➔➔➔➔➔➔➔➔');
      debugPrint('[HTTP RESPONSE] $method $url');
      debugPrint('Status Code: $statusCode');
      debugPrint('Response: $responseBody');
      debugPrint('➔➔➔➔➔➔➔➔➔➔➔➔➔➔➔➔➔➔➔➔➔➔➔➔➔➔➔➔➔➔➔➔➔➔➔➔');
    }
  }

  static void logError(String message, dynamic error, [StackTrace? stackTrace]) {
    if (kDebugMode) {
      debugPrint('❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌');
      debugPrint('[ERROR] $message');
      debugPrint('Details: $error');
      if (stackTrace != null) {
        debugPrint('StackTrace:\n$stackTrace');
      }
      debugPrint('❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌');
    }
  }
}
