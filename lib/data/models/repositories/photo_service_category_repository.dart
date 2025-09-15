import 'dart:io';

import 'package:chakak_flutter/_core/constants/app_images.dart';
import 'package:chakak_flutter/_core/constants/app_strings.dart';
import 'package:dio/dio.dart';

import '../../dtos/photo_service_category_dto.dart';
import '../photo_service_category.dart';

abstract class PhotoServiceCategoryRepository {
  Future<List<PhotoServiceCategory>> getCategories();
}

class PhotoServiceCategoryRepositoryImpl
    implements PhotoServiceCategoryRepository {
  final Dio _dio = Dio(); // Dio 인스턴스 생성

  // 플랫폼별 서버 주소 설정
  static String get serverUrl {
    if (Platform.isAndroid) {
      print("object 1");
      return 'http://192.168.0.82:8080';
    } else if (Platform.isIOS) {
      print("object 2");
      return 'http://192.168.0.82:8080';
    } else {
      print("object 3");
      return 'http://192.168.0.82:8080';
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

  Future<List<PhotoServiceCategory>> _getMockData() async {
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
