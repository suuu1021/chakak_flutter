import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/models/photo_service_category.dart';
import '../../../../provider/global/category/photo_service_category_notifier.dart';

class PhotoServiceCategoryWidget extends ConsumerStatefulWidget {
  final Function(PhotoServiceCategory) onCategoryTap;
  final bool showSeeAll;
  final double itemSize;
  final bool showLabels;
  final EdgeInsets? padding;
  final String? title;
  final VoidCallback? onSeeAllTap;

  const PhotoServiceCategoryWidget({
    Key? key,
    required this.onCategoryTap,
    this.showSeeAll = false,
    this.itemSize = 70.0,
    this.showLabels = true,
    this.padding,
    this.title,
    this.onSeeAllTap,
  }) : super(key: key);

  @override
  ConsumerState<PhotoServiceCategoryWidget> createState() =>
      _PhotoServiceCategoryWidgetState();
}

class _PhotoServiceCategoryWidgetState
    extends ConsumerState<PhotoServiceCategoryWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(photoServiceCategoryNotifierProvider.notifier).loadCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    final categoryState = ref.watch(photoServiceCategoryNotifierProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 카테고리 행
        SizedBox(
          height: widget.itemSize + (widget.showLabels ? 40 : 10),
          child: _buildContent(categoryState),
        ),
      ],
    );
  }

  Widget _buildContent(PhotoServiceCategoryState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (state.error != null) {
      return Center(child: Text('에러: ${state.error}'));
    } else if (state.categories.isEmpty) {
      return const Center(child: Text('카테고리가 없습니다.'));
    } else {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: widget.padding ??
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Wrap(
          spacing: 16.0,
          runSpacing: 8.0,
          children: state.categories.map((category) {
            return Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: _buildCategoryItem(category),
            );
          }).toList(),
        ),
      );
    }
  }

  Widget _buildCategoryItem(PhotoServiceCategory category) {
    return GestureDetector(
      onTap: () => widget.onCategoryTap(category),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 원형 이미지
          Container(
            width: widget.itemSize,
            height: widget.itemSize,
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
              child: Image.asset(
                category.categoryImageData,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  print('이미지 로드 에러 ${category.categoryImageData} : $error');
                  return _buildPlaceholder(category);
                },
              ),
            ),
          ),

          if (widget.showLabels) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: widget.itemSize + 10,
              child: Text(
                category.name,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPlaceholder(PhotoServiceCategory category) {
    return Icon(
      Icons.category,
      color: Colors.white,
      size: widget.itemSize * 0.4,
    );
  }
}
