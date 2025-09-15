import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../_core/constants/app_colors.dart';
import '../../../data/models/photo_service/photo_service.dart';
import 'widgets/service_image_section.dart';
import 'widgets/service_info_section.dart';
import 'widgets/service_price_section.dart';
import 'widgets/service_description_section.dart';
import 'widgets/service_gallery_section.dart';
import 'widgets/photographer_info_section.dart';
import 'widgets/service_review_section.dart';
import 'widgets/other_services_section.dart';

class PhotoServiceDetailPage extends StatelessWidget {
  final PhotoService service;
  final List<PhotoService>? otherServices;

  const PhotoServiceDetailPage({
    super.key,
    required this.service,
    this.otherServices,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
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
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
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
          onPressed: () => _onShareTap(context),
          icon: const Icon(Icons.share),
        ),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context) {
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
          IconButton(
            onPressed: () => _onLikeTap(context),
            icon: Icon(
              service.isLiked ? Icons.favorite : Icons.favorite_border,
              color: service.isLiked ? Colors.red : Colors.grey,
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

  // 이벤트 핸들러들
  void _onShareTap(BuildContext context) {
    // 공유할 텍스트 생성
    final shareText = '${service.title}\n'
        '평점: ${service.rating.toStringAsFixed(1)}점 (${service.reviewCount}개 리뷰)\n'
        '가격: ${service.priceRange}\n'
        '카테고리: ${service.categories.join(', ')}\n'
        '\n이 서비스를 확인해보세요!';

    Share.share(
      shareText,
      subject: service.title,
    );
  }

  void _onLikeTap(BuildContext context) {
    // TODO: 찜하기 기능 구현
    print('찜하기 - serviceId: ${service.id}, isLiked: ${service.isLiked}');
  }

  void _onBookingTap(BuildContext context) {
    // TODO: 예약하기 기능 구현
    print('예약하기 - serviceId: ${service.id}');
  }

  void _onPhotographerProfileTap(BuildContext context) {
    // TODO: 포토그래퍼 프로필 페이지로 이동
    print('포토그래퍼 프로필 - photographerId: ${service.photographerId}');
  }

  void _onOtherServiceTap(BuildContext context, PhotoService otherService) {
    // TODO: 다른 서비스 상세 페이지로 이동
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => PhotoServiceDetailPage(
          service: otherService,
          otherServices: otherServices,
        ),
      ),
    );
  }

  void _onViewAllReviewsTap(BuildContext context) {
    // TODO: 모든 리뷰 페이지로 이동
    print('모든 리뷰 보기 - serviceId: ${service.id}');
  }
}
