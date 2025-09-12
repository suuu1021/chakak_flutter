import 'package:flutter/material.dart';
import '../../widgets/custom_bottom_navigation_bar.dart';
import 'package:chakak_flutter/data/dtos/porfolio_dto.dart';
import 'package:chakak_flutter/data/models/portfolio.dart';
import 'widgets/review_card_widget.dart';

class PhotographerReviewScreen extends StatelessWidget {
  const PhotographerReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 더미 리뷰 → PortfolioDto 생성
    final receivedReviews = [
      PortfolioDto(
        id: "3",
        title: "웨딩 스냅",
        description: "작가님 덕분에 결혼식 사진이 너무 예쁘게 나왔어요!",
        thumbnailUrl: "assets/images/onbording.jpg",
        imageUrls: ["assets/images/onbording.jpg"],
        categories: ["웨딩"],
        likes: 20,
        createdAt: DateTime.now().toIso8601String(),
        photographerId: "photo21",
      ),
      PortfolioDto(
        id: "4",
        title: "우정 스냅",
        description: "우정 스냅 너무 재밌게 촬영했어요!",
        thumbnailUrl: "assets/images/dora.png",
        imageUrls: ["assets/images/dora.png"],
        categories: ["우정"],
        likes: 15,
        createdAt: DateTime.now().toIso8601String(),
        photographerId: "photo22",
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
        children: receivedReviews.map((dto) {
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
