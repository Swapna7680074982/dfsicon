import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'constants/colors.dart';
import 'providers/auth_provider.dart';
import 'providers/photo_provider.dart';
import 'providers/abstract_provider.dart';
import 'providers/home_provider.dart';
import 'providers/sessions_provider.dart';
import 'providers/connections_provider.dart';
import 'providers/network_provider.dart';
import 'providers/explore_provider.dart';
import 'providers/gallery_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/photo/photo_upload_screen.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  static bool _isRedirectingToLogin = false;

  static void redirectToLogin() {
    if (_isRedirectingToLogin) return;
    _isRedirectingToLogin = true;

    // Reset the flag after a short delay to allow transition to complete
    Future.delayed(const Duration(seconds: 1), () {
      _isRedirectingToLogin = false;
    });

    navigatorKey.currentState?.pushNamedAndRemoveUntil('/login', (route) => false);
  }

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => PhotoProvider()),
        ChangeNotifierProvider(create: (_) => AbstractProvider()),
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => SessionsProvider()),
        ChangeNotifierProvider(create: (_) => ConnectionsProvider()),
        ChangeNotifierProvider(create: (_) => NetworkProvider()),
        ChangeNotifierProvider(create: (_) => ExploreProvider()),
        ChangeNotifierProvider(create: (_) => GalleryProvider()),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        title: 'DFSICON 2026',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            primary: AppColors.primary,
            surface: AppColors.background,
          ),
          fontFamily: 'Roboto',
          textTheme: const TextTheme(
            headlineMedium: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            bodyMedium: TextStyle(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/login': (context) => const LoginScreen(),
          '/photo_upload': (context) => const PhotoUploadScreen(),
          '/dashboard': (context) => const DashboardScreen(),
        },
      ),
    );
  }
}
