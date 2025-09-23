import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/photo_service/photo_service.dart';
import '../../../data/models/photo_service/price_option.dart';
import '../../../data/models/repositories/photo_service_category_repository.dart';
import '../../../data/models/repositories/photo_service_repository.dart';
import '../../core/dio_provider.dart';

class ServiceState {
  final List<PhotoService> services;
  final Map<int, List<PhotoService>> photographerServices;
  final bool isLoading;
  final String? error;

  ServiceState({
    this.services = const [],
    this.photographerServices = const {},
    this.isLoading = false,
    this.error,
  });

  ServiceState copyWith({
    List<PhotoService>? services,
    Map<int, List<PhotoService>>? photographerServices,
    bool? isLoading,
    String? error,
  }) {
    return ServiceState(
      services: services ?? this.services,
      photographerServices: photographerServices ?? this.photographerServices,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// 창고 메뉴얼 (확장된 VM 개념)
class ServiceNotifier extends Notifier<ServiceState> {
  late PhotoServiceRepository _repository;
  late PhotoServiceCategoryRepository _categoryRepository;
  late Dio _dio; // Dio 인스턴스 추가

  PhotoServiceRepository get repository => _repository;

  @override
  ServiceState build() {
    _dio = ref.watch(dioProvider); // dioProvider에서 공통 Dio 인스턴스 가져오기
    _repository = PhotoServiceRepositoryImpl(_dio); // Dio 인스턴스 주입
    _categoryRepository =
        PhotoServiceCategoryRepositoryImpl(_dio); // 카테고리 repository 추가
    return ServiceState();
  }

  Future<void> loadServices() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final services = await _repository.getServices();
      state = state.copyWith(services: services, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// 새로운 포토 서비스 생성
  Future<void> createService(Map<String, dynamic> serviceData) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      // 이미지 데이터 처리 (Base64 인코딩)
      String imageData = '';
      if (serviceData['newImages'] != null) {
        final List<File> newImages = serviceData['newImages'];
        imageData = await _encodeImagesToBase64(newImages);
      }

      // 가격 정보 구성
      List<Map<String, dynamic>> priceInfoList = [];
      if (serviceData['priceInfoList'] != null) {
        priceInfoList = serviceData['priceInfoList'];
      }

      // 백엔드 API 요청 데이터 구성
      final requestData = {
        'title': serviceData['title'],
        'description': serviceData['description'],
        'imageData': imageData,
        'priceInfoList': priceInfoList,
        'categoryIdList': serviceData['categoryIdList'] ?? [],
      };

      // API 호출 - POST /api/photo/services
      final response = await _dio.post(
        '/api/photo/services',
        data: requestData,
        options: Options(
          headers: {
            'Authorization': 'Bearer ${await _getAccessToken()}',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        // 서비스 목록 새로고침
        await loadServicesByPhotographer(serviceData['photographerId']);
      } else {
        throw Exception('서비스 생성 실패');
      }
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: error.toString(),
      );
      rethrow;
    }
  }

  /// 포토 서비스 수정
  Future<void> updateService(
      int serviceId, Map<String, dynamic> serviceData) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      // 이미지 데이터 처리
      String imageData = '';
      if (serviceData['existingImageData'] != null) {
        imageData = serviceData['existingImageData'];
      }
      if (serviceData['newImages'] != null) {
        final List<File> newImages = serviceData['newImages'];
        final newImageData = await _encodeImagesToBase64(newImages);
        imageData =
            imageData.isEmpty ? newImageData : '$imageData,$newImageData';
      }

      // 가격 정보 구성
      List<Map<String, dynamic>> priceInfoList = [];
      if (serviceData['priceInfoList'] != null) {
        priceInfoList = serviceData['priceInfoList'];
      }

      // 백엔드 API 요청 데이터 구성
      final requestData = {
        'title': serviceData['title'],
        'description': serviceData['description'],
        'imageData': imageData,
        'priceInfoList': priceInfoList,
        'categoryIdList': serviceData['categoryIdList'] ?? [],
      };

      // API 호출 - PATCH /api/photo/services/{id}
      final response = await _dio.patch(
        '/api/photo/services/$serviceId',
        data: requestData,
        options: Options(
          headers: {
            'Authorization': 'Bearer ${await _getAccessToken()}',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        // 서비스 목록 새로고침
        await loadServicesByPhotographer(serviceData['photographerId']);
      } else {
        throw Exception('서비스 수정 실패');
      }
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: error.toString(),
      );
      rethrow;
    }
  }

  /// 포토 서비스 삭제
  Future<void> deleteService(int serviceId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      // API 호출 - DELETE /api/photo/services/{id}
      final response = await _dio.delete(
        '/api/photo/services/$serviceId',
        options: Options(
          headers: {
            'Authorization': 'Bearer ${await _getAccessToken()}',
          },
        ),
      );

      if (response.statusCode == 200) {
        // 로컬 상태에서 서비스 제거
        final updatedServices =
            state.services.where((service) => service.id != serviceId).toList();

        // 포토그래퍼별 캐시에서도 제거
        final updatedCache =
            Map<int, List<PhotoService>>.from(state.photographerServices);
        for (final photographerId in updatedCache.keys) {
          updatedCache[photographerId] = updatedCache[photographerId]!
              .where((service) => service.id != serviceId)
              .toList();
        }

        state = state.copyWith(
          services: updatedServices,
          photographerServices: updatedCache,
          isLoading: false,
        );
      } else {
        throw Exception('서비스 삭제 실패');
      }
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: error.toString(),
      );
      rethrow;
    }
  }

  /// 특정 포토그래퍼의 서비스 목록 로드
  Future<void> loadServicesByPhotographer(int photographerId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final services =
          await _repository.getServicesByPhotographer(photographerId);

      // 포토그래퍼별 캐시에 저장
      final updatedCache =
          Map<int, List<PhotoService>>.from(state.photographerServices);
      updatedCache[photographerId] = services;

      // 전체 서비스 목록에서도 업데이트 (중복 제거)
      final Map<int, PhotoService> serviceMap = {
        for (var service in state.services) service.id: service
      };

      for (var service in services) {
        serviceMap[service.id] = service;
      }

      state = state.copyWith(
        services: serviceMap.values.toList(),
        photographerServices: updatedCache,
        isLoading: false,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: error.toString(),
      );
      rethrow;
    }
  }

  /// 특정 포토그래퍼의 서비스 목록 가져오기 (로컬 상태에서)
  List<PhotoService> getPhotographerServices(int photographerId) {
    return state.photographerServices[photographerId] ?? [];
  }

  /// 포토 서비스 목록 조회 (검색 포함)
  Future<void> loadServiceList(
      {int page = 0, int size = 10, String? keyword}) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final services = await _repository.getServices();

      if (page == 0) {
        // 첫 페이지인 경우 새로 설정
        state = state.copyWith(
          services: services,
          isLoading: false,
        );
      } else {
        // 추가 페이지인 경우 기존 목록에 추가
        final updatedServices = [...state.services, ...services];
        state = state.copyWith(
          services: updatedServices,
          isLoading: false,
        );
      }
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: error.toString(),
      );
      rethrow;
    }
  }

  /// 포토 서비스 상세 조회
  Future<PhotoService?> loadServiceDetail(int serviceId) async {
    try {
      // 먼저 로컬 상태에서 찾기
      PhotoService? service;
      try {
        service = state.services.firstWhere((s) => s.id == serviceId);
        return service;
      } catch (e) {
        // 로컬에 없으면 전체 목록 다시 로드
        await loadServices();
        try {
          service = state.services.firstWhere((s) => s.id == serviceId);
          return service;
        } catch (e) {
          return null;
        }
      }
    } catch (error) {
      rethrow;
    }
  }

  /// 카테고리 목록 조회
  Future<List<dynamic>> loadCategories() async {
    try {
      final categories = await _categoryRepository.getCategories();

      // PhotoServiceCategory를 Map<String, dynamic> 형태로 변환
      return categories
          .map((category) => {
                'categoryId': category.id,
                'categoryName': category.name,
                'categoryImageData': category.categoryImageData,
              })
          .toList();
    } catch (error) {
      print('카테고리 로딩 실패: $error');
      // API 실패 시 기본 카테고리 목록 반환
      return [
        {'categoryId': 1, 'categoryName': '웨딩', 'categoryImageData': ''},
        {'categoryId': 2, 'categoryName': '가족사진', 'categoryImageData': ''},
        {'categoryId': 3, 'categoryName': '프로필사진', 'categoryImageData': ''},
        {'categoryId': 4, 'categoryName': '스튜디오', 'categoryImageData': ''},
        {'categoryId': 5, 'categoryName': '야외촬영', 'categoryImageData': ''},
        {'categoryId': 6, 'categoryName': '상품촬영', 'categoryImageData': ''},
        {'categoryId': 7, 'categoryName': '행사촬영', 'categoryImageData': ''},
        {'categoryId': 8, 'categoryName': '기타', 'categoryImageData': ''},
      ];
    }
  }

  // 카테고리별 서비스 로드 메서드
  Future<void> loadServicesByCategory(String categoryId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final services =
          await _categoryRepository.getServicesByCategory(categoryId);

      state = state.copyWith(services: services, isLoading: false);
    } catch (e) {
      print('카테고리별 서비스 로딩 실패: $e');
      // 실패 시 전체 서비스 로드
      try {
        final allServices = await _repository.getServices();
        state = state.copyWith(services: allServices, isLoading: false);
      } catch (fallbackError) {
        state =
            state.copyWith(isLoading: false, error: fallbackError.toString());
      }
    }
  }

  Future<void> toggleLike(int serviceId) async {
    try {
      // 현재 좋아요 상태 찾기
      final currentService =
          state.services.firstWhere((service) => service.id == serviceId);
      final newLikeStatus = !currentService.isLiked;

      // API 호출
      await _repository.updateLikeStatus(serviceId, newLikeStatus);

      // 전체 서비스 목록에서 업데이트
      final services = state.services.map((service) {
        if (service.id == serviceId) {
          return service.copyWith(isLiked: newLikeStatus);
        }
        return service;
      }).toList();

      // 포토그래퍼별 캐시에서도 업데이트
      final updatedCache =
          Map<int, List<PhotoService>>.from(state.photographerServices);
      for (final photographerId in updatedCache.keys) {
        updatedCache[photographerId] =
            updatedCache[photographerId]!.map((service) {
          if (service.id == serviceId) {
            return service.copyWith(isLiked: newLikeStatus);
          }
          return service;
        }).toList();
      }

      state = state.copyWith(
        services: services,
        photographerServices: updatedCache,
      );
    } catch (e) {
      print('서비스 좋아요 상태 변경 실패: $e');
      // 에러 발생 시 상태 복원 로직 추가 가능
    }
  }

  /// 이미지를 Base64로 인코딩
  Future<String> _encodeImagesToBase64(List<File> images) async {
    try {
      List<String> base64Images = [];

      for (File image in images) {
        final bytes = await image.readAsBytes();
        final base64String = base64Encode(bytes);
        base64Images.add(base64String);
      }

      return base64Images.join(',');
    } catch (error) {
      throw Exception('이미지 인코딩 실패: $error');
    }
  }

  /// Access Token 가져오기
  Future<String> _getAccessToken() async {
    // SharedPreferences 또는 다른 저장소에서 토큰 가져오기
    // 실제 구현에서는 AuthProvider나 SessionProvider에서 가져와야 함
    // 예시: final session = ref.read(sessionProvider);
    // return session.accessToken;
    return 'your_access_token_here';
  }

  // 에러 초기화
  void clearError() {
    state = state.copyWith(error: null);
  }
}

@override
Future<List<PhotoService>> parseServicesFromJson(List<dynamic> jsonList) async {
  return jsonList
      .map((item) {
        if (item is Map<String, dynamic>) {
          List<PriceOption> priceOptionsList = [];
          if (item['priceInfoList'] != null) {
            priceOptionsList = (item['priceInfoList'] as List)
                .map((priceJson) =>
                    PriceOption.fromJson(priceJson as Map<String, dynamic>))
                .toList();
          }

          return PhotoService(
            id: item['serviceId'] as int? ?? 0,
            photographerId: item['photographerId'] as int? ?? 0,
            photographerUserId: item['photographerUserId'] as int? ?? 0,
            title: item['title'] as String? ?? '',
            imageUrl: item['imageData'] as String? ?? '',
            categories: [],
            price: item['price'] as int? ?? 0,
            rating: 0.0,
            reviewCount: 0,
            isLiked: false,
            description: item['description'] as String? ?? '',
            priceOptions: priceOptionsList,
            portfolioImages: [],
          );
        }
        return null;
      })
      .where((service) => service != null)
      .cast<PhotoService>()
      .toList();
}

// 실제 창고 개설
final photoServiceProvider = NotifierProvider<ServiceNotifier, ServiceState>(
  () => ServiceNotifier(),
);
