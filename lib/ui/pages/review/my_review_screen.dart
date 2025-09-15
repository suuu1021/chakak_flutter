import 'package:chakak_flutter/data/dtos/porfolio_dto.dart';
import 'package:flutter/material.dart';

import '../../widgets/custom_bottom_navigation_bar.dart';
import 'widgets/review_card_widget.dart';

class MyReviewScreen extends StatelessWidget {
  const MyReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 더미 리뷰 → PortfolioDto 생성
    final myReviews = [
      PortfolioDto(
        id: "1",
        title: "웨딩 스냅 포트폴리오",
        description: "정말 만족스러웠습니다!",
        thumbnailUrl: "assets/images/onbording.jpg",
        imageUrls: ["assets/images/onbording.jpg"],
        categories: ["웨딩"],
        likes: 10,
        createdAt: DateTime.now().toIso8601String(),
        photographerId: "photo11",
      ),
      PortfolioDto(
        id: "2",
        title: "우정 스냅 포트폴리오",
        description: "친구들이 너무 좋아했어요",
        thumbnailUrl: "assets/images/dora.png",
        imageUrls: ["assets/images/dora.png"],
        categories: ["우정"],
        likes: 5,
        createdAt: DateTime.now().toIso8601String(),
        photographerId: "photo12",
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
              children: myReviews.map((dto) {
                return ReviewCardWidget(
                  dto: dto.toModel(), // DTO → Model 변환
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/portfolio-detail',
                      arguments: dto.toModel(), // Model 전달
                    );
                  },
                );
              }).toList(),
            ),
      bottomNavigationBar: const CustomBottomNavigationBar(),
    );
  }
}
