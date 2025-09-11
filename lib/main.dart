import 'package:chakak_flutter/ui/pages/notification/notification_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'ui/pages/splash/splash_screen.dart';
import 'ui/pages/splash/onboarding_screen.dart';
import 'ui/pages/auth/login_choice_screen.dart';
import 'ui/pages/auth/login_screen.dart';
import 'ui/pages/auth/signup_screen.dart';
import 'ui/pages/auth/social_login_screen.dart';
import 'ui/pages/home/home_screen.dart';
import 'ui/pages/help_center/help_center_screen.dart';

GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // 앱 시작 시 첫 화면
      initialRoute: '/splash',

      // 라우트 테이블
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/login-choice': (context) => const LoginChoiceScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/social-login': (context) => const SocialLoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/help-center': (context) => const HelpCenterScreen(),
        '/notification': (context) => const NotificationScreen(),
      },
    );
  }
}
