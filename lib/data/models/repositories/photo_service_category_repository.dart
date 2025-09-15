import 'package:chakak_flutter/_core/constants/app_images.dart';
import 'package:chakak_flutter/_core/constants/app_strings.dart';

import '../photo_service_category.dart';

abstract class PhotoServiceCategoryRepository {
  Future<List<PhotoServiceCategory>> getCategories();
}

class PhotoServiceCategoryRepositoryImpl
    implements PhotoServiceCategoryRepository {
  @override
  Future<List<PhotoServiceCategory>> getCategories() async {
    // TODO: 실제 API 호출로 교체
    await Future.delayed(const Duration(milliseconds: 300));

    final mockData = [
      PhotoServiceCategory(
        id: 'categoryPersonal',
        name: AppStrings.categoryPersonal,
        categoryImageData: AppImages.onboarding, // 다양한 이미지 사용
      ),
      PhotoServiceCategory(
        id: 'categoryCouple',
        name: AppStrings.categoryCouple,
        categoryImageData: AppImages.onboarding2,
      ),
      PhotoServiceCategory(
        id: 'categoryWedding',
        name: AppStrings.categoryWedding,
        categoryImageData:
            'https://images.unsplash.com/photo-1606216794074-735e91aa2c92?w=400', // 웨딩 이미지
      ),
      PhotoServiceCategory(
        id: 'categoryEvent',
        name: AppStrings.categoryEvent,
        categoryImageData:
            'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=400', // 이벤트 이미지
      ),
      PhotoServiceCategory(
        id: 'categoryFamily',
        name: '가족사진', // AppStrings.categoryFamily가 있다면 교체
        categoryImageData:
            'https://images.unsplash.com/photo-1511285560929-80b456fea0bc?w=400', // 가족 이미지
      ),
      PhotoServiceCategory(
        id: 'categoryProduct',
        name: '제품촬영', // AppStrings.categoryProduct가 있다면 교체
        categoryImageData:
            'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=400', // 제품/공간 이미지
      ),
      // 추가 카테고리들
      PhotoServiceCategory(
        id: 'categoryPet',
        name: '반려동물',
        categoryImageData:
            'https://images.unsplash.com/photo-1425082661705-1834bfd09dca?w=400',
      ),
      PhotoServiceCategory(
        id: 'categoryInterior',
        name: '인테리어',
        categoryImageData:
            'https://images.unsplash.com/photo-1618221195710-dd6b41faaea6?w=400',
      ),
    ];

    return mockData;
  }
}
