import 'package:flutter/material.dart';

import '../../../../data/models/review.dart';

class ReviewCardWidget extends StatelessWidget {
  final Review review;
  final String mode; // "photographer", "user", 또는 "service_detail" 등
  final VoidCallback? onTap;

  const ReviewCardWidget({
    super.key,
    required this.review,
    required this.mode,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // 날짜 포맷팅 (YYYY-MM-DD)
    String formattedDate = review.createdAt.length >= 10
        ? review.createdAt.substring(0, 10)
        : review.createdAt;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 사용자 정보 (닉네임)
            // 'mode'에 따라 다르게 표시할 수도 있지만, 우선은 닉네임으로 통일
            Text(
              "작성자: ${review.author.nickname}",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            // 리뷰 내용
            Text(
              review.content.isNotEmpty ? review.content : "코멘트 없음",
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            // 별점
            Text("⭐ ${review.rating.toStringAsFixed(1)} / 5"),
            const SizedBox(height: 4),
            // 작성일
            Text(
              "작성일: $formattedDate",
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
