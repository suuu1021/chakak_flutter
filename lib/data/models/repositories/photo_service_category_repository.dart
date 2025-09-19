import 'dart:io';

import 'package:dio/dio.dart';

import '../../../_core/constants/api_config.dart';
import '../../dtos/photo_service_category_dto.dart';
import '../../dtos/photo_service_dto.dart';
import '../photo_service/photo_service.dart';
import '../photo_service_category.dart';

abstract class PhotoServiceCategoryRepository {
  Future<List<PhotoServiceCategory>> getCategories();
  Future<List<PhotoService>> getServicesByCategory(String categoryId);
  Future<void> createCategory(PhotoServiceCategory category);
  Future<void> updateCategory(String categoryId, PhotoServiceCategory category);
  Future<void> deleteCategory(String categoryId);
}

class PhotoServiceCategoryRepositoryImpl
    implements PhotoServiceCategoryRepository {
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
  Future<List<PhotoServiceCategory>> getCategories() async {
    try {
      final response = await _dio.get('$serverUrl/api/photo/categories/list');

      if (response.statusCode == 200) {
        final Map<String, dynamic> apiResponse = response.data;

        final List<dynamic> categoryListFromResponse =
            apiResponse['body'] as List<dynamic>;

        final List<PhotoServiceCategory> categories =
            categoryListFromResponse.map((item) {
          final PhotoServiceCategoryDto dto =
              PhotoServiceCategoryDto.fromJson(item as Map<String, dynamic>);
          return PhotoServiceCategory.fromDto(dto);
        }).toList();

        print(categories);
        return categories;
      } else {
        throw Exception('Failed to load categories: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching categories: $e');
      throw Exception('Error fetching categories: $e');
    }
  }

  @override
  Future<List<PhotoService>> getServicesByCategory(String categoryId) async {
    try {
      final response = await _dio
          .get('$serverUrl/api/photo/mappings/category/$categoryId/services');
      print('Category Services Response: ${response.data}');
      if (response.statusCode == 200) {
        final Map<String, dynamic> apiResponse = response.data;
        final List<dynamic> serviceListFromResponse =
            apiResponse['body'] as List<dynamic>;

        final List<PhotoService> services = serviceListFromResponse.map((item) {
          final PhotoServiceDto dto =
              PhotoServiceDto.fromJson(item as Map<String, dynamic>);
          return PhotoService.fromDto(dto);
        }).toList();

        print('Services for category $categoryId: $services');
        return services;
      } else {
        throw Exception(
            'Failed to load services for category: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching services for category: $e');
      throw Exception('Error fetching services for category: $e');
    }
  }

  @override
  Future<void> createCategory(PhotoServiceCategory category) async {
    try {
      final response = await _dio.post(
        '$serverUrl/api/photo/categories',
        data: {
          'name': category.name,
          'categoryImageData': category.categoryImageData,
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to create category: ${response.statusCode}');
      }
    } catch (e) {
      print('Error creating category: $e');
      throw Exception('Error creating category: $e');
    }
  }

  @override
  Future<void> updateCategory(
      String categoryId, PhotoServiceCategory category) async {
    try {
      final response = await _dio.patch(
        '$serverUrl/api/photo/categories/$categoryId',
        data: {
          'name': category.name,
          'categoryImageData': category.categoryImageData,
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update category: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating category: $e');
      throw Exception('Error updating category: $e');
    }
  }

  @override
  Future<void> deleteCategory(String categoryId) async {
    try {
      final response =
          await _dio.delete('$serverUrl/api/photo/categories/$categoryId');

      if (response.statusCode != 200) {
        throw Exception('Failed to delete category: ${response.statusCode}');
      }
    } catch (e) {
      print('Error deleting category: $e');
      throw Exception('Error deleting category: $e');
    }
  }
}
