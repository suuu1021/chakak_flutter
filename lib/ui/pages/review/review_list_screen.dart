import 'package:chakak_flutter/ui/pages/review/widgets/review_card_widget.dart';
import 'package:flutter/material.dart';
import '../../../data/dtos/review_dto.dart';
import '../../../ui/pages/photo_service/photo_service_detail_page.dart';
import '../../../data/models/photo_service/photo_service.dart';
import 'review_dummy.dart';

class ReviewListScreen extends StatelessWidget {
  const ReviewListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("리뷰 목록")),
      body: ListView.builder(
        itemCount: dummyReviews.length,
        itemBuilder: (context, index) {
          final ReviewDto review = dummyReviews[index];
          return ReviewCardWidget(
            dto: review,
            mode: "user", // ✅ 필수 파라미터 추가
            onTap: () {
              // ✅ 리뷰 클릭 → 서비스 상세 페이지로 이동
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
                  builder: (_) => PhotoServiceDetailPage(service: dummyService),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
