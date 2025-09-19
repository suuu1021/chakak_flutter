import 'dart:io';

import 'package:dio/dio.dart';

import '../../../_core/constants/api_config.dart';
import '../../dtos/photographer_category_dto.dart';
import '../photographer_category.dart';

abstract class PhotographerCategoryRepository {
  Future<List<PhotographerCategory>> getCategories();
  Future<void> createCategory(PhotographerCategory category);
  Future<void> updateCategory(String categoryId, PhotographerCategory category);
  Future<void> deleteCategory(String categoryId);
}

class PhotographerCategoryRepositoryImpl
    implements PhotographerCategoryRepository {
  final Dio _dio = Dio();

  // 플랫폼별 서버 주소 설정
  static String get serverUrl {
    if (Platform.isAndroid) {
      return ApiConfig.baseUrl;
    } else if (Platform.isIOS) {
      return ApiConfig.baseUrl;
    } else {
      return ApiConfig.baseUrl;
    }
  }

  @override
  Future<List<PhotographerCategory>> getCategories() async {
    try {
      final response =
          await _dio.get('$serverUrl/api/photographer/categories/list');

      if (response.statusCode == 200) {
        final Map<String, dynamic> apiResponse = response.data;

        final List<dynamic> categoryListFromResponse =
            apiResponse['body'] as List<dynamic>;

        final List<PhotographerCategory> categories =
            categoryListFromResponse.map((item) {
          final PhotographerCategoryDto dto =
              PhotographerCategoryDto.fromJson(item as Map<String, dynamic>);
          return PhotographerCategory.fromDto(dto);
        }).toList();

        return categories;
      } else {
        throw Exception(
            'Failed to load photographer categories: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching photographer categories: $e');
      throw Exception('Error fetching photographer categories: $e');
    }
  }

  @override
  Future<void> createCategory(PhotographerCategory category) async {
    try {
      final response = await _dio.post(
        '$serverUrl/api/photographer/categories',
        data: {
          'name': category.name,
        },
      );

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to create photographer category: ${response.statusCode}');
      }
    } catch (e) {
      print('Error creating photographer category: $e');
      throw Exception('Error creating photographer category: $e');
    }
  }

  @override
  Future<void> updateCategory(
      String categoryId, PhotographerCategory category) async {
    try {
      final response = await _dio.patch(
        '$serverUrl/api/photographer/categories/$categoryId',
        data: {
          'name': category.name,
        },
      );

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to update photographer category: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating photographer category: $e');
      throw Exception('Error updating photographer category: $e');
    }
  }

  @override
  Future<void> deleteCategory(String categoryId) async {
    try {
      final response = await _dio
          .delete('$serverUrl/api/photographer/categories/$categoryId');

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to delete photographer category: ${response.statusCode}');
      }
    } catch (e) {
      print('Error deleting photographer category: $e');
      throw Exception('Error deleting photographer category: $e');
    }
  }
}
