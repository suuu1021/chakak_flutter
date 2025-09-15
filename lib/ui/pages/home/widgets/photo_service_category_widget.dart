import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/models/photo_service_category.dart';
import '../../../../provider/global/category/photo_service_category_notifier.dart';

class PhotoServiceCategoryWidget extends ConsumerStatefulWidget {
  final Function(PhotoServiceCategory category) onCategorySelected;
  final double height;
  final EdgeInsets padding;

  const PhotoServiceCategoryWidget({
    Key? key,
    required this.onCategorySelected,
    this.height = 120.0,
    this.padding = const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
  }) : super(key: key);

  @override
  ConsumerState<PhotoServiceCategoryWidget> createState() =>
      _PhotoServiceCategoryWidgetState();
}

class _PhotoServiceCategoryWidgetState
    extends ConsumerState<PhotoServiceCategoryWidget> {
  PhotoServiceCategory? _selectedCategory;

  @override
  void initState() {
    super.initState();
    // 카테고리 데이터 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(photoServiceCategoryNotifierProvider.notifier).loadCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    final categoryState = ref.watch(photoServiceCategoryNotifierProvider);

    if (categoryState.isLoading && categoryState.categories.isEmpty) {
      return _buildLoading();
    }

    if (categoryState.error != null && categoryState.categories.isEmpty) {
      return _buildError(categoryState.error!);
    }

    if (categoryState.categories.isEmpty) {
      return _buildEmpty();
    }

    // 초기 선택 (첫 번째 카테고리)
    if (_selectedCategory == null && categoryState.categories.isNotEmpty) {
      _selectedCategory = categoryState.categories.first;
      // widget.onCategorySelected(_selectedCategory!); // 초기 선택 시 콜백 호출 여부 결정
    }

    return Container(
      height: widget.height,
      padding: widget.padding,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categoryState.categories.length,
        itemBuilder: (context, index) {
          final category = categoryState.categories[index];
          return _buildCategoryItem(category);
        },
      ),
    );
  }

  Widget _buildCategoryItem(PhotoServiceCategory category) {
    final bool isSelected = _selectedCategory?.id ==
        category.id;

    Widget imageWidget;
    if (category.categoryImageData != null &&
        category.categoryImageData!.isNotEmpty) {
      try {
        // Base64 문자열에서 데이터 부분만 추출 (예: "data:image/png;base64," 같은 프리픽스가 있다면 제거)
        String base64String = category.categoryImageData!;
        if (base64String.startsWith('data:image')) {
          base64String = base64String
              .split(',')
              .last;
        }
        Uint8List imageBytes = base64Decode(base64String);
        imageWidget = Image.memory(
          imageBytes,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Icon(Icons.broken_image, color: Colors.grey[400]),
              ),
            );
          },
        );
      } catch (e) {
        print('Error decoding base64 image for category ${category
            .name}: $e');
        imageWidget = Container(
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Icon(Icons.broken_image, color: Colors.grey[400], size: 30),
          ),
        );
      }
    } else {
      // categoryImageData가 없거나 비어있을 경우 대체 위젯
      imageWidget = Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Icon(Icons.photo, color: Colors.grey[400], size: 30),
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = category;
        });
        widget.onCategorySelected(category);
      },
      child: Container(
        width: widget.height - 20, // 높이에서 약간의 패딩을 뺀 너비
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: isSelected
              ? Border.all(color: Theme
              .of(context)
              .primaryColor, width: 2)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.0), // 컨테이너보다 약간 작은 값으로 조정
          child: Stack(
            children: [
              Positioned.fill(
                child: imageWidget, // 여기에 디코딩된 이미지 위젯 사용
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 4.0, horizontal: 6.0),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                  ),
                  child: Text(
                    category.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              if (isSelected)
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Theme
                          .of(context)
                          .primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                        Icons.check, color: Colors.white, size: 12),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return Container(
      height: widget.height,
      padding: widget.padding,
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Theme
              .of(context)
              .primaryColor),
        ),
      ),
    );
  }

  Widget _buildError(String error) {
    return Container(
      height: widget.height,
      padding: widget.padding,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red[300], size: 30),
            const SizedBox(height: 8),
            Text(
              '카테고리 로딩 실패',
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            // Text(error, style: TextStyle(color: Colors.grey[500], fontSize: 10)),
            TextButton(
                onPressed: () {
                  ref
                      .read(photoServiceCategoryNotifierProvider.notifier)
                      .loadCategories();
                },
                child: const Text('재시도'))
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Container(
      height: widget.height,
      padding: widget.padding,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.category_outlined, color: Colors.grey[400], size: 30),
            const SizedBox(height: 8),
            Text('카테고리가 없습니다.', style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }
}
