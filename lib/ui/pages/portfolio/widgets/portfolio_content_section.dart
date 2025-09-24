import 'package:flutter/material.dart';
import '../../../../../_core/constants/app_colors.dart';
import '../../../../../_core/constants/app_sizes.dart';
import '../../../../data/models/portfolio.dart';

class PortfolioContentSection extends StatelessWidget {
  final Portfolio portfolio;

  const PortfolioContentSection({
    super.key,
    required this.portfolio,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitleAndLikes(),
          const SizedBox(height: AppSizes.spacing12),
          _buildDescription(),
          const SizedBox(height: AppSizes.spacing16),
          _buildCategoriesSection(),
          const SizedBox(height: AppSizes.spacing12),
          _buildDateInfo(),
        ],
      ),
    );
  }

  Widget _buildTitleAndLikes() {
    return Row(
      children: [
        Expanded(
          child: Text(
            portfolio.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        // Container(
        //   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        //   decoration: const BoxDecoration(
        //     color: AppColors.primary,
        //     borderRadius: BorderRadius.all(Radius.circular(20)),
        //   ),
        //   child: Row(
        //     mainAxisSize: MainAxisSize.min,
        //     children: [
        //       const Icon(Icons.favorite, size: 16, color: AppColors.white),
        //       const SizedBox(width: 4),
        //       Text(
        //         '${portfolio.likes}',
        //         style: const TextStyle(
        //           fontSize: 14,
        //           fontWeight: FontWeight.w600,
        //           color: AppColors.white,
        //         ),
        //       ),
        //     ],
        //   ),
        // ),
      ],
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

  Widget _buildCategoriesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '카테고리',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSizes.spacing8),
        Wrap(
          spacing: AppSizes.spacing8,
          runSpacing: AppSizes.spacing4,
          children: portfolio.categories.map((category) {
            return _buildCategoryChip(category);
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCategoryChip(String category) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      child: Text(
        category,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.white,
        ),
      ),
    );
  }

  Widget _buildDateInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: const BoxDecoration(
        color: AppColors.gray100,
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.calendar_today_outlined,
              size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(
            portfolio.formattedDate,
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
}
