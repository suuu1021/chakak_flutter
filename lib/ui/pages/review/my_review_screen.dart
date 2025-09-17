import 'package:flutter/material.dart';
import 'package:chakak_flutter/ui/pages/review/widgets/review_card_widget.dart';
import 'package:chakak_flutter/ui/pages/review/review_dummy.dart'; // 더미 리뷰
import 'package:chakak_flutter/data/dtos/review_dto.dart';

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
            mode: "user", // ✅ 여기서 "user" 지정
            onTap: () {},
          );
        },
      ),
    );
  }
}
