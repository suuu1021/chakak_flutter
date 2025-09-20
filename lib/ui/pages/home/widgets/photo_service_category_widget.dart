import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/models/photo_service_category.dart';
import '../../../../provider/global/category/photo_service_category_provider.dart';

class PhotoServiceCategoryWidget extends ConsumerStatefulWidget {
  final Function(PhotoServiceCategory category) onCategorySelected;
  final double height;
  final EdgeInsets padding;

  const PhotoServiceCategoryWidget({
    Key? key,
    required this.onCategorySelected,
    this.height = 80.0,
    this.padding = const EdgeInsets.symmetric(vertical: 0.0, horizontal: 16.0),
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
      ref.read(photoServiceCategoryProvider.notifier).loadCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    final categoryState = ref.watch(photoServiceCategoryProvider);

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
    final bool isSelected = _selectedCategory?.id == category.id;

    Widget imageWidget;
    if (category.categoryImageData.isNotEmpty) {
      // URL인지 Base64인지 확인
      if (category.categoryImageData.startsWith('http')) {
        // 네트워크 이미지 처리
        imageWidget = ClipOval(
          child: Image.network(
            category.categoryImageData,
            width: 60,
            height: 60,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(Icons.photo, color: Colors.grey[400], size: 24),
                ),
              );
            },
          ),
        );
      } else {
        // Base64 이미지 처리
        try {
          String base64String = category.categoryImageData;
          if (base64String.startsWith('data:image')) {
            base64String = base64String.split(',').last;
          }
          Uint8List imageBytes = base64Decode(base64String);
          imageWidget = ClipOval(
            child: Image.memory(
              imageBytes,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(Icons.photo, color: Colors.grey[400], size: 24),
                  ),
                );
              },
            ),
          );
        } catch (e) {
          imageWidget = Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(Icons.photo, color: Colors.grey[400], size: 24),
            ),
          );
        }
      }
    } else {
      // 기본 이미지
      imageWidget = Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Icon(Icons.photo, color: Colors.grey[400], size: 24),
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
        width: 60,
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                // border: isSelected
                //     ? Border.all(
                //         color: Theme.of(context).primaryColor, width: 2)
                //     : null,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: imageWidget,
            ),
            const SizedBox(height: 8),
            Text(
              category.name,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                // color: isSelected
                //     ? Theme.of(context).primaryColor
                //     : Colors.black87,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
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
          valueColor:
              AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
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
                      .read(photoServiceCategoryProvider.notifier)
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
