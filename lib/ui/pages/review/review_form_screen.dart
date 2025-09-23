import 'package:flutter/material.dart';
import 'widgets/review_star_widget.dart';

class ReviewFormScreen extends StatefulWidget {
  const ReviewFormScreen({super.key});

  @override
  State<ReviewFormScreen> createState() => _ReviewFormScreenState();
}

class _ReviewFormScreenState extends State<ReviewFormScreen> {
  int _rating = 0; // 선택된 별점
  final TextEditingController _controller = TextEditingController();

  void _submitReview() {
    if (_rating == 0 || _controller.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("별점과 리뷰 내용을 입력해주세요.")),
      );
      return;
    }

    // TODO: 서버로 리뷰 전송 (API 연결 예정)
    print("별점: $_rating");
    print("내용: ${_controller.text}");

    Navigator.pop(context); // 이전 화면으로 돌아가기
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("리뷰 작성"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("별점 선택", style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),

            // ⭐ 별점 선택 위젯
            GestureDetector(
              onTapDown: (details) {
                const starSize = 36.0;
                const starCount = 5;

                final tapX = details.localPosition.dx;
                final starWidth = starSize; // 별 하나 크기

                setState(() {
                  _rating = (tapX / starWidth).ceil().clamp(1, starCount);
                });
              },
              child: ReviewStarWidget(
                rating: _rating,
                size: 36,
                color: Colors.orange,
              ),
            ),

            const SizedBox(height: 16),

            const Text("리뷰 내용", style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            TextField(
              controller: _controller,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: "리뷰를 입력하세요...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),

            const Spacer(),

            // 등록 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitReview,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text("리뷰 등록하기"),
              ),
            )
          ],
        ),
      ),
    );
  }
} // 리뷰 작성 페이지
