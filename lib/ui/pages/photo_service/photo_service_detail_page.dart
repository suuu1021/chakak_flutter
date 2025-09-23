import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../_core/constants/app_colors.dart';
import '../../../../_core/utils/error_handler.dart';
import '../../../data/models/photo_service/photo_service.dart';
import '../../../provider/global/photoService/photo_service_provider.dart';
import '../../../provider/review/review_provider.dart'; // 추가된 import

import '../profile/photographer/photographer_profile_page.dart';
import '../review/review_list_screen.dart';
import 'widgets/service_image_section.dart';
import 'widgets/service_info_section.dart';
import 'widgets/service_price_section.dart';
import 'widgets/service_description_section.dart';
import 'widgets/service_gallery_section.dart';
import 'widgets/photographer_info_section.dart';
import 'widgets/service_review_section.dart';
import 'widgets/other_services_section.dart';

class PhotoServiceDetailPage extends ConsumerWidget {
  final PhotoService service;
  final List<PhotoService>? otherServices;

  const PhotoServiceDetailPage({
    super.key,
    required this.service,
    this.otherServices,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 에러 상태 감지
    ref.listen(photoServiceProvider, (previous, next) {
      if (next.error != null && previous?.error != next.error) {
        ErrorHandler.handleError(context, next.error);
      }
    });

    Future.microtask(() {
      final reviewStatusNotifier = ref.read(reviewStatusProvider.notifier);
      final currentStatus = ref.read(reviewStatusProvider);
      if (currentStatus.currentServiceId != service.id ||
          currentStatus.status == ReviewServiceFetchStatus.initial) {
        print(
            "[PhotoServiceDetailPage] Fetching review status for service ID: ${service.id}");
        reviewStatusNotifier.fetchStatus(service.id);
      } else {
        print(
            "[PhotoServiceDetailPage] Review status for service ID: ${service.id} is already up-to-date or loading.");
      }
    });

    return Scaffold(
      appBar: _buildAppBar(context, ref),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ServiceImageSection(service: service),
            ServiceInfoSection(service: service),
            ServicePriceSection(service: service),
            ServiceDescriptionSection(service: service),
            ServiceGallerySection(service: service),
            PhotographerInfoSection(
              service: service,
              onProfileTap: () => _onPhotographerProfileTap(context),
            ),
            OtherServicesSection(
              service: service,
              otherServices: otherServices,
              onServiceTap: (otherService) =>
                  _onOtherServiceTap(context, otherService),
            ),
            ServiceReviewSection(
              service: service,
              onViewAllTap: () => _onViewAllReviewsTap(context),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(context, ref),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, WidgetRef ref) {
    return AppBar(
      backgroundColor: AppColors.primaryLight,
      title: Text(
        service.title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      actions: [
        IconButton(
          onPressed: () => _onShareTap(context, ref),
          icon: const Icon(Icons.share),
        ),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context, WidgetRef ref) {
    final serviceState = ref.watch(photoServiceProvider);
    final currentService = serviceState.services
        .firstWhere((s) => s.id == service.id, orElse: () => service);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => _onLikeTap(context, ref),
            icon: Icon(
              currentService.isLiked ? Icons.favorite : Icons.favorite_border,
              color: currentService.isLiked ? Colors.red : Colors.grey,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () => _onBookingTap(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                '예약하기',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onShareTap(BuildContext context, WidgetRef ref) {
    print("[PhotoServiceDetailPage] _onShareTap called.");
    try {
      final reviewStatusState = ref.read(reviewStatusProvider);
      print(
          "[PhotoServiceDetailPage] Current reviewStatusState status: ${reviewStatusState.status}, serviceId: ${reviewStatusState.currentServiceId}, data: ${reviewStatusState.data}");

      final String averageRatingStr =
          (reviewStatusState.status == ReviewServiceFetchStatus.success &&
                  reviewStatusState.data != null &&
                  reviewStatusState.currentServiceId == service.id)
              ? reviewStatusState.data!.averageRating.toStringAsFixed(1)
              : service.rating.toStringAsFixed(1);

      final String totalReviewsStr =
          (reviewStatusState.status == ReviewServiceFetchStatus.success &&
                  reviewStatusState.data != null &&
                  reviewStatusState.currentServiceId == service.id)
              ? reviewStatusState.data!.totalReviews.toString()
              : service.reviewCount.toString();

      print(
          "[PhotoServiceDetailPage] Sharing with: ratingStr: $averageRatingStr, reviewsStr: $totalReviewsStr");

      final shareText = '${service.title}\n'
          '평점: ⭐ $averageRatingStr점 ($totalReviewsStr개 리뷰)\n'
          '가격: ${service.price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},R')}원~\n'
          '카테고리: ${service.categories.join(', ')}\n'
          '\n이 서비스를 확인해보세요!';

      Share.share(
        shareText,
        subject: service.title,
      );
    } catch (error) {
      ErrorHandler.handleError(
        context,
        error,
        customMessage: '공유 중 오류가 발생했습니다',
      );
    }
  }

  void _onLikeTap(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(photoServiceProvider.notifier).toggleLike(service.id);
    } catch (error) {
      ErrorHandler.handleError(
        context,
        error,
        customMessage: '찜하기 처리 중 오류가 발생했습니다',
      );
    }
  }

  void _onBookingTap(BuildContext context) {
    try {
      print('예약하기 - serviceId: ${service.id}');
      ErrorHandler.showWarning(context, '예약 기능을 준비 중입니다');
    } catch (error) {
      ErrorHandler.handleError(
        context,
        error,
        customMessage: '예약 처리 중 오류가 발생했습니다',
      );
    }
  }

  void _onPhotographerProfileTap(BuildContext context) {
    try {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PhotographerProfilePage(
            photographerId: service.photographerId,
          ),
        ),
      );
    } catch (error) {
      ErrorHandler.handleError(
        context,
        error,
        customMessage: '포토그래퍼 프로필을 불러올 수 없습니다',
      );
    }
  }

  void _onOtherServiceTap(BuildContext context, PhotoService otherService) {
    try {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PhotoServiceDetailPage(
            service: otherService,
          ),
        ),
      );
    } catch (error) {
      ErrorHandler.handleError(
        context,
        error,
        customMessage: '서비스 페이지를 불러올 수 없습니다',
      );
    }
  }

  void _onViewAllReviewsTap(BuildContext context) {
    try {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ReviewListScreen(serviceId: service.id),
        ),
      );
    } catch (error) {
      ErrorHandler.handleError(
        context,
        error,
        customMessage: '리뷰를 불러올 수 없습니다',
      );
    }
  }
}
