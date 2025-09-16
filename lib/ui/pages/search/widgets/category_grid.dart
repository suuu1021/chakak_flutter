import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/models/photo_service_category.dart';
import '../../../../provider/global/category/photo_service_category_notifier.dart';

class CategoryGrid extends ConsumerWidget {
  final Function(PhotoServiceCategory) onCategoryTap;
  final bool showSeeAll;

  const CategoryGrid({
    super.key,
    required this.onCategoryTap,
    this.showSeeAll = true,
  });

  Widget build(BuildContext context, WidgetRef ref) {
    final categoryState = ref.watch(photoServiceCategoryNotifierProvider);

    if (categoryState.categories.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showSeeAll)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '카테고리',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  print('카테고리 전체 보기');
                },
                child: Text(
                  '전체보기',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          )
        else
          const Text(
            '카테고리',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 16, // 가로 간격
          runSpacing: 16, // 세로 간격
          children: categoryState.categories.map((category) {
            return _buildCategoryCard(category);
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCategoryCard(PhotoServiceCategory category) {
    return SizedBox(
      width: 80, // 전체 카드 너비 제한
      child: GestureDetector(
        onTap: () => onCategoryTap(category),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 원형 이미지
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipOval(
                child: category.categoryImageData.startsWith('http')
                    ? Image.network(
                        category.categoryImageData,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[200],
                            child: Icon(
                              Icons.category,
                              color: Colors.grey,
                              size: 24,
                            ),
                          );
                        },
                      )
                    : Image.asset(
                        category.categoryImageData,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[200],
                            child: Icon(
                              Icons.category,
                              color: Colors.grey,
                              size: 24,
                            ),
                          );
                        },
                      ),
              ),
            ),
            const SizedBox(height: 8),
            // 카테고리 이름
            Text(
              category.name,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
