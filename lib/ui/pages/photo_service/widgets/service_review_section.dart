import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../_core/constants/app_sizes.dart';
import '../../../../../../data/models/photo_service/photo_service.dart';
import '../../../../../../data/models/review.dart';
import '../../../../../../provider/review/review_provider.dart';
import '../../review/widgets/review_card_widget.dart';

class ServiceReviewSection extends ConsumerWidget {
  final PhotoService service;
  final VoidCallback? onViewAllTap;

  const ServiceReviewSection({
    super.key,
    required this.service,
    this.onViewAllTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentReviews = ref.watch(recentReviewsProvider(service.id));

    return Padding(
      padding: const EdgeInsets.all(AppSizes.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: AppSizes.spacing12),
          recentReviews.when(
            data: (reviewDtoList) {
              if (reviewDtoList.isEmpty) {
                return _buildNoReviews();
              }
              return Column(
                children: reviewDtoList.take(5).map((reviewDto) {
                  final Review reviewModel = reviewDto.toModel();
                  return ReviewCardWidget(
                    review: reviewModel,
                    mode: "user",
                  );
                }).toList(),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Text("리뷰 불러오기 실패: $err"),
          ),
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

  Widget _buildNoReviews() {
    return const Text(
      '아직 리뷰가 없습니다.',
      style: TextStyle(
        fontSize: 14,
        color: Colors.grey,
      ),
    );
  }

  void _defaultViewAllTap() {
    // ignore: avoid_print
    print('모든 리뷰 보기 - serviceId: ${service.id}');
  }
}
