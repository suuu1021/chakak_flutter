import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../_core/constants/app_colors.dart';
import '../../../../../_core/constants/app_sizes.dart';
import '../../../../../data/models/review.dart';
import '../../../../../provider/global/photographer/photographer_reviews_provider.dart';
import '../../../../../data/dtos/review/review_dto.dart';

/// ✅ 포토그래퍼 전체 리뷰 섹션 위젯
class PhotographerReviewsSection extends ConsumerWidget {
  final int photographerId;

  const PhotographerReviewsSection({
    super.key,
    required this.photographerId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(photographerReviewsProvider(photographerId));

    return state.when(
      data: (reviewPage) {
        if (reviewPage.content.isEmpty) {
          return const Center(child: Text("아직 작성된 리뷰가 없습니다."));
        }

        // ✅ ReviewDto → Review 변환
        final List<Review> reviews =
        reviewPage.content.map((dto) => dto.toModel()).toList();

        final double averageRating = reviews.isNotEmpty
            ? reviews.map((r) => r.rating).reduce((a, b) => a + b) /
            reviews.length
            : 0.0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildReviewHeader(reviewPage.totalElements, averageRating),
            const SizedBox(height: AppSizes.spacing20),
            _buildReviewsList(reviews),
          ],
        );
      },
      loading: () =>
      const Center(child: CircularProgressIndicator()), // 로딩중
      error: (error, stack) =>
          Center(child: Text("리뷰 로딩 실패: $error")), // 에러처리
    );
  }

  /// 리뷰 헤더 (평균 평점 + 개수)
  Widget _buildReviewHeader(int totalReviews, double averageRating) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.spacing16),
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    averageRating.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildStarRating(averageRating),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '$totalReviews개의 리뷰',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const Spacer(),
        ],
      ),
    );
  }

  /// 리뷰 카드 리스트
  Widget _buildReviewsList(List<Review> reviews) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: reviews.length,
      separatorBuilder: (context, index) =>
      const SizedBox(height: AppSizes.spacing16),
      itemBuilder: (context, index) {
        return _buildReviewCard(reviews[index]);
      },
    );
  }

  /// 리뷰 카드 개별
  Widget _buildReviewCard(Review review) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.spacing16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.gray300,
                child: Text(
                  review.author.nickname.isNotEmpty
                      ? review.author.nickname[0]
                      : "?",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.author.nickname,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _buildStarRating(review.rating),
                        const SizedBox(width: 8),
                        Text(
                          _formatDate(DateTime.parse(review.createdAt)),
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            review.content.isNotEmpty ? review.content : "내용 없음",
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  /// 별점 위젯
  Widget _buildStarRating(double rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        if (index < rating.floor()) {
          return const Icon(Icons.star, size: 16, color: AppColors.primary);
        } else if (index < rating) {
          return const Icon(Icons.star_half,
              size: 16, color: AppColors.primary);
        } else {
          return const Icon(Icons.star_border,
              size: 16, color: AppColors.gray400);
        }
      }),
    );
  }

  /// 날짜 포맷
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays < 7) {
      return '${difference.inDays}일 전';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()}주 전';
    } else {
      return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
    }
  }
}
