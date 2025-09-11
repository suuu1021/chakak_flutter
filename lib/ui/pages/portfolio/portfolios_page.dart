import 'package:flutter/material.dart';
import '../../../../_core/constants/app_colors.dart';
import '../../../../_core/constants/app_sizes.dart';
import '../../../data/models/portfolio.dart';
import 'portfolio_detail_page.dart';
import 'widgets/portfolio_card_widget.dart';

class PortfolioPage extends StatelessWidget {
  const PortfolioPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        const SizedBox(height: AppSizes.spacing12),
        _buildPortfolioList(),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          '포트폴리오',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          '${Portfolio.samplePortfolios.length}개 작품',
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildPortfolioList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: Portfolio.samplePortfolios.length,
      separatorBuilder: (context, index) =>
          const SizedBox(height: AppSizes.spacing12),
      itemBuilder: (context, index) => PortfolioCardWidget(
        portfolio: Portfolio.samplePortfolios[index],
        onTap: () =>
            _onPortfolioTap(context, Portfolio.samplePortfolios[index]),
      ),
    );
  }

  void _onPortfolioTap(BuildContext context, Portfolio portfolio) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PortfolioDetailPage(portfolio: portfolio),
      ),
    );
  }
}
