import 'package:flutter/material.dart';
import 'package:chakak_flutter/ui/pages/review/widgets/review_card_widget.dart';
import 'package:chakak_flutter/data/dtos/review_dto.dart';
import 'package:chakak_flutter/ui/pages/review/review_dummy.dart';
import 'package:chakak_flutter/ui/pages/photo_service/photo_service_detail_page.dart';
import 'package:chakak_flutter/data/models/photo_service/photo_service.dart';

class MyReviewScreen extends StatelessWidget {
  const MyReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("내가 작성한 리뷰"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: dummyReviews.isEmpty
          ? const Center(child: Text("아직 내가 작성한 리뷰가 없습니다."))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: dummyReviews.length,
        itemBuilder: (context, index) {
          final ReviewDto review = dummyReviews[index];
          return ReviewCardWidget(
            dto: review,
            mode: "user", // ✅ 유저 입장
            onTap: () {
              // ✅ 디버깅 로그
              print("리뷰 클릭됨: ${review.id}");

              // ✅ 더미 서비스 생성 후 상세 페이지로 이동
              final dummyService = PhotoService(
                id: int.parse(review.serviceId),
                photographerId: 1,
                title: "웨딩 스냅 촬영",
                imageUrl: "https://example.com/wedding.jpg",
                categories: ["웨딩", "스냅"],
                price: 200000,
                rating: 4.8,
                reviewCount: 12,
              );

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      PhotoServiceDetailPage(service: dummyService),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
