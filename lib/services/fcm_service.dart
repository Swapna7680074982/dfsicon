import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/custom_logger.dart';

class FcmService {
  static String? _cachedFcmToken;

  /// Initializes Firebase and retrieves FCM Token
  static Future<void> initialize() async {
    try {
      await Firebase.initializeApp();
      CustomLogger.logInfo('Firebase initialized successfully');

      final messaging = FirebaseMessaging.instance;

      // Request notification permissions
      NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      CustomLogger.logInfo('User notification permission status: ${settings.authorizationStatus}');

      // Get initial token
      await fetchToken();

      // Listen for token refreshes
      messaging.onTokenRefresh.listen((newToken) async {
        _cachedFcmToken = newToken;
        CustomLogger.logInfo('FCM Token refreshed: $newToken');
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('fcm_token', newToken);
      });
    } catch (e, stack) {
      CustomLogger.logError('Failed to initialize Firebase/FCM', e, stack);
    }
  }

  /// Fetches the FCM token from Firebase Messaging
  static Future<String> fetchToken() async {
    try {
      String? token = await FirebaseMessaging.instance.getToken();
      if (token != null && token.isNotEmpty) {
        _cachedFcmToken = token;
        CustomLogger.logInfo('FCM Token generated: $token');
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('fcm_token', token);
        return token;
      }
    } catch (e, stack) {
      CustomLogger.logError('Failed to get FCM token', e, stack);
    }

    // Fallback to SharedPreferences if token fetch failed
    final prefs = await SharedPreferences.getInstance();
    _cachedFcmToken = prefs.getString('fcm_token') ?? '';
    return _cachedFcmToken ?? '';
  }

  /// Returns current cached token or fetches it
  static Future<String> getFcmToken() async {
    if (_cachedFcmToken != null && _cachedFcmToken!.isNotEmpty) {
      return _cachedFcmToken!;
    }
    return await fetchToken();
  }
}
