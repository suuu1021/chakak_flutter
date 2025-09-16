import 'package:flutter/material.dart';

class ReviewStarWidget extends StatelessWidget {
  final int rating; // 표시할 별 개수
  final double size; // 별 크기
  final Color color;

  const ReviewStarWidget({
    super.key,
    required this.rating,
    this.size = 18,
    this.color = Colors.orange,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        5, // 항상 5개 기준
            (index) => Icon(
          index < rating ? Icons.star : Icons.star_border,
          color: color,
          size: size,
        ),
      ),
    );
  }
}
