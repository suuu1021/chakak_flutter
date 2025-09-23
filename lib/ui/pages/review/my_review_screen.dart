import 'package:flutter/material.dart';
// import 'package:chakak_flutter/ui/pages/review/review_dummy.dart'; // 삭제
import 'package:chakak_flutter/ui/pages/review/widgets/review_card_widget.dart'; // ReviewCardWidget은 유지 (나중에 사용될 수 있음)
import 'package:chakak_flutter/ui/pages/photo_service/photo_service_detail_page.dart'; // onTap 관련 임시 코드에서 사용
import 'package:chakak_flutter/data/models/photo_service/photo_service.dart'; // onTap 관련 임시 코드에서 사용
import '../../../data/models/review.dart'; // Review 모델은 유지

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
      // dummyReviews 사용 부분을 플레이스홀더로 변경
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.construction_outlined, size: 50, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              "내가 작성한 리뷰 기능을 준비 중입니다.",
              style: TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
