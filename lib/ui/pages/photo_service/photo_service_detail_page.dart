import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../_core/constants/app_colors.dart';
import '../../../../_core/utils/error_handler.dart';
import '../../../data/dtos/chat_room_create_request_dto.dart';
import '../../../data/models/photo_service/photo_service.dart';
import '../../../data/models/review.dart';
import '../../../provider/auth/session_provider.dart';
import '../../../provider/chat/chat_provider.dart';
import '../../../provider/global/photoService/photo_service_provider.dart';
import '../../../provider/global/photographer/photographer_provider.dart';
import '../../../provider/review/review_provider.dart';

import '../chat/chat_screen.dart';
import '../profile/photographer/photographer_profile_page.dart';
import '../review/review_list_screen.dart';
import '../review/widgets/review_card_widget.dart';
import 'widgets/other_services_section.dart';
import 'widgets/photographer_info_section.dart';
import 'widgets/service_description_section.dart';
import 'widgets/service_gallery_section.dart';
import 'widgets/service_image_section.dart';
import 'widgets/service_info_section.dart';
import 'widgets/service_price_section.dart';

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
        reviewStatusNotifier.fetchStatus(service.id);
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
            ServiceGallerySection(photographerId: service.photographerId),
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
            ReviewPreviewSection(
              serviceId: service.id,
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
            color: Colors.grey.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () => _onBookingTap(context, ref),
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
    try {
      final reviewStatusState = ref.read(reviewStatusProvider);

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

      final shareText = '${service.title}\n'
          '평점: ⭐ $averageRatingStr점 ($totalReviewsStr개 리뷰)\n'
          '가격: ${service.price}원~\n'
          '카테고리: ${service.categories.join(', ')}\n'
          '\n이 서비스를 확인해보세요!';

      Share.share(shareText, subject: service.title);
    } catch (error) {
      ErrorHandler.handleError(context, error,
          customMessage: '공유 중 오류가 발생했습니다');
    }
  }

  void _onBookingTap(BuildContext context, WidgetRef ref) async {
    try {
      final session = ref.read(sessionProvider);

      final photographer = ref
          .read(photographerProvider.notifier)
          .getPhotographerById(service.photographerId);

      final chatRequest = ChatRoomCreateRequestDto(
        photographerProfileId: service.photographerId,
        userProfileId: session.userId,
      );

      final chatRoom = await ref
          .read(chatRepositoryProvider)
          .createOrGetChatRoom(chatRequest);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatScreen(
            chatRoomId: chatRoom.chatRoomId,
            opponentNickname: photographer?.businessName ?? "포토그래퍼",
          ),
        ),
      );
    } catch (error) {
      ErrorHandler.handleError(context, error,
          customMessage: '채팅 연결 중 오류가 발생했습니다');
    }
  }

  void _onPhotographerProfileTap(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            PhotographerProfilePage(photographerId: service.photographerId),
      ),
    );
  }

  void _onOtherServiceTap(BuildContext context, PhotoService otherService) {
    final remainingServices = otherServices
        ?.where((s) => s.id != service.id && s.id != otherService.id)
        .toList();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => PhotoServiceDetailPage(
          service: otherService,
          otherServices: remainingServices,
        ),
      ),
    );
  }

  void _onViewAllReviewsTap(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReviewListScreen(serviceId: service.id),
      ),
    );
  }
}

/// --------------------
/// 리뷰 미리보기 섹션
/// --------------------
class ReviewPreviewSection extends ConsumerWidget {
  final int serviceId;
  final VoidCallback onViewAllTap;

  const ReviewPreviewSection({
    super.key,
    required this.serviceId,
    required this.onViewAllTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncReviews = ref.watch(recentReviewsProvider(serviceId));

    return asyncReviews.when(
      data: (reviews) {
        if (reviews.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text("아직 리뷰가 없습니다."),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 "최근 리뷰" + "모두 보기"를 한 줄에 배치
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "최근 리뷰",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: onViewAllTap,
                    child: const Text("모두 보기"),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            ...reviews.take(5).map(
                  (r) {
                final reviewModel = Review(
                  id: r.id,
                  reviewerId: r.reviewerId,
                  serviceId: r.serviceId,
                  bookingId: r.bookingId,
                  rating: r.rating,
                  reviewContent: r.reviewContent,
                  createdAt: r.createdAt,
                );

                return Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
                  child: ReviewCardWidget(
                    review: reviewModel,
                    mode: "user",
                  ),
                );
              },
            ),
          ],
        );
      },
      loading: () =>
      const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      error: (err, stack) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text("리뷰 불러오기 실패: $err"),
      ),
    );
  }
}
