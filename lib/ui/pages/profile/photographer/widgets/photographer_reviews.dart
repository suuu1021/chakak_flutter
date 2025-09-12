import 'package:flutter/material.dart';

import '../../../../../_core/constants/app_colors.dart';

// 리뷰 데이터 모델
class ReviewData {
  final String userName;
  final String userProfileImage;
  final double rating;
  final String reviewText;
  final DateTime reviewDate;
  final List<String> reviewImages;
  final String serviceType;

  const ReviewData({
    required this.userName,
    required this.userProfileImage,
    required this.rating,
    required this.reviewText,
    required this.reviewDate,
    this.reviewImages = const [],
    required this.serviceType,
  });
}

class PhotographerReviews extends StatelessWidget {
  const PhotographerReviews({super.key});

  // 샘플 리뷰 데이터
  static final List<ReviewData> _sampleReviews = [
    ReviewData(
      userName: "김민수",
      userProfileImage: "https://via.placeholder.com/40",
      rating: 5.0,
      reviewText:
          "정말 만족스러운 촬영이었습니다! 포토그래퍼님이 디렉팅도 잘해주시고, 자연스러운 표정을 잘 이끌어내주셨어요. 결과물도 기대 이상으로 만족합니다.",
      reviewDate: DateTime(2024, 8, 15),
      reviewImages: [
        "https://via.placeholder.com/80x80",
        "https://via.placeholder.com/80x80",
      ],
      serviceType: "프리미엄",
    ),
    ReviewData(
      userName: "박지영",
      userProfileImage: "https://via.placeholder.com/40",
      rating: 4.5,
      reviewText: "세심한 준비와 꼼꼼한 촬영 진행이 인상적이었습니다. 다양한 컨셉으로 촬영해주셔서 선택의 폭이 넓었어요.",
      reviewDate: DateTime(2024, 8, 10),
      reviewImages: [
        "https://via.placeholder.com/80x80",
      ],
      serviceType: "시그니처",
    ),
    ReviewData(
      userName: "이동훈",
      userProfileImage: "https://via.placeholder.com/40",
      rating: 5.0,
      reviewText:
          "커플 촬영으로 이용했는데 분위기 연출을 정말 잘해주세요. 둘 다 사진 찍는 게 어색했는데 편안하게 촬영할 수 있었습니다.",
      reviewDate: DateTime(2024, 8, 5),
      reviewImages: [],
      serviceType: "에센셜",
    ),
    ReviewData(
      userName: "최수빈",
      userProfileImage: "https://via.placeholder.com/40",
      rating: 4.8,
      reviewText: "프로필 사진 촬영 목적으로 방문했는데 결과가 너무 만족스럽네요. 보정도 자연스럽게 잘해주셨습니다.",
      reviewDate: DateTime(2024, 7, 28),
      reviewImages: [
        "https://via.placeholder.com/80x80",
        "https://via.placeholder.com/80x80",
        "https://via.placeholder.com/80x80",
      ],
      serviceType: "프리미엄",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildReviewHeader(),
        const SizedBox(height: 20),
        _buildReviewsList(),
      ],
    );
  }

  // 리뷰 헤더 (평점 통계)
  Widget _buildReviewHeader() {
    final double averageRating = _calculateAverageRating();
    final int totalReviews = _sampleReviews.length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // 평점 표시
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
          // 평점 분포 (간단히)
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildRatingBar(5, _countRatingsByScore(5), totalReviews),
              _buildRatingBar(4, _countRatingsByScore(4), totalReviews),
              _buildRatingBar(3, _countRatingsByScore(3), totalReviews),
            ],
          ),
        ],
      ),
    );
  }

  // 리뷰 목록
  Widget _buildReviewsList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _sampleReviews.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        return _buildReviewCard(_sampleReviews[index]);
      },
    );
  }

  // 개별 리뷰 카드
  Widget _buildReviewCard(ReviewData review) {
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
          // 사용자 정보 및 평점
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.gray300,
                child: Text(
                  review.userName[0],
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
                    Row(
                      children: [
                        Text(
                          review.userName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            review.serviceType,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _buildStarRating(review.rating),
                        const SizedBox(width: 8),
                        Text(
                          _formatDate(review.reviewDate),
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

          // 리뷰 텍스트
          Text(
            review.reviewText,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
              height: 1.4,
            ),
          ),

          // 리뷰 이미지 (있는 경우)
          if (review.reviewImages.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildReviewImages(review.reviewImages),
          ],
        ],
      ),
    );
  }

  // 별점 표시 위젯
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

  // 평점 분포 바
  Widget _buildRatingBar(int starCount, int count, int total) {
    final double percentage = total > 0 ? count / total : 0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$starCount',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 4),
          Container(
            width: 60,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.gray200,
              borderRadius: BorderRadius.circular(2),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: percentage,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '$count',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // 리뷰 이미지 표시
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

  // 유틸리티 메서드들
  double _calculateAverageRating() {
    if (_sampleReviews.isEmpty) return 0.0;
    final double sum =
        _sampleReviews.fold(0.0, (sum, review) => sum + review.rating);
    return sum / _sampleReviews.length;
  }

  int _countRatingsByScore(int score) {
    return _sampleReviews
        .where((review) => review.rating.floor() == score)
        .length;
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
