import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/map_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/reservation_screen.dart';
import 'screens/edit_profile_screen.dart';
import 'screens/notifications_settings_screen.dart';
import 'screens/privacy_security_screen.dart';
import 'screens/help_center_screen.dart';
import 'screens/about_screen.dart';
import 'models/app_state.dart';
import 'utils/theme.dart';
import 'utils/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set orientation
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize Firebase Cloud Messaging
  await NotificationService.instance.initialize();

  runApp(
    ChangeNotifierProvider(
      create: (context) => AppState(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PMU Park',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/map': (context) => const MapScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/reservation': (context) => const ReservationScreen(),
        '/edit_profile': (context) => const EditProfileScreen(),
        '/notifications': (context) => const NotificationsSettingsScreen(),
        '/privacy_security': (context) => const PrivacySecurityScreen(),
        '/help_center': (context) => const HelpCenterScreen(),
        '/about': (context) => const AboutScreen(),
      },
    );
  }
}
