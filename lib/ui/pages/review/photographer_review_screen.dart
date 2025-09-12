import 'package:flutter/material.dart';
import '../../widgets/custom_bottom_navigation_bar.dart';
import 'package:chakak_flutter/data/dtos/review_dto.dart';
import 'widgets/review_card_widget.dart';

class PhotographerReviewScreen extends StatelessWidget {
  const PhotographerReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 📌 Mock DTO 리스트
    final receivedReviews = [
      ReviewDto(
        id: "1",
        reviewerId: "happyclient",
        photographerId: "photo21",
        rating: 5,
        comment: "작가님 덕분에 결혼식 사진이 너무 예쁘게 나왔어요!",
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      ReviewDto(
        id: "2",
        reviewerId: "bestfriends",
        photographerId: "photo22",
        rating: 4,
        comment: "우정 스냅 너무 재밌게 촬영했어요!",
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("받은 리뷰 관리"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: receivedReviews.isEmpty
          ? const Center(child: Text("아직 받은 리뷰가 없습니다."))
          : ListView(
        children: receivedReviews.map((review) {
          return ReviewCardWidget(
            dto: review,
            onTap: () {
              Navigator.pushNamed(
                context,
                '/review-detail',
                arguments: review,
              );
            },
          );
        }).toList(),
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(),
    );
  }
}
