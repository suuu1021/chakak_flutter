import 'package:chakak_flutter/ui/pages/chat/chat_list_screen.dart';
import 'package:flutter/material.dart';

import '../../data/models/portfolio.dart'; //
import '../../ui/pages/auth/login_choice_screen.dart';
import '../../ui/pages/auth/login_screen.dart';
import '../../ui/pages/auth/signup_screen.dart';
import '../../ui/pages/auth/social_login_screen.dart';
import '../../ui/pages/booking/booking_management_screen.dart';
import '../../ui/pages/chat/chat_screen.dart';
import '../../ui/pages/help_center/help_center_screen.dart';
import '../../ui/pages/home/home_screen.dart';
import '../../ui/pages/notification/notification_screen.dart';
import '../../ui/pages/profile/photographer/photographer_profile_form_page.dart';
import '../../ui/pages/profile/profile_edit_page.dart';
import '../../ui/pages/review/my_review_screen.dart';
import '../../ui/pages/review/photographer_review_screen.dart';
import '../../ui/pages/review/review_manager_screen.dart';
import '../../ui/pages/portfolio/portfolio_detail_page.dart';
import '../../ui/pages/search/search_screen.dart';
import '../../ui/pages/splash/onboarding_screen.dart';
import '../../ui/pages/splash/splash_screen.dart';
import '../../ui/pages/payment/payment_form_screen.dart';
import '../../ui/pages/payment/payment_success_screen.dart';
import '../../ui/pages/payment/payment_fail_screen.dart';
import 'user_type.dart';

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
  static const String profileEdit = '/profile/edit';
  static const String reviewManager = '/review-manager';
  static const String portfolioDetail = '/portfolio-detail';
  static const String userBookingList = '/user-booking-list';
  static const String search = '/search';
  static const String paymentForm = '/payment-form';
  static const String paymentSuccess = '/payment-success';
  static const String paymentFail = '/payment-fail';
  static const String chat = '/chat';
  static const String chatList = '/chat-list';

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
        photographerProfileForm: (context) =>
            const PhotographerProfileFormPage(),
        profileEdit: (context) => const ProfileEditPage(),
        photographerReviews: (context) => const PhotographerReviewScreen(),
        reviewManager: (context) =>
            const ReviewManagerScreen(userType: UserType.user),
        portfolioDetail: (context) {
          final portfolio =
              ModalRoute.of(context)!.settings.arguments as Portfolio;
          return PortfolioDetailPage(portfolio: portfolio);
        },
        userBookingList: (context) => const BookingManagementScreen(),
        search: (context) => const SearchScreen(),
        chat: (context) {
          final args =
              ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          final chatRoomId = args['chatRoomId'] as int;
          final opponentNickname = args['opponentNickname'] as String;
          return ChatScreen(
              chatRoomId: chatRoomId, opponentNickname: opponentNickname);
        },
        chatList: (context) => const ChatListScreen(),
        paymentForm: (context) {
          final args = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>;
          return PaymentFormScreen(
            itemName: args['itemName'],
            totalAmount: args['totalAmount'],
            bookingInfoId: args['bookingInfoId'],
          );
        },
        paymentSuccess: (context) => const PaymentSuccessScreen(),
        paymentFail: (context) {
          final reason = ModalRoute.of(context)!.settings.arguments as String?;
          return PaymentFailScreen(reason: reason);
        },
      };

  // 초기 라우트
  static const String initialRoute = splash;
}
