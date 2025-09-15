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
    super.key,
    required this.onCategoryTap,
    this.showSeeAll = false,
    this.itemSize = 70.0,
    this.showLabels = true,
    this.padding,
    this.title,
    this.onSeeAllTap,
  });

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
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipOval(
              child: _buildCategoryImage(category),
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

  Widget _buildCategoryImage(PhotoServiceCategory category) {
    final imageUrl = category.categoryImageData;

    if (imageUrl.isEmpty) {
      return _buildPlaceholder(category);
    }

    if (imageUrl.startsWith('http')) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          print('카테고리 이미지 로드 에러 $imageUrl : $error');
          return _buildPlaceholder(category);
        },
      );
    }

    return Image.asset(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        print('카테고리 이미지 로드 에러 $imageUrl : $error');
        return _buildPlaceholder(category);
      },
    );
  }

  Widget _buildPlaceholder(PhotoServiceCategory category) {
    return Container(
      color: Colors.grey[200],
      child: Icon(
        Icons.category,
        color: Colors.grey[600],
        size: widget.itemSize * 0.4,
      ),
    );
  }
}
