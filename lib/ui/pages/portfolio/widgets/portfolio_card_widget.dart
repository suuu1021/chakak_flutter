import 'package:flutter/material.dart';
import '../../../../_core/constants/app_colors.dart';
import '../../../../_core/constants/app_sizes.dart';
import '../../../../data/models/portfolio.dart';

class PortfolioCardWidget extends StatelessWidget {
  final Portfolio portfolio;
  final VoidCallback? onTap;

  const PortfolioCardWidget({
    super.key,
    required this.portfolio,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: _buildCardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPortfolioImage(),
            _buildPortfolioContent(),
          ],
        ),
      ),
    );
  }

  BoxDecoration _buildCardDecoration() {
    return const BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.all(Radius.circular(AppSizes.radiusMedium)),
      boxShadow: [
        BoxShadow(
          color: AppColors.shadowLight,
          blurRadius: 6,
          offset: Offset(0, 2),
        ),
      ],
    );
  }

  Widget _buildPortfolioImage() {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(AppSizes.radiusMedium),
      ),
      child: Stack(
        children: [
          _buildImageContainer(),
          _buildCategoryBadge(),
          _buildLikeButton(),
        ],
      ),
    );
  }

  Widget _buildImageContainer() {
    return Container(
      width: double.infinity,
      height: 200,
      child: portfolio.firstImageUrl.isNotEmpty
          ? Image.network(
              portfolio.firstImageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                debugPrint('이미지 로드 에러 ${portfolio.firstImageUrl} : $error');
                return _buildPlaceholderImage();
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return _buildLoadingImage();
              },
            )
          : _buildPlaceholderImage(),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: AppColors.gray200,
      child: const Icon(
        Icons.photo_camera_outlined,
        size: 48,
        color: AppColors.gray400,
      ),
    );
  }

  Widget _buildLoadingImage() {
    return Container(
      color: AppColors.gray200,
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildCategoryBadge() {
    return Positioned(
      top: AppSizes.spacing8,
      left: AppSizes.spacing8,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.spacing8,
          vertical: AppSizes.spacing4,
        ),
        decoration: const BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        child: Text(
          portfolio.category,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textOnPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildLikeButton() {
    return Positioned(
      top: AppSizes.spacing8,
      right: AppSizes.spacing8,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.spacing8,
          vertical: AppSizes.spacing4,
        ),
        decoration: BoxDecoration(
          color: Color(0xB3000000), // AppColors.black with 70% opacity
          borderRadius: const BorderRadius.all(Radius.circular(12)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.favorite,
              size: 14,
              color: AppColors.error,
            ),
            const SizedBox(width: 4),
            Text(
              '${portfolio.likes}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPortfolioContent() {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.spacing12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitleAndDate(),
          const SizedBox(height: AppSizes.spacing6),
          _buildDescription(),
        ],
      ),
    );
  }

  Widget _buildTitleAndDate() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            portfolio.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text(
          portfolio.formattedDate,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return Text(
      portfolio.description,
      style: const TextStyle(
        fontSize: 14,
        color: AppColors.textSecondary,
        height: 1.4,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }
}
