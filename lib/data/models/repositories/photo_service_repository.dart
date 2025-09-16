import 'dart:io';

import 'package:chakak_flutter/_core/constants/app_strings.dart';
import 'package:chakak_flutter/_core/constants/app_images.dart';
import 'package:chakak_flutter/data/dtos/photo_service_dto.dart';
import 'package:dio/dio.dart';

import '../../../_core/constants/api_config.dart';
import '../photo_service/photo_service.dart';
import '../photo_service/price_option.dart';

abstract class PhotoServiceRepository {
  Future<List<PhotoService>> getServices();
  Future<List<PhotoService>> getServicesByPhotographer(int photographerId);
  Future<void> updateLikeStatus(int serviceId, bool isLiked);
}

class PhotoServiceRepositoryImpl implements PhotoServiceRepository {
  final Dio _dio = Dio();

  String get serverUrl {
    if (Platform.isAndroid) {
      return ApiConfig.baseUrl;
    } else if (Platform.isIOS) {
      return ApiConfig.baseUrl;
    } else {
      return ApiConfig.baseUrl;
    }
  }

  @override
  Future<List<PhotoService>> getServices() async {
    final String apiUrl = '$serverUrl/api/photo/services/list'; // 실제 API 엔드포인트
    try {
      final response = await _dio.get(apiUrl);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = response.data;
        // 서버 응답 구조에 'body' 키가 있고, 그 값이 리스트인지 확인
        if (responseData.containsKey('body') && responseData['body'] is List) {
          final List<dynamic> serviceListFromResponse =
              responseData['body'] as List<dynamic>;
          final List<PhotoService> services = serviceListFromResponse
              .map((item) {
                // 각 아이템이 Map 형태인지 확인 후 DTO로 변환
                if (item is Map<String, dynamic>) {
                  final dto = PhotoServiceDto.fromJson(item);
                  return dto
                      .toModel(); // PhotoServiceDto에 toModel() 메서드가 있다고 가정
                } else {
                  // 예외 처리 또는 로그: 리스트 내 아이템 형식이 올바르지 않음
                  print('Invalid item format in service list: $item');
                  return null; // 또는 예외를 던짐
                }
              })
              .where((service) => service != null) // null이 아닌 객체만 필터링
              .cast<PhotoService>() // 타입 캐스팅
              .toList();
          return services;
        } else {
          print(
              'Error: Response "body" is not a list or "body" key is missing. URL: $apiUrl, Response: $responseData');
          return [];
        }
      } else {
        print('Error fetching services: ${response.statusCode}, URL: $apiUrl');
        return [];
      }
    } on DioException catch (e) {
      print('DioError fetching services: ${e.message}, URL: $apiUrl');
      return [];
    } catch (e) {
      print('Unexpected error fetching services: $e, URL: $apiUrl');
      return [];
    }
  }

  @override
  Future<List<PhotoService>> getServicesByPhotographer(
      int photographerId) async {
    // TODO: 실제 API 엔드포인트로 교체 (예: /api/photo/services/photographer/{photographerId} 또는 /api/photo/services?photographerId={photographerId})
    final String apiUrl =
        '$serverUrl/api/photo/services/photographer/$photographerId';
    try {
      final response = await _dio.get(apiUrl);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = response.data;
        if (responseData.containsKey('body') && responseData['body'] is List) {
          final List<dynamic> serviceListFromResponse =
              responseData['body'] as List<dynamic>;
          final List<PhotoService> services = serviceListFromResponse
              .map((item) {
                if (item is Map<String, dynamic>) {
                  final dto = PhotoServiceDto.fromJson(item);
                  return dto.toModel();
                } else {
                  print(
                      'Invalid item format in photographer service list: $item');
                  return null;
                }
              })
              .where((service) => service != null)
              .cast<PhotoService>()
              .toList();
          return services;
        } else {
          print(
              'Error: Response "body" is not a list or "body" key is missing for photographer services. URL: $apiUrl, Response: $responseData');
          return [];
        }
      } else {
        print(
            'Error fetching services by photographer: ${response.statusCode}, URL: $apiUrl');
        return [];
      }
    } on DioException catch (e) {
      print(
          'DioError fetching services by photographer: ${e.message}, URL: $apiUrl');
      return [];
    } catch (e) {
      print(
          'Unexpected error fetching services by photographer: $e, URL: $apiUrl');
      return [];
    }
  }

  Future<List<PhotoService>> _getMockData() async {
    // TODO: 실제 API 호출로 교체
    await Future.delayed(const Duration(milliseconds: 500));

    final mockData = [
      PhotoService(
        id: 1,
        photographerId: 1,
        title: '추억이 될 오늘을 스냅으로 담아드려요요요요요요요요요요요요요요',
        imageUrl: AppImages.onboarding,
        categories: [
          AppStrings.categoryWedding,
          AppStrings.categoryCouple,
          AppStrings.categoryEvent,
        ],
        price: 100000,
        rating: 5.0,
        reviewCount: 4,
        isLiked: true,
        description:
            '소중한 순간을 아름답게 담아드립니다. 자연스럽고 감성적인 스냅 촬영으로 평생 간직할 추억을 만들어보세요. 전문적인 촬영 기술과 섬세한 편집으로 최고의 결과물을 제공합니다.',
        priceOptions: [
          PriceOption(
            name: '에센셜',
            price: 100000,
            duration: '1시간',
            photoCount: '20장',
            editingLevel: '기본 보정',
            features: ['스튜디오 촬영', '기본 의상 제공', '48시간 내 전달'],
          ),
          PriceOption(
            name: '프리미엄',
            price: 150000,
            duration: '2시간',
            photoCount: '50장',
            editingLevel: '고급 보정',
            features: ['실외 + 스튜디오', '의상 컨설팅', '소품 제공', '24시간 내 전달'],
          ),
          PriceOption(
            name: '시그니처',
            price: 250000,
            duration: '3시간',
            photoCount: '100장',
            editingLevel: '프리미엄 보정',
            features: ['장소 제한 없음', '프리미엄 의상', '전문 메이크업', '당일 전달', '인화본 제공'],
          ),
        ],
        portfolioImages: [
          'https://images.unsplash.com/photo-1511285560929-80b456fea0bc?w=400',
          'https://images.unsplash.com/photo-1519741497674-611481863552?w=400',
          'https://images.unsplash.com/photo-1469371670807-013ccf25f16a?w=400',
          'https://images.unsplash.com/photo-1606216794074-735e91aa2c92?w=400',
        ],
      ),
      PhotoService(
        id: 2,
        photographerId: 1,
        title: '추억이 될 오늘을 스냅으로 담아드려요',
        imageUrl: AppImages.onboarding2,
        categories: [
          AppStrings.categoryWedding,
          AppStrings.categoryCouple,
          AppStrings.categoryEvent,
        ],
        price: 100000,
        rating: 5.0,
        reviewCount: 4,
        isLiked: false,
        description:
            '커플, 웨딩, 이벤트 등 특별한 순간을 전문적으로 촬영합니다. 자연스러운 포즈와 아름다운 구도로 감동적인 사진을 완성해드립니다.',
        priceOptions: [
          PriceOption(
            name: '에센셜',
            price: 100000,
            duration: '1시간',
            photoCount: '25장',
            editingLevel: '기본 보정',
            features: ['야외 촬영', '기본 소품 제공', '72시간 내 전달'],
          ),
          PriceOption(
            name: '프리미엄',
            price: 160000,
            duration: '2.5시간',
            photoCount: '60장',
            editingLevel: '고급 보정',
            features: ['다양한 장소', '의상 체인지', '당일 스냅 제공', '48시간 내 전달'],
          ),
        ],
        portfolioImages: [
          'https://images.unsplash.com/photo-1583939003579-730e3918a45a?w=400',
          'https://images.unsplash.com/photo-1606216794074-735e91aa2c92?w=400',
          'https://images.unsplash.com/photo-1594736797933-d0c8b2e90d85?w=400',
        ],
      ),
      PhotoService(
        id: 3,
        photographerId: 2,
        title: '공간, 인테리어, 숙소 촬영 해드립니다',
        imageUrl:
            'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=400',
        categories: ['인테리어', '공간촬영'],
        price: 130000,
        rating: 4.8,
        reviewCount: 3,
        isLiked: false,
        description:
            '공간의 아름다움을 최대한 살려 촬영합니다. 인테리어, 카페, 숙소 등 다양한 공간을 전문적으로 촬영하여 매력적인 이미지를 제작해드립니다.',
        priceOptions: [
          PriceOption(
            name: '베이직',
            price: 130000,
            duration: '2시간',
            photoCount: '30장',
            editingLevel: '전문 보정',
            features: ['공간 전체 촬영', '각도별 다양한 컷', '조명 세팅', '2일 내 전달'],
          ),
          PriceOption(
            name: '프리미엄',
            price: 200000,
            duration: '3시간',
            photoCount: '50장',
            editingLevel: '고급 보정',
            features: ['디테일 촬영', '분위기별 조명', '스타일링 조언', '당일 전달'],
          ),
        ],
        portfolioImages: [
          'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=400',
          'https://images.unsplash.com/photo-1618221195710-dd6b41faaea6?w=400',
          'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=400',
        ],
      ),
      PhotoService(
        id: 4,
        photographerId: 2,
        title: '반려동물 홈스냅, 야외스냅 촬영 해드립니다',
        imageUrl:
            'https://images.unsplash.com/photo-1425082661705-1834bfd09dca?w=400',
        categories: ['반려동물', '야외촬영'],
        price: 120000,
        rating: 5.0,
        reviewCount: 1,
        isLiked: true,
        description:
            '소중한 반려동물과의 특별한 순간을 담아드립니다. 반려동물의 성격과 특성을 고려한 촬영으로 자연스럽고 사랑스러운 모습을 연출합니다.',
        priceOptions: [
          PriceOption(
            name: '홈스냅',
            price: 120000,
            duration: '1.5시간',
            photoCount: '40장',
            editingLevel: '펫 전용 보정',
            features: ['집에서 편안한 촬영', '반려동물 간식 제공', '다양한 포즈', '3일 내 전달'],
          ),
          PriceOption(
            name: '야외스냅',
            price: 150000,
            duration: '2시간',
            photoCount: '60장',
            editingLevel: '자연광 보정',
            features: ['공원/해변 촬영', '자연스러운 액션샷', '계절감 연출', '2일 내 전달'],
          ),
        ],
        portfolioImages: [
          'https://images.unsplash.com/photo-1425082661705-1834bfd09dca?w=400',
          'https://images.unsplash.com/photo-1583337130417-3346a1be7dee?w=400',
          'https://images.unsplash.com/photo-1601758228041-f3b2795255f1?w=400',
        ],
      ),
      PhotoService(
        id: 5,
        photographerId: 3,
        title: '공연/연주 촬영, 행사 촬영 해드립니다',
        imageUrl:
            'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=400',
        categories: ['공연', '행사'],
        price: 120000,
        rating: 4.8,
        reviewCount: 15,
        isLiked: false,
        description:
            '공연과 행사의 생생한 순간을 포착합니다. 무대의 역동성과 감동을 그대로 담아 기억에 남는 사진을 제작해드립니다. 다양한 조명 환경에 대한 전문 지식을 바탕으로 최상의 결과물을 보장합니다.',
        priceOptions: [
          PriceOption(
            name: '기본 촬영',
            price: 120000,
            duration: '2시간',
            photoCount: '80장',
            editingLevel: '무대 전용 보정',
            features: ['공연 전체 촬영', '하이라이트 순간 포착', '무대 조명 활용', '3일 내 전달'],
          ),
          PriceOption(
            name: '프리미엄',
            price: 180000,
            duration: '3시간',
            photoCount: '120장',
            editingLevel: '프로페셔널 보정',
            features: ['다각도 촬영', '백스테이지 포함', '개별 아티스트 촬영', '당일 하이라이트 제공'],
          ),
          PriceOption(
            name: '풀패키지',
            price: 280000,
            duration: '전체 행사',
            photoCount: '200장+',
            editingLevel: '마스터 보정',
            features: ['행사 전체 기록', '실시간 편집', '당일 SNS용 사진', '앨범 제작', '영상 하이라이트'],
          ),
        ],
        portfolioImages: [
          'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=400',
          'https://images.unsplash.com/photo-1516450360452-9312f5e86fc7?w=400',
          'https://images.unsplash.com/photo-1429962714451-bb934ecdc4ec?w=400',
          'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400',
        ],
      ),
    ];

    return mockData;
  }

  @override
  Future<void> updateLikeStatus(int serviceId, bool isLiked) async {
    // TODO: 실제 API 호출로 교체
    print('서비스 좋아요 상태 업데이트: $serviceId, $isLiked');
  }
}
