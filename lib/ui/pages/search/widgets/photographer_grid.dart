import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/models/photographer.dart';
import '../../../../provider/global/photographer/photographer_notifier.dart';

class PhotographerGrid extends ConsumerWidget {
  final Function(Photographer) onPhotographerTap;

  const PhotographerGrid({
    super.key,
    required this.onPhotographerTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photographerState = ref.watch(photographerNotifierProvider);

    if (photographerState.photographers.isEmpty) {
      return const SizedBox.shrink();
    }

    // 최대 6명만 표시
    final displayPhotographers =
        photographerState.photographers.take(6).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '인기 작가',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 16, // 가로 간격
          runSpacing: 16, // 세로 간격
          children: displayPhotographers.map((photographer) {
            return _buildPhotographerCard(photographer, ref);
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPhotographerCard(Photographer photographer, WidgetRef ref) {
    return SizedBox(
      width: 110,
      height: 140,
      child: GestureDetector(
        onTap: () => onPhotographerTap(photographer),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 작가 이미지
              Expanded(
                flex: 3,
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                      child: Image.asset(
                        photographer.imageUrl,
                        height: double.infinity,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: double.infinity,
                            width: double.infinity,
                            color: Colors.grey[200],
                            child: const Center(
                              child: Icon(Icons.person, color: Colors.grey),
                            ),
                          );
                        },
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () {
                          // 좋아요 토글 기능
                          ref
                              .read(photographerNotifierProvider.notifier)
                              .toggleLike(photographer.id);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.8),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            photographer.isLiked
                                ? Icons.favorite
                                : Icons.favorite_border,
                            size: 16,
                            color:
                                photographer.isLiked ? Colors.red : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // 작가 정보
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        photographer.businessName,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            size: 12,
                            color: Colors.amber[600],
                          ),
                          const SizedBox(width: 2),
                          Text(
                            photographer.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '(${photographer.reviewCount})',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
