import 'package:chakak_flutter/_core/constants/app_strings.dart';
import 'package:chakak_flutter/_core/constants/app_images.dart';

import '../photo_service.dart';

abstract class PhotoServiceRepository {
  Future<List<PhotoService>> getServices();
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
        title: '추억이 될 오늘을 스냅으로 담아드려요',
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
    ];

    return mockData;
  }

  @override
  Future<void> updateLikeStatus(int serviceId, bool isLiked) async {
    // TODO: 실제 API 호출로 교체
    print('서비스 좋아요 상태 업데이트: $serviceId, $isLiked');
  }
}
