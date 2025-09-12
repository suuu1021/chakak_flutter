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
      ),
      PhotographerCategory(
        id: 'categoryCouple',
        name: AppStrings.categoryCouple,
      ),
      PhotographerCategory(
        id: 'categoryWedding',
        name: AppStrings.categoryWedding,
      ),
      PhotographerCategory(
        id: 'categoryEvent',
        name: AppStrings.categoryEvent,
      ),
    ];

    return mockData;
  }
}
