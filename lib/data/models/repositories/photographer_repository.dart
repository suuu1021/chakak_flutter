import 'package:chakak_flutter/_core/constants/app_strings.dart';
import 'package:chakak_flutter/_core/constants/app_images.dart';
import '../photographer.dart';

abstract class PhotographerRepository {
  Future<List<Photographer>> getPhotographers();
  Future<void> updateLikeStatus(int photographerId, bool isLiked);
}

class PhotographerRepositoryImpl implements PhotographerRepository {
  @override
  Future<List<Photographer>> getPhotographers() async {
    // TODO: 실제 API 호출로 교체
    await Future.delayed(const Duration(milliseconds: 500));

    final mockData = [
      Photographer(
        id: 1,
        businessName: '감성 포토 스튜디오',
        imageUrl: AppImages.onboarding,
        categories: [
          AppStrings.categoryWedding,
          AppStrings.categoryCouple,
          AppStrings.categoryEvent,
        ],
        rating: 4.8,
        reviewCount: 120,
        isLiked: true,
      ),
      Photographer(
        id: 2,
        businessName: '모던 스냅',
        imageUrl: AppImages.onboarding2,
        categories: [
          AppStrings.categoryCouple,
          AppStrings.categoryEvent,
          AppStrings.categoryPersonal,
        ],
        rating: 4.9,
        reviewCount: 98,
        isLiked: false,
      ),
      Photographer(
        id: 3,
        businessName: '빛을 담는 사진관',
        imageUrl: AppImages.onboarding,
        categories: [
          AppStrings.categoryCouple,
          AppStrings.categoryEvent,
          AppStrings.categoryPersonal,
        ],
        rating: 4.7,
        reviewCount: 75,
        isLiked: true,
      ),
    ];

    return mockData;
  }

  @override
  Future<void> updateLikeStatus(int photographerId, bool isLiked) async {
    // TODO: 실제 API 호출로 교체
    print('포토그래퍼 좋아요 상태 업데이트: $photographerId, $isLiked');
  }
}
