import 'package:flutter/material.dart';
import '../../../../../../_core/constants/app_sizes.dart';
import '../../../../../../data/models/photo_service/photo_service.dart';

class ServiceReviewSection extends StatelessWidget {
  final PhotoService service;
  final VoidCallback? onViewAllTap;

  const ServiceReviewSection({
    super.key,
    required this.service,
    this.onViewAllTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: AppSizes.spacing12),
          _buildReviewContent(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          '리뷰',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        TextButton(
          onPressed: onViewAllTap ?? _defaultViewAllTap,
          child: const Text('모두 보기'),
        ),
      ],
    );
  }

  Widget _buildReviewContent() {
    // TODO: 실제 리뷰 데이터가 있을 때 리뷰 목록 표시
    if (service.reviewCount == 0) {
      return _buildNoReviews();
    }

    return _buildReviewPlaceholder();
  }

  Widget _buildNoReviews() {
    return const Text(
      '아직 리뷰가 없습니다.',
      style: TextStyle(
        fontSize: 14,
        color: Colors.grey,
      ),
    );
  }

  Widget _buildReviewPlaceholder() {
    return const Text(
      '리뷰가 여기에 표시됩니다.',
      style: TextStyle(
        fontSize: 14,
        color: Colors.grey,
      ),
    );
  }

  void _defaultViewAllTap() {
    print('모든 리뷰 보기 - serviceId: ${service.id}');
  }
}
