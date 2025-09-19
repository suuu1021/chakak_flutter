import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../_core/constants/app_colors.dart';
import '../../../../../_core/constants/app_sizes.dart';

class FormImageSelector extends StatelessWidget {
  final List<Object> selectedImages;
  final Function(List<Object>) onChanged;
  final int? thumbnailIndex; // 썸네일로 지정된 이미지의 인덱스
  final Function(int?)? onThumbnailChanged; // 썸네일 변경 콜백

  const FormImageSelector({
    super.key,
    required this.selectedImages,
    required this.onChanged,
    this.thumbnailIndex,
    this.onThumbnailChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              '이미지',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            if (selectedImages.isNotEmpty) ...[
              const SizedBox(width: 8),
              Text(
                '(${selectedImages.length}개)',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: AppSizes.spacing8),
        _buildImageSelector(),
        if (selectedImages.isNotEmpty) ...[
          const SizedBox(height: AppSizes.spacing12),
          const Text(
            '선택된 이미지 (대표 이미지를 선택하세요)',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSizes.spacing8),
          _buildSelectedImages(),
        ],
      ],
    );
  }

  Widget _buildImageSelector() {
    return GestureDetector(
      onTap: () => _pickImages(),
      child: Container(
        width: double.infinity,
        height: 120,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.gray300),
          borderRadius: BorderRadius.circular(8),
          color: AppColors.gray50,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_photo_alternate_outlined,
                size: 40, color: AppColors.gray400),
            const SizedBox(height: AppSizes.spacing8),
            Text(
              selectedImages.isEmpty ? '이미지 선택' : '이미지 추가',
              style: const TextStyle(fontSize: 14, color: AppColors.gray400),
            ),
            if (selectedImages.isEmpty)
              const Text(
                '여러 장 선택 가능',
                style: TextStyle(fontSize: 12, color: AppColors.gray400),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedImages() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: AppSizes.spacing8,
        mainAxisSpacing: AppSizes.spacing8,
        childAspectRatio: 1.0,
      ),
      itemCount: selectedImages.length,
      itemBuilder: (context, index) {
        final isMainImage = thumbnailIndex == index;
        final image = selectedImages[index];

        Widget imageWidget;
        if (image is File) {
          imageWidget = Image.file(image, fit: BoxFit.cover);
        } else if (image is String) {
          imageWidget = Image.network(image, fit: BoxFit.cover);
        } else {
          imageWidget = const Icon(Icons.error_outline);
        }

        return GestureDetector(
          onTap: () => _setMainImage(index),
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: isMainImage
                      ? Border.all(color: AppColors.primary, width: 3)
                      : Border.all(color: AppColors.gray300, width: 1),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: imageWidget,
                ),
              ),
              // 대표 이미지 표시
              if (isMainImage)
                Positioned(
                  top: 4,
                  left: 4,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      '대표',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              // 삭제 버튼
              Positioned(
                top: 4,
                right: 4,
                child: GestureDetector(
                  onTap: () => _removeImage(index),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(4),
                    child: const Icon(
                      Icons.close,
                      size: 14,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
              // 선택 안내
              if (!isMainImage)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.black.withOpacity(0.1),
                    ),
                    child: const Center(
                      child: Text(
                        '터치하여\n대표 이미지 지정',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              offset: Offset(0, 1),
                              blurRadius: 2,
                              color: Colors.black54,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();

    if (images.isNotEmpty) {
      final newImages = images.map((image) => File(image.path)).toList();
      final allImages = [...selectedImages, ...newImages];
      onChanged(allImages);

      // 첫 번째 이미지가 추가되면 자동으로 대표 이미지로 설정
      if (selectedImages.isEmpty && onThumbnailChanged != null) {
        onThumbnailChanged!(0);
      }
    }
  }

  void _removeImage(int index) {
    final newImages = List<Object>.from(selectedImages);
    newImages.removeAt(index);
    onChanged(newImages);

    // 삭제된 이미지가 대표 이미지였다면 첫 번째 이미지를 대표로 설정
    if (onThumbnailChanged != null) {
      if (thumbnailIndex == index) {
        // 삭제된 이미지가 대표였다면
        onThumbnailChanged!(newImages.isNotEmpty ? 0 : null);
      } else if (thumbnailIndex != null && thumbnailIndex! > index) {
        // 대표 이미지 인덱스 조정
        onThumbnailChanged!(thumbnailIndex! - 1);
      }
    }
  }

  void _setMainImage(int index) {
    if (onThumbnailChanged != null) {
      onThumbnailChanged!(index);
    }
  }
}
