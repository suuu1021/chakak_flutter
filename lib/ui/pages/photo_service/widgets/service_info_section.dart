import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // <<< IMPORT 추가
import '../../../../../../_core/constants/app_colors.dart';
import '../../../../../../_core/constants/app_sizes.dart';
import '../../../../../../data/models/photo_service/photo_service.dart';
import '../../../../../../provider/review/review_provider.dart'; // <<< IMPORT 추가

// vvv StatelessWidget에서 ConsumerWidget으로 변경
class ServiceInfoSection extends ConsumerWidget {
  final PhotoService service;

  const ServiceInfoSection({
    super.key,
    required this.service,
  });

  @override
  // vvv build 메소드에 WidgetRef ref 추가
  Widget build(BuildContext context, WidgetRef ref) {
    // vvv reviewStatusProvider 상태를 watch
    final reviewStatusState = ref.watch(reviewStatusProvider);

    // 기본값은 service 객체의 값으로 설정
    String ratingStr = service.rating.toStringAsFixed(1);
    String reviewCountStr = service.reviewCount.toString();

    // reviewStatusProvider가 현재 서비스에 대한 성공적인 데이터를 가지고 있다면 해당 값 사용
    if (reviewStatusState.currentServiceId == service.id &&
        reviewStatusState.status == ReviewServiceFetchStatus.success &&
        reviewStatusState.data != null) {
      ratingStr = reviewStatusState.data!.averageRating.toStringAsFixed(1);
      reviewCountStr = reviewStatusState.data!.totalReviews.toString();
    }
    // 참고: 로딩 중이거나 에러 발생 시에는 자동으로 service 객체의 초기값이 사용됩니다.
    // 만약 로딩 중에 "..." 같은 다른 표시를 원하시면 이 부분에 else if 조건을 추가할 수 있습니다.

    return Padding(
      padding: const EdgeInsets.all(AppSizes.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitle(), // 기존과 동일
          const SizedBox(height: AppSizes.spacing8),
          // vvv _buildRating 호출 시 업데이트된 문자열 값 전달
          _buildRating(ratingStr, reviewCountStr),
          const SizedBox(height: AppSizes.spacing12),
          _buildCategories(), // 기존과 동일
        ],
      ),
    );
  }

  // _buildTitle 메소드는 기존과 동일 (변경 없음)
  Widget _buildTitle() {
    return Text(
      service.title,
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  // vvv _buildRating 메소드가 평점과 리뷰 수를 문자열 파라미터로 받도록 수정
  Widget _buildRating(String rating, String reviewCount) {
    return Row(
      children: [
        const Icon(Icons.star, color: Colors.amber, size: 20),
        const SizedBox(width: AppSizes.spacing4),
        // vvv Text 위젯에서 전달받은 파라미터 사용
        Text(
          '$rating ($reviewCount개)',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // _buildCategories 메소드는 기존과 동일 (AppColors.primary.withValues 부분만 수정 제안)
  Widget _buildCategories() {
    if (service.categories.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: 8.0,
      runSpacing: 4.0,
      children: service.categories.map((category) {
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: AppColors.primary
                .withOpacity(0.1), // withValues 대신 withOpacity 사용
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.primary
                  .withOpacity(0.3), // withValues 대신 withOpacity 사용
            ),
          ),
          child: Text(
            category,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
    );
  }
}
