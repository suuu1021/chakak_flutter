import 'package:flutter/material.dart';
import 'package:chakak_flutter/data/dtos/review_dto.dart';

class ReviewCardWidget extends StatelessWidget {
  final ReviewDto dto;
  final VoidCallback onTap;
  final String mode; // "user" → 유저 입장 / "photographer" → 포토그래퍼 입장

  const ReviewCardWidget({
    super.key,
    required this.dto,
    required this.onTap,
    required this.mode,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
        margin: const EdgeInsets.symmetric(vertical: 6),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 모드별 상단 표시
              Text(
                mode == "user"
                    ? "작가: ${dto.photographerId}"   // 유저 입장 → 내가 리뷰한 대상 작가
                    : "작성자: ${dto.reviewerId}",   // 포토그래퍼 입장 → 나를 리뷰한 유저
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),

              // ⭐ 별점
              Text(
                "⭐ ${dto.rating} / 5",
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(height: 8),

              // 코멘트
              if (dto.comment != null)
                Text(
                  dto.comment!,
                  style: const TextStyle(fontSize: 14),
                ),
              const SizedBox(height: 8),

              // 작성일
              Text(
                "작성일: ${dto.createdAt.toLocal().toString().split(' ')[0]}",
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
