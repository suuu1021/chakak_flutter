import 'dart:io';

import 'package:chakak_flutter/_core/constants/app_images.dart';
import 'package:chakak_flutter/_core/constants/app_strings.dart';
import 'package:dio/dio.dart';

import '../../../_core/constants/api_config.dart';
import '../../dtos/photo_service_category_dto.dart';
import '../photo_service_category.dart';

abstract class PhotoServiceCategoryRepository {
  Future<List<PhotoServiceCategory>> getCategories();
  Future<void> createCategory(PhotoServiceCategory category);
  Future<void> updateCategory(String categoryId, PhotoServiceCategory category);
  Future<void> deleteCategory(String categoryId);
}

class PhotoServiceCategoryRepositoryImpl
    implements PhotoServiceCategoryRepository {
  final Dio _dio = Dio(); // Dio 인스턴스 생성

  // 플랫폼별 서버 주소 설정
  static String get serverUrl {
    if (Platform.isAndroid) {
      print("object 1");
      return ApiConfig.baseUrl;
    } else if (Platform.isIOS) {
      print("object 2");
      return ApiConfig.baseUrl;
    } else {
      print("object 3");
      return ApiConfig.baseUrl;
    }
  }

  @override
  Future<List<PhotoServiceCategory>> getCategories() async {
    try {
      final response = await _dio.get('$serverUrl/api/photo/categories/list');

      if (response.statusCode == 200) {
        // API 응답 전체는 Map 형태입니다.
        final Map<String, dynamic> apiResponse = response.data;

        // 실제 카테고리 목록은 'body' 키 아래의 리스트입니다.
        final List<dynamic> categoryListFromResponse =
            apiResponse['body'] as List<dynamic>;

        // 각 항목을 DTO로 변환한 후, 모델로 변환합니다.
        final List<PhotoServiceCategory> categories =
            categoryListFromResponse.map((item) {
          // item은 Map<String, dynamic> 형태입니다.
          final PhotoServiceCategoryDto dto =
              PhotoServiceCategoryDto.fromJson(item as Map<String, dynamic>);
          return PhotoServiceCategory.fromDto(dto); // 모델 클래스에 정의된 fromDto 사용
        }).toList();
        print(categories);
        return categories;
      } else {
        // API 요청 실패 시 예외 처리
        throw Exception('Failed to load categories: ${response.statusCode}');
      }
    } catch (e) {
      // 네트워크 오류 또는 기타 예외 처리
      print('Error fetching categories: $e');
      throw Exception('Error fetching categories: $e');
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
