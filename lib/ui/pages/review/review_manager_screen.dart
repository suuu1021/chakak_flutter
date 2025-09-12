// lib/ui/pages/review/review_manager_screen.dart
import 'package:flutter/material.dart';
import 'my_review_screen.dart';
import 'photographer_review_screen.dart';
import '../../../_core/constants/user_type.dart';

class ReviewManagerScreen extends StatelessWidget {
  final UserType userType;

  const ReviewManagerScreen({super.key, required this.userType});

  @override
  Widget build(BuildContext context) {
    if (userType == UserType.photographer) {
      return const PhotographerReviewScreen();
    } else {
      return const MyReviewScreen();
    }
  }
}
