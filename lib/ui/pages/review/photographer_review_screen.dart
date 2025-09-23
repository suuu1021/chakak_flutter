import 'package:flutter/material.dart';
import '../../../data/models/review.dart'; // Review 모델은 유지
import '../../widgets/custom_bottom_navigation_bar.dart'; // BottomNavigationBar는 유지
import 'widgets/review_card_widget.dart'; // ReviewCardWidget은 유지 (나중에 사용될 수 있음)

class PhotographerReviewScreen extends StatelessWidget {
  const PhotographerReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("받은 리뷰 관리"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      // dummyReviews 사용 부분을 플레이스홀더로 변경
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.rate_review_outlined, size: 50, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              "받은 리뷰 관리 기능을 준비 중입니다.",
              style: TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(),
    );
  }
}
