import 'package:flutter/material.dart';
import '../../widgets/custom_bottom_navigation_bar.dart';
import '../../widgets/review_card_widget.dart';

class MyReviewScreen extends StatelessWidget {
  const MyReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ 타입 명확하게 지정
    final List<Map<String, dynamic>> myReviews = [
      {
        "portfolioId": 1,
        "title": "웨딩 스냅 포트폴리오",
        "comment": "정말 만족스러웠습니다!",
        "rating": 5,
        "time": "2일 전",
      },
      {
        "portfolioId": 2,
        "title": "우정 스냅 포트폴리오",
        "comment": "친구들이 너무 좋아했어요",
        "rating": 4,
        "time": "1주 전",
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("내가 작성한 리뷰"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListView(
        children: myReviews.map((review) {
          return ReviewCardWidget(
            title: review["title"] as String,
            comment: review["comment"] as String,
            rating: review["rating"] as int,
            time: review["time"] as String,
            onTap: () {
              Navigator.pushNamed(
                context,
                '/portfolio-detail',
                arguments: review["portfolioId"],
              );
            },
          );
        }).toList(),
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(),
    );
  }
}
