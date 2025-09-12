import 'package:flutter/material.dart';
import '../../widgets/custom_bottom_navigation_bar.dart';
import 'package:chakak_flutter/data/dtos/review_dto.dart';
import 'widgets/review_card_widget.dart';

class MyReviewScreen extends StatelessWidget {
  const MyReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 📌 Mock DTO 리스트
    final myReviews = [
      ReviewDto(
        id: "1",
        reviewerId: "홍길동",
        photographerId: "photo11",
        rating: 5,
        comment: "정말 만족스러웠습니다!",
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      ReviewDto(
        id: "2",
        reviewerId: "임꺽정",
        photographerId: "photo12",
        rating: 4,
        comment: "친구들이 너무 좋아했어요",
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("내가 작성한 리뷰"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: myReviews.isEmpty
          ? const Center(child: Text("작성한 리뷰가 없습니다."))
          : ListView(
        children: myReviews.map((review) {
          return ReviewCardWidget(
            dto: review,
            onTap: () {
              Navigator.pushNamed(
                context,
                '/portfolio-detail',
                arguments: review.photographerId,
              );
            },
          );
        }).toList(),
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(),
    );
  }
}
