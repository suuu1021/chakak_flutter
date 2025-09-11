import 'package:flutter/material.dart';
import '../../../../_core/constants/app_colors.dart';
import '../../../../_core/constants/app_sizes.dart';

// 포트폴리오 데이터 모델
class Portfolio {
  final String title;
  final String description;
  final String category;
  final String imageUrl;
  final int likes;
  final DateTime createdAt;

  const Portfolio({
    required this.title,
    required this.description,
    required this.category,
    required this.imageUrl,
    required this.likes,
    required this.createdAt,
  });
}

class PhotographerPortfolios extends StatelessWidget {
  const PhotographerPortfolios({super.key});

  static final List<Portfolio> _portfolios = [
    Portfolio(
      title: '골든 아워 커플 촬영',
      description: '한강에서 진행한 커플 촬영입니다. 자연스러운 포즈와 따뜻한 조명으로 로맨틱한 분위기를 연출했습니다.',
      category: '커플',
      imageUrl: 'assets/images/sample1.jpg',
      likes: 127,
      createdAt: DateTime(2024, 3, 15),
    ),
    Portfolio(
      title: '프로필 촬영 - 비즈니스',
      description: '깔끔하고 전문적인 비즈니스 프로필 촬영입니다. 조명과 구도를 통해 신뢰감 있는 이미지를 표현했습니다.',
      category: '프로필',
      imageUrl: 'assets/images/sample2.jpg',
      likes: 89,
      createdAt: DateTime(2024, 3, 10),
    ),
    Portfolio(
      title: '웨딩 스냅 촬영',
      description: '행복한 순간을 담은 웨딩 촬영입니다. 감동적인 순간들을 자연스럽게 포착했습니다.',
      category: '웨딩',
      imageUrl: 'assets/images/sample3.jpg',
      likes: 203,
      createdAt: DateTime(2024, 3, 5),
    ),
    Portfolio(
      title: '가족 야외 촬영',
      description: '공원에서 진행한 가족 촬영입니다. 아이들의 밝은 모습과 가족의 따뜻한 정을 담았습니다.',
      category: '가족',
      imageUrl: 'assets/images/sample4.jpg',
      likes: 156,
      createdAt: DateTime(2024, 2, 28),
    ),
    Portfolio(
      title: '개인 아티스틱 촬영',
      description: '창의적인 컨셉으로 진행한 개인 촬영입니다. 독특한 조명과 구도로 예술적인 감각을 표현했습니다.',
      category: '아티스틱',
      imageUrl: 'assets/images/sample5.jpg',
      likes: 94,
      createdAt: DateTime(2024, 2, 20),
    ),
    Portfolio(
      title: '브랜딩 제품 촬영',
      description: '제품의 특성을 살린 브랜딩 촬영입니다. 깔끔한 배경과 조명으로 제품의 매력을 부각시켰습니다.',
      category: '제품',
      imageUrl: 'assets/images/sample6.jpg',
      likes: 78,
      createdAt: DateTime(2024, 2, 15),
    ),
  ];

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
          '${_portfolios.length}개 작품',
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
      itemCount: _portfolios.length,
      separatorBuilder: (context, index) =>
          const SizedBox(height: AppSizes.spacing12),
      itemBuilder: (context, index) => _buildPortfolioCard(_portfolios[index]),
    );
  }

  Widget _buildPortfolioCard(Portfolio portfolio) {
    return Container(
      decoration: _buildCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPortfolioImage(portfolio),
          _buildPortfolioContent(portfolio),
        ],
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

  Widget _buildPortfolioImage(Portfolio portfolio) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(AppSizes.radiusMedium),
      ),
      child: Stack(
        children: [
          _buildImageContainer(portfolio),
          _buildCategoryBadge(portfolio.category),
          _buildLikeButton(portfolio.likes),
        ],
      ),
    );
  }

  Widget _buildImageContainer(Portfolio portfolio) {
    return Container(
      width: double.infinity,
      height: 200,
      color: AppColors.gray200,
      child: const Icon(
        Icons.photo_camera_outlined,
        size: 48,
        color: AppColors.gray400,
      ),
    );
  }

  Widget _buildCategoryBadge(String category) {
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
          category,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textOnPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildLikeButton(int likes) {
    return Positioned(
      top: AppSizes.spacing8,
      right: AppSizes.spacing8,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.spacing8,
          vertical: AppSizes.spacing4,
        ),
        decoration: BoxDecoration(
          color: AppColors.black.withOpacity(0.7),
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
              '$likes',
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

  Widget _buildPortfolioContent(Portfolio portfolio) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.spacing12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitleAndDate(portfolio),
          const SizedBox(height: AppSizes.spacing6),
          _buildDescription(portfolio.description),
          const SizedBox(height: AppSizes.spacing8),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildTitleAndDate(Portfolio portfolio) {
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
          _formatDate(portfolio.createdAt),
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildDescription(String description) {
    return Text(
      description,
      style: const TextStyle(
        fontSize: 14,
        color: AppColors.textSecondary,
        height: 1.4,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        _buildActionButton(Icons.visibility_outlined, '자세히 보기'),
        const SizedBox(width: AppSizes.spacing8),
        _buildActionButton(Icons.share_outlined, '공유'),
        const Spacer(),
        _buildActionButton(Icons.bookmark_border, '저장'),
      ],
    );
  }

  Widget _buildActionButton(IconData icon, String label) {
    return InkWell(
      onTap: () => print('$label 클릭'),
      borderRadius: const BorderRadius.all(Radius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.spacing8,
          vertical: AppSizes.spacing4,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: AppColors.primary,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }
}
