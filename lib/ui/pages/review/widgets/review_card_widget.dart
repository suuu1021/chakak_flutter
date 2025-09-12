import 'package:flutter/material.dart';
import 'package:chakak_flutter/data/dtos/review_dto.dart';

class ReviewCardWidget extends StatelessWidget {
  final ReviewDto dto;
  final VoidCallback onTap;

  const ReviewCardWidget({
    super.key,
    required this.dto,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: dto.reviewerId.isNotEmpty
            ? CircleAvatar(child: Text(dto.reviewerId[0].toUpperCase()))
            : null,
        title: Text(dto.reviewerId),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (dto.comment != null) Text(dto.comment!),
            Row(
              children: List.generate(
                5,
                    (i) => Icon(
                  i < dto.rating ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 18,
                ),
              ),
            ),
            Text(
              "${DateTime.now().difference(dto.createdAt).inDays}일 전",
              style: const TextStyle(fontSize: 12),
            ),
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
