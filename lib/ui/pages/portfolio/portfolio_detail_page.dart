import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../_core/constants/app_colors.dart';
import '../../../../_core/constants/app_sizes.dart';
import '../../../data/models/portfolio.dart';

class PortfolioDetailPage extends StatefulWidget {
  final Portfolio portfolio;

  const PortfolioDetailPage({
    super.key,
    required this.portfolio,
  });

  @override
  State<PortfolioDetailPage> createState() => _PortfolioDetailPageState();
}

class _PortfolioDetailPageState extends State<PortfolioDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.portfolio.category),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _sharePortfolio,
            icon: const Icon(Icons.share_outlined),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageGallery(),
            _buildContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildImageGallery() {
    return Column(
      children: widget.portfolio.imageUrls.asMap().entries.map((entry) {
        int index = entry.key;
        String imageUrl = entry.value;

        return Container(
          margin: EdgeInsets.only(
            bottom: index < widget.portfolio.imageUrls.length - 1
                ? AppSizes.spacing12
                : 0,
          ),
          child: _buildImageContainer(imageUrl, index),
        );
      }).toList(),
    );
  }

  Widget _buildImageContainer(String imageUrl, int index) {
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

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.portfolio.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.favorite,
                        size: 16, color: AppColors.white),
                    const SizedBox(width: 4),
                    Text(
                      '${widget.portfolio.likes}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spacing12),
          Text(
            widget.portfolio.description,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: AppSizes.spacing16),
          Row(
            children: [
              _buildInfoChip(
                  Icons.category_outlined, widget.portfolio.category),
              const SizedBox(width: AppSizes.spacing8),
              _buildInfoChip(Icons.calendar_today_outlined,
                  widget.portfolio.formattedDate),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: const BoxDecoration(
        color: AppColors.gray100,
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
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
    final portfolioUrl = 'https://myapp.com/portfolio/${widget.portfolio.id}';
    final shareText =
        '${widget.portfolio.title}\n\n${widget.portfolio.description}\n\n자세히 보기: $portfolioUrl';
    Share.share(shareText);
  }
}
