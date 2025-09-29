import 'package:flutter/material.dart';
import '../../../../../_core/constants/app_colors.dart';
import '../../../../../_core/constants/app_sizes.dart';

class PortfolioImageGallery extends StatelessWidget {
  final List<String> imageUrls;

  const PortfolioImageGallery({
    super.key,
    required this.imageUrls,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: imageUrls.asMap().entries.map((entry) {
        int index = entry.key;
        String imageUrl = entry.value;

        return Container(
          margin: EdgeInsets.only(
            bottom: index < imageUrls.length - 1 ? AppSizes.spacing12 : 0,
          ),
          child: _buildImageContainer(imageUrl),
        );
      }).toList(),
    );
  }

  Widget _buildImageContainer(String imageUrl) {
    return Container(
      width: double.infinity,
      height: 300,
      child: Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          color: AppColors.gray200,
          child: const Icon(
            Icons.photo_camera_outlined,
            size: 80,
            color: AppColors.gray400,
          ),
        ),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: AppColors.gray200,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        },
      ),
    );
  }
}
