
import 'package:flutter/material.dart';

import 'package:chakak_flutter/_core/constants/app_strings.dart';
import 'package:chakak_flutter/_core/constants/app_images.dart';

import '../photographer_category.dart';

abstract class PhotographerCategoryRepository {
  Future<List<PhotographerCategory>> getCategories();
}

class PhotographerCategoryRepositoryImpl
    implements PhotographerCategoryRepository {
  @override
  Future<List<PhotographerCategory>> getCategories() async {
    // TODO: 실제 API 호출로 교체
    await Future.delayed(const Duration(milliseconds: 300));

    final mockData = [
      PhotographerCategory(
        id: 'categoryPersonal',
        name: AppStrings.categoryPersonal,
        categoryImageData: AppImages.onboarding2,
        backgroundColor: Colors.orange,
      ),
      PhotographerCategory(
        id: 'categoryCouple',
        name: AppStrings.categoryCouple,
        categoryImageData: AppImages.onboarding2,
        backgroundColor: Colors.red,
      ),
      PhotographerCategory(
        id: 'categoryWedding',
        name: AppStrings.categoryWedding,
        categoryImageData: AppImages.onboarding2,
        backgroundColor: Colors.brown,
      ),
      PhotographerCategory(
        id: 'categoryEvent',
        name: AppStrings.categoryEvent,
        categoryImageData: AppImages.onboarding2,
        backgroundColor: Colors.blue,
      ),

    ];

    return mockData;
  }
}
