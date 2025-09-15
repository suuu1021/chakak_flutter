import 'package:chakak_flutter/_core/constants/app_strings.dart';
import 'package:chakak_flutter/_core/constants/app_images.dart';

import '../photo_service/photo_service.dart';

abstract class PhotoServiceRepository {
  Future<List<PhotoService>> getServices();
  Future<List<PhotoService>> getServicesByPhotographer(
      int photographerId); // 추가된 메서드
  Future<void> updateLikeStatus(int serviceId, bool isLiked);
}

class PhotoServiceRepositoryImpl implements PhotoServiceRepository {
  @override
  Future<List<PhotoService>> getServices() async {
    // TODO: 실제 API 호출로 교체
    await Future.delayed(const Duration(milliseconds: 500));

    final mockData = [
      PhotoService(
        id: 1,
        photographerId: 1, // 추가된 필드
        title: '추억이 될 오늘을 스냅으로 담아드려요요요요요요요요요요요요요요',
        imageUrl: AppImages.onboarding,
        categories: [
          AppStrings.categoryWedding,
          AppStrings.categoryCouple,
          AppStrings.categoryEvent,
        ],
        price: 100000,
        rating: 5.0,
        reviewCount: 4,
        isLiked: true,
      ),
      PhotoService(
        id: 2,
        photographerId: 1, // 추가된 필드
        title: '추억이 될 오늘을 스냅으로 담아드려요',
        imageUrl: AppImages.onboarding2,
        categories: [
          AppStrings.categoryWedding,
          AppStrings.categoryCouple,
          AppStrings.categoryEvent,
        ],
        price: 100000,
        rating: 5.0,
        reviewCount: 4,
        isLiked: false,
      ),
      PhotoService(
        id: 3,
        photographerId: 2, // 다른 포토그래퍼
        title: '공간, 인테리어, 숙소 촬영 해드립니다',
        imageUrl:
            'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=400',
        categories: [
          '인테리어',
          '공간촬영',
        ],
        price: 130000,
        rating: 4.8,
        reviewCount: 3,
        isLiked: false,
      ),
      PhotoService(
        id: 4,
        photographerId: 2, // 같은 포토그래퍼의 다른 서비스
        title: '반려동물 홈스냅, 야외스냅 촬영 해드립니다',
        imageUrl:
            'https://images.unsplash.com/photo-1425082661705-1834bfd09dca?w=400',
        categories: [
          '반려동물',
          '야외촬영',
        ],
        price: 120000,
        rating: 5.0,
        reviewCount: 1,
        isLiked: true,
      ),
      PhotoService(
        id: 5,
        photographerId: 3, // 또 다른 포토그래퍼
        title: '공연/연주 촬영, 행사 촬영 해드립니다',
        imageUrl:
            'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=400',
        categories: [
          '공연',
          '행사',
        ],
        price: 120000,
        rating: 4.8,
        reviewCount: 15,
        isLiked: false,
      ),
    ];

    return mockData;
  }

  @override
  Future<List<PhotoService>> getServicesByPhotographer(
      int photographerId) async {
    // TODO: 실제 API 호출로 교체 (예: GET /api/photographers/{photographerId}/services)
    await Future.delayed(const Duration(milliseconds: 300));

    // 전체 서비스에서 해당 포토그래퍼의 서비스만 필터링
    final allServices = await getServices();
    return allServices
        .where((service) => service.photographerId == photographerId)
        .toList();
  }

  @override
  Future<void> updateLikeStatus(int serviceId, bool isLiked) async {
    // TODO: 실제 API 호출로 교체
    print('서비스 좋아요 상태 업데이트: $serviceId, $isLiked');
  }
}
