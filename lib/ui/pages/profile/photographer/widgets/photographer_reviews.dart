import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../_core/constants/app_colors.dart';
import '../../../../../data/models/repositories/photo_service_repository.dart';
import '../../../../../data/models/review.dart';
import '../../../../../provider/chat/chat_provider.dart';

// 3단계: Provider 생성
final reviewsProvider =
    FutureProvider.family<ReviewPage, int>((ref, serviceId) async {
  final repository = ref.watch(photoServiceRepositoryProvider);
  return repository.fetchReviews(serviceId: serviceId);
});

// 4단계: UI 수정
class PhotographerReviews extends ConsumerWidget {
  final int serviceId;

  const PhotographerReviews({super.key, required this.serviceId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewsAsyncValue = ref.watch(reviewsProvider(serviceId));

    return reviewsAsyncValue.when(
      data: (reviewPage) {
        if (reviewPage.empty) {
          return const Center(child: Text("아직 작성된 리뷰가 없습니다."));
        }

        final double averageRating = reviewPage.content.isNotEmpty
            ? reviewPage.content.map((r) => r.rating).reduce((a, b) => a + b) /
                reviewPage.content.length
            : 0.0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildReviewHeader(reviewPage, averageRating),
            const SizedBox(height: 20),
            _buildReviewsList(reviewPage.content),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) =>
          Center(child: Text("리뷰를 불러오는 중 오류가 발생했습니다: $error")),
    );
  }

  Widget _buildReviewHeader(ReviewPage reviewPage, double averageRating) {
    return Container(
      padding: const EdgeInsets.all(20),
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
                '${reviewPage.totalElements}개의 리뷰',
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

  Widget _buildReviewsList(List<Review2> reviews) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: reviews.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        return _buildReviewCard(reviews[index]);
      },
    );
  }

  Widget _buildReviewCard(Review2 review) {
    return Container(
      padding: const EdgeInsets.all(16),
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
                      : "",
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
            review.content,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
              height: 1.4,
            ),
          ),
          if (review.thumbnailUrl != null) ...[
            const SizedBox(height: 12),
            _buildReviewImages([review.thumbnailUrl!]),
          ],
        ],
      ),
    );
  }

  Widget _buildStarRating(double rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        if (index < rating.floor()) {
          return const Icon(
            Icons.star,
            size: 16,
            color: AppColors.primary,
          );
        } else if (index < rating) {
          return const Icon(
            Icons.star_half,
            size: 16,
            color: AppColors.primary,
          );
        } else {
          return const Icon(
            Icons.star_border,
            size: 16,
            color: AppColors.gray400,
          );
        }
      }),
    );
  }

  Widget _buildReviewImages(List<String> images) {
    return SizedBox(
      height: 80,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          return Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: AppColors.gray200,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                images[index],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.image,
                    color: AppColors.gray400,
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

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
