import 'package:flutter/material.dart';

import '../../ui/pages/auth/login_choice_screen.dart';
import '../../ui/pages/auth/login_screen.dart';
import '../../ui/pages/auth/signup_screen.dart';
import '../../ui/pages/auth/social_login_screen.dart';
import '../../ui/pages/help_center/help_center_screen.dart';
import '../../ui/pages/home/home_screen.dart';
import '../../ui/pages/notification/notification_screen.dart';
import '../../ui/pages/profile/photographer/photographer_profile_form_page.dart';
import '../../ui/pages/review/my_review_screen.dart';
import '../../ui/pages/review/photographer_review_screen.dart';
import '../../ui/pages/splash/onboarding_screen.dart';
import '../../ui/pages/splash/splash_screen.dart';

class AppRoutes {
  // 라우트 이름 상수
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String loginChoice = '/login-choice';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String socialLogin = '/social-login';
  static const String home = '/home';
  static const String helpCenter = '/help-center';
  static const String notification = '/notification';
  static const String myReviews = '/my-reviews';
  static const String photographerReviews = '/photographer-reviews';
  static const String photographerProfileForm = '/photographer-profile-form';

  // 라우트 테이블
  static Map<String, WidgetBuilder> get routes => {
        splash: (context) => const SplashScreen(),
        onboarding: (context) => const OnboardingScreen(),
        loginChoice: (context) => const LoginChoiceScreen(),
        login: (context) => const LoginScreen(),
        signup: (context) => const SignupScreen(),
        socialLogin: (context) => const SocialLoginScreen(),
        home: (context) => const HomeScreen(),
        helpCenter: (context) => const HelpCenterScreen(),
        notification: (context) => const NotificationScreen(),
        myReviews: (context) => const MyReviewScreen(),
        photographerReviews: (context) => const PhotographerReviewScreen(),
        photographerProfileForm: (context) =>
            const PhotographerProfileFormPage(),
      };

  // 초기 라우트
  static const String initialRoute = splash;
}
