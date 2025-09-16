import 'package:flutter/material.dart';
import 'widgets/review_item_card_widget.dart';
import 'review_form_screen.dart';

class ReviewListScreen extends StatelessWidget {
  const ReviewListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 더미 리뷰 데이터 (dynamic 사용)
    final List<Map<String, dynamic>> reviews = [
      {
        "user": "stee001",
        "rating": 5,
        "text": "정말 멋진 촬영이었어요! 또 이용하고 싶습니다.",
        "date": "2025-09-10",
      },
      {
        "user": "danibancoof#3118",
        "rating": 4,
        "text": "사진은 좋았지만, 일정 조율이 조금 아쉬웠어요.",
        "date": "2025-09-09",
      },
      {
        "user": "asura_op",
        "rating": 5,
        "text": "친절하시고 촬영도 만족스러웠습니다!",
        "date": "2025-09-08",
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("리뷰 목록"),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: reviews.length,
        itemBuilder: (context, index) {
          final r = reviews[index];
          return ReviewItemCardWidget(
            userName: r["user"],   // String
            rating: r["rating"],   // int
            content: r["text"],    // String
            date: r["date"],       // String
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: () {
              // 리뷰 작성 화면으로 이동
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ReviewFormScreen()),
              );
            },
            child: const Text("리뷰 작성하기"),
          ),
        ),
      ),
    );
  }
}
