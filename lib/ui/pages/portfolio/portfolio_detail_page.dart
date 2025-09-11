import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../_core/constants/app_colors.dart';
import '../../../../_core/constants/app_sizes.dart';
import '../../../data/models/portfolio.dart';

class PortfolioDetailPage extends StatelessWidget {
  final Portfolio portfolio;

  const PortfolioDetailPage({
    super.key,
    required this.portfolio,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageSection(),
            _buildContentSection(),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(
        portfolio.category,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: AppColors.surface,
      elevation: 0,
      actions: [
        IconButton(
          onPressed: _sharePortfolio,
          icon: const Icon(Icons.share_outlined),
        ),
      ],
    );
  }

  Widget _buildImageSection() {
    return Container(
      width: double.infinity,
      height: 300,
      color: AppColors.gray200,
      child: const Icon(
        Icons.photo_camera_outlined,
        size: 80,
        color: AppColors.gray400,
      ),
    );
  }

  Widget _buildContentSection() {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitleRow(),
          const SizedBox(height: AppSizes.spacing12),
          _buildDescription(),
          const SizedBox(height: AppSizes.spacing16),
          _buildInfoRow(),
        ],
      ),
    );
  }

  Widget _buildTitleRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            portfolio.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              height: 1.2,
            ),
          ),
        ),
        const SizedBox(width: AppSizes.spacing8),
        _buildLikeChip(),
      ],
    );
  }

  Widget _buildLikeChip() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.spacing12,
        vertical: AppSizes.spacing6,
      ),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.favorite,
            size: 16,
            color: AppColors.white,
          ),
          const SizedBox(width: 4),
          Text(
            '${portfolio.likes}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    return Text(
      portfolio.description,
      style: const TextStyle(
        fontSize: 16,
        color: AppColors.textSecondary,
        height: 1.5,
      ),
    );
  }

  Widget _buildInfoRow() {
    return Row(
      children: [
        _buildInfoChip(Icons.category_outlined, portfolio.category),
        const SizedBox(width: AppSizes.spacing8),
        _buildInfoChip(Icons.calendar_today_outlined, portfolio.formattedDate),
      ],
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.spacing12,
        vertical: AppSizes.spacing8,
      ),
      decoration: const BoxDecoration(
        color: AppColors.gray100,
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _sharePortfolio() {
    final portfolioUrl = 'https://myapp.com/portfolio/${portfolio.id}';
    final shareText =
        '${portfolio.title}\n\n${portfolio.description}\n\n자세히 보기: $portfolioUrl';
    Share.share(shareText);
  }
}
