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
        leading: _buildThumbnail(),
        title: Text(dto.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(dto.description),
            Text("좋아요 ${dto.likes}개"),
            Text("작성일: $dateOnly"),
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

  Widget _buildThumbnail() {
    if (dto.thumbnailUrl.isEmpty) {
      return _buildPlaceholderThumbnail();
    }

    // HTTP URL인 경우 네트워크 이미지
    if (dto.thumbnailUrl.startsWith('http')) {
      return CircleAvatar(
        backgroundImage: NetworkImage(dto.thumbnailUrl),
        onBackgroundImageError: (exception, stackTrace) {
          // 에러 발생시 기본 처리
        },
      );
    }

    // 로컬 asset 이미지인 경우
    return CircleAvatar(
      backgroundImage: AssetImage(dto.thumbnailUrl),
      onBackgroundImageError: (exception, stackTrace) {
        // 에러 발생시 기본 처리
      },
    );
  }

  Widget _buildPlaceholderThumbnail() {
    return CircleAvatar(
      backgroundColor: Colors.grey[300],
      child: const Icon(
        Icons.image,
        color: Colors.grey,
        size: 24,
      ),
    );
  }
}
