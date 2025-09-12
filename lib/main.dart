import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
<<<<<<< HEAD
import 'ui/pages/splash/splash_screen.dart';
import 'ui/pages/splash/onboarding_screen.dart';
import 'ui/pages/auth/login_choice_screen.dart';
import 'ui/pages/auth/login_screen.dart';
import 'ui/pages/auth/signup_screen.dart';
import 'ui/pages/auth/social_login_screen.dart';
import 'ui/pages/home/home_screen.dart';
import 'ui/pages/help_center/help_center_screen.dart';
import 'ui/pages/notification/notification_screen.dart';
import 'ui/pages/review/my_review_screen.dart';
import 'ui/pages/review/photographer_review_screen.dart';
import 'ui/pages/review/review_manager_screen.dart';
import 'ui/pages/portfolio/portfolio_detail_page.dart';
import '_core/constants/user_type.dart';
import '../data/models/portfolio.dart';
=======

import '_core/constants/app_routes.dart';
>>>>>>> 13108472edd4a931a59f927c1c5caea13ebc415c

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
<<<<<<< HEAD
      initialRoute: '/splash',
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
        '/my-reviews': (context) => const MyReviewScreen(),
        '/photographer-reviews': (context) =>
        const PhotographerReviewScreen(),
        '/review-manager': (context) => const ReviewManagerScreen(
          userType: UserType.user, // 테스트 시 user/photographer 바꿔가며 확인
        ),
        '/portfolio-detail': (context) {
          final portfolio =
          ModalRoute.of(context)!.settings.arguments as Portfolio;
          return PortfolioDetailPage(portfolio: portfolio);
        },
      },
=======
      navigatorKey: navigatorKey,
      initialRoute: AppRoutes.initialRoute,
      routes: AppRoutes.routes,
>>>>>>> 13108472edd4a931a59f927c1c5caea13ebc415c
    );
  }
}
