import 'package:chakak_flutter/_core/constants/app_images.dart';
import 'package:chakak_flutter/_core/constants/app_strings.dart';
import 'package:flutter/material.dart';

class PhotoServiceCategory extends StatelessWidget {
  final List<CategoryItem> categories;
  final Function(CategoryItem) onCategoryTap;
  final double itemSize;
  final bool showLabels;
  final EdgeInsets? padding;
  final MainAxisAlignment alignment;
  final String? title;
  final bool showSeeAll;
  final VoidCallback? onSeeAllTap;

  const PhotoServiceCategory({
    super.key,
    required this.categories,
    required this.onCategoryTap,
    this.itemSize = 70.0,
    this.showLabels = true,
    this.padding,
    this.alignment = MainAxisAlignment.start,
    this.title,
    this.showSeeAll = false,
    this.onSeeAllTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 섹션 제목 (선택적)
        if (title != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title!,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (showSeeAll && onSeeAllTap != null)
                  GestureDetector(
                    onTap: onSeeAllTap,
                    child: Row(
                      children: const [
                        Text(
                          '전체보기',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 12,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

        if (title != null) const SizedBox(height: 16),

        // 카테고리 행
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: padding ??
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: categories.map((category) {
              return Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: _buildCategoryItem(category),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryItem(CategoryItem category) {
    return GestureDetector(
      onTap: () => onCategoryTap(category),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 원형 이미지
          Container(
            width: itemSize,
            height: itemSize,
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
              child: Container(
                decoration: BoxDecoration(
                  color: category.backgroundColor ?? Colors.grey[200],
                ),
                child: category.categoryImageData != null
                    ? Image.asset(category.categoryImageData!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                        print(
                            '이미지 로드 에러 ${category.categoryImageData} : $error');
                        return _buildPlaceholder(category);
                      })
                    : _buildPlaceholder(category),
              ),
            ),
          ),

          if (showLabels) ...[
            const SizedBox(height: 8),
            Text(
              category.name,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPlaceholder(CategoryItem category) {
    return Container(
      decoration: BoxDecoration(
        color: category.backgroundColor ?? Colors.grey[200],
        shape: BoxShape.circle,
      ),
    );
  }
}

// 카테고리 아이템 데이터 클래스
class CategoryItem {
  final String id;
  final String name;
  final String categoryImageData;
  final Color? backgroundColor;

  const CategoryItem({
    required this.id,
    required this.name,
    required this.categoryImageData,
    this.backgroundColor,
  });

  static List<CategoryItem> photoServiceCategories() {
    return [
      const CategoryItem(
        id: 'categoryPersonal',
        name: AppStrings.categoryPersonal,
        categoryImageData: AppImages.onboarding2,
        backgroundColor: Colors.orange,
      ),
      const CategoryItem(
        id: 'categoryCouple',
        name: AppStrings.categoryCouple,
        categoryImageData: AppImages.onboarding2,
        backgroundColor: Colors.red,
      ),
      const CategoryItem(
        id: 'categoryWedding',
        name: AppStrings.categoryWedding,
        categoryImageData: AppImages.onboarding2,
        backgroundColor: Colors.brown,
      ),
      const CategoryItem(
        id: 'categoryEvent',
        name: AppStrings.categoryEvent,
        categoryImageData: AppImages.onboarding2,
        backgroundColor: Colors.blue,
      ),
      const CategoryItem(
        id: 'categoryPersonal',
        name: AppStrings.categoryPersonal,
        categoryImageData: AppImages.onboarding2,
        backgroundColor: Colors.orange,
      ),
      const CategoryItem(
        id: 'categoryCouple',
        name: AppStrings.categoryCouple,
        categoryImageData: AppImages.onboarding2,
        backgroundColor: Colors.red,
      ),
      const CategoryItem(
        id: 'categoryWedding',
        name: AppStrings.categoryWedding,
        categoryImageData: AppImages.onboarding2,
        backgroundColor: Colors.brown,
      ),
      const CategoryItem(
        id: 'categoryEvent',
        name: AppStrings.categoryEvent,
        categoryImageData: AppImages.onboarding2,
        backgroundColor: Colors.blue,
      ),
    ];
  }
}
