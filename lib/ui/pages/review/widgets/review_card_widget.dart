import 'package:flutter/material.dart';
import '../../../../data/dtos/review_dto.dart';

class ReviewCardWidget extends StatelessWidget {
  final ReviewDto dto;
  final String mode;
  final VoidCallback? onTap;

  const ReviewCardWidget({
    super.key,
    required this.dto,
    required this.mode,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
            if (mode == "photographer" || mode == "user")
              Text(
                "작성자: ${dto.reviewerId}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            const SizedBox(height: 4),
            Text(
              dto.comment ?? "코멘트 없음",
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text("⭐ ${dto.rating} / 5"),
            const SizedBox(height: 4),
            Text(
              "작성일: ${dto.createdAt.toString().substring(0, 10)}",
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
