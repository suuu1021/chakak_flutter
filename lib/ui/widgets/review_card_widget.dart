import 'package:flutter/material.dart';

class ReviewCardWidget extends StatelessWidget {
  final String? user;        // optional (포토그래퍼용 화면에서만 사용)
  final String title;        // 포트폴리오 제목
  final String comment;      // 리뷰 내용
  final int rating;          // 별점 (0~5)
  final String time;         // 작성 시각
  final VoidCallback onTap;  // 이동 버튼 액션

  const ReviewCardWidget({
    super.key,
    this.user,
    required this.title,
    required this.comment,
    required this.rating,
    required this.time,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: user != null
            ? CircleAvatar(child: Text(user![0].toUpperCase())) // 포토그래퍼용
            : null,
        title: user != null ? Text("$user • $title") : Text(title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(comment),
            Row(
              children: List.generate(
                5,
                    (i) => Icon(
                  i < rating ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 18,
                ),
              ),
            ),
            Text(time, style: const TextStyle(fontSize: 12)),
          ],
        ),
        trailing: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
          ),
          child: const Text("이동"),
        ),
      ),
    );
  }
}
