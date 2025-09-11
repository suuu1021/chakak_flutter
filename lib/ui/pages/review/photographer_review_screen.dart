import 'package:flutter/material.dart';
import '../../widgets/custom_bottom_navigation_bar.dart';
import '../../widgets/review_card_widget.dart';

class PhotographerReviewScreen extends StatelessWidget {
  const PhotographerReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ 타입 명확하게 지정
    final List<Map<String, dynamic>> receivedReviews = [
      {
        "user": "happyclient",
        "title": "웨딩 스냅",
        "comment": "작가님 덕분에 결혼식 사진이 너무 예쁘게 나왔어요!",
        "rating": 5,
        "time": "3일 전",
      },
      {
        "user": "bestfriends",
        "title": "우정 스냅",
        "comment": "우정 스냅 너무 재밌게 촬영했어요!",
        "rating": 4,
        "time": "1주 전",
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("받은 리뷰 관리"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListView(
        children: receivedReviews.map((review) {
          return ReviewCardWidget(
            user: review["user"] as String,
            title: review["title"] as String,
            comment: review["comment"] as String,
            rating: review["rating"] as int,
            time: review["time"] as String,
            onTap: () {
              Navigator.pushNamed(
                context,
                '/review-detail',
                arguments: review,
              );
            },
          );
        }).toList(), // ✅ 반드시 toList()
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(),
    );
  }
}
