import 'package:flutter/material.dart';
import '../../../../data/models/portfolio.dart';

class ReviewCardWidget extends StatelessWidget {
  final Portfolio dto;
  final VoidCallback onTap;

  const ReviewCardWidget({
    super.key,
    required this.dto,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // 날짜만 추출 (YYYY-MM-DD)
    final String dateOnly = dto.createdAt.toString().substring(0, 10);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: AssetImage(dto.thumbnailUrl),
        ),
        title: Text(dto.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(dto.description),
            Text("좋아요 ${dto.likes}개"),
            Text("작성일: $dateOnly"), // ← const 붙이면 안 됩니다!
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
