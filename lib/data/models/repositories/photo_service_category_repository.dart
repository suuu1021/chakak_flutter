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
        categoryImageData: AppImages.onboarding2,
      ),
      PhotoServiceCategory(
        id: 'categoryCouple',
        name: AppStrings.categoryCouple,
        categoryImageData: AppImages.onboarding2,
      ),
      PhotoServiceCategory(
        id: 'categoryWedding',
        name: AppStrings.categoryWedding,
        categoryImageData: AppImages.onboarding2,
      ),
      PhotoServiceCategory(
        id: 'categoryEvent',
        name: AppStrings.categoryEvent,
        categoryImageData: AppImages.onboarding2,
      ),
      PhotoServiceCategory(
        id: 'categoryFamily',
        name: AppStrings.categoryEvent,
        categoryImageData: AppImages.onboarding2,
      ),
      PhotoServiceCategory(
        id: 'categoryProduct',
        name: AppStrings.categoryEvent,
        categoryImageData: AppImages.onboarding2,
      ),
    ];

    return mockData;
  }
}
