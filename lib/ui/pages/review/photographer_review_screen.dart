import 'package:flutter/material.dart';
import '../../../_core/constants/app_colors.dart';
import '../../widgets/custom_bottom_navigation_bar.dart';
import 'widgets/review_card_widget.dart';
import '../../../data/models/review/review_dto.dart';
import 'package:chakak_flutter/ui/pages/review/review_dummy.dart';

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
      body: dummyReviews.isEmpty
          ? const Center(child: Text("아직 받은 리뷰가 없습니다."))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: dummyReviews.length,
              itemBuilder: (context, index) {
                final ReviewDto review = dummyReviews[index];
                return ReviewCardWidget(
                  dto: review,
                  mode: "photographer", // ✅ 포토그래퍼 입장
                  onTap: () {},
                );
              },
            ),
      bottomNavigationBar: const CustomBottomNavigationBar(),
    );
  }
}
