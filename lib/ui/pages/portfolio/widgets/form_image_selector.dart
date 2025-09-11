import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../_core/constants/app_colors.dart';
import '../../../../../_core/constants/app_sizes.dart';

class FormImageSelector extends StatelessWidget {
  final List<File> selectedImages;
  final Function(List<File>) onChanged;

  const FormImageSelector({
    super.key,
    required this.selectedImages,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '이미지',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSizes.spacing8),
        _buildImageSelector(),
        if (selectedImages.isNotEmpty) _buildSelectedImages(),
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
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate_outlined,
                size: 40, color: AppColors.gray400),
            SizedBox(height: AppSizes.spacing8),
            Text(
              '이미지 선택',
              style: TextStyle(fontSize: 14, color: AppColors.gray400),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedImages() {
    return Padding(
      padding: const EdgeInsets.only(top: AppSizes.spacing12),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: AppSizes.spacing8,
          mainAxisSpacing: AppSizes.spacing8,
        ),
        itemCount: selectedImages.length,
        itemBuilder: (context, index) {
          return Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: FileImage(selectedImages[index]),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
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
                    padding: const EdgeInsets.all(2),
                    child: const Icon(
                      Icons.close,
                      size: 16,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();

    final newImages = images.map((image) => File(image.path)).toList();
    onChanged(newImages);
  }

  void _removeImage(int index) {
    final newImages = List<File>.from(selectedImages);
    newImages.removeAt(index);
    onChanged(newImages);
  }
}
