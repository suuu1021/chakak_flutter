import 'package:flutter/material.dart';
import 'review_star_widget.dart';

class ReviewItemCardWidget extends StatelessWidget {
  final String userName;
  final int rating;
  final String content;
  final String date;

  const ReviewItemCardWidget({
    super.key,
    required this.userName,
    required this.rating,
    required this.content,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 작성자 + 날짜
            Row(
              children: [
                const CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(width: 8),
                Text(
                  userName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  date,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // ⭐ 별점 위젯
            ReviewStarWidget(rating: rating, size: 20),

            const SizedBox(height: 6),

            // 리뷰 본문
            Text(content),
          ],
        ),
      ),
    );
  }
}
