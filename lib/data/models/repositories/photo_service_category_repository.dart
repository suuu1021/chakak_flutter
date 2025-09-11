import 'package:flutter/material.dart';
import 'package:chakak_flutter/_core/constants/app_strings.dart';
import 'package:chakak_flutter/_core/constants/app_images.dart';

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
        backgroundColor: Colors.orange,
      ),
      PhotoServiceCategory(
        id: 'categoryCouple',
        name: AppStrings.categoryCouple,
        categoryImageData: AppImages.onboarding2,
        backgroundColor: Colors.red,
      ),
      PhotoServiceCategory(
        id: 'categoryWedding',
        name: AppStrings.categoryWedding,
        categoryImageData: AppImages.onboarding2,
        backgroundColor: Colors.brown,
      ),
      PhotoServiceCategory(
        id: 'categoryEvent',
        name: AppStrings.categoryEvent,
        categoryImageData: AppImages.onboarding2,
        backgroundColor: Colors.blue,
      ),
      PhotoServiceCategory(
        id: 'categoryFamily',
        name: AppStrings.categoryEvent,
        categoryImageData: AppImages.onboarding2,
        backgroundColor: Colors.green,
      ),
      PhotoServiceCategory(
        id: 'categoryProduct',
        name: AppStrings.categoryEvent,
        categoryImageData: AppImages.onboarding2,
        backgroundColor: Colors.purple,
      ),
    ];

    return mockData;
  }
}
