import 'package:chakak_flutter/provider/global/photoService/photo_service_api_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/photo_service/photo_service.dart';
import '../../../data/models/repositories/photo_service_repository.dart';

final photoServiceRepositoryProvider = Provider<PhotoServiceRepository>((ref) {
  return PhotoServiceRepositoryImpl();
});

// API Service Provider
final photoServiceApiServiceProvider = Provider<PhotoServiceApiService>((ref) {
  final repository = ref.read(photoServiceRepositoryProvider);
  return PhotoServiceApiService(repository);
});

// State 클래스
class ServiceState {
  final List<PhotoService> services;
  final Map<int, List<PhotoService>> photographerServices; // 포토그래퍼별 서비스 캐시
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

// Notifier 클래스
class ServiceNotifier extends StateNotifier<ServiceState> {
  final PhotoServiceApiService _apiService;

  ServiceNotifier(this._apiService) : super(ServiceState());

  Future<void> loadServices() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      // 시연용 Mock 데이터
      await Future.delayed(const Duration(milliseconds: 500)); // 로딩 시뮬레이션

      final mockServices = [
        PhotoService(
          id: 1,
          photographerId: 1,
          title: '웨딩 스냅 촬영',
          imageUrl:
              'https://images.unsplash.com/photo-1519741497674-611481863552?w=800&h=600&fit=crop&crop=center',
          categories: ['웨딩'],
          price: 500000,
          rating: 4.8,
          reviewCount: 24,
          isLiked: false,
          description: '특별한 날의 소중한 순간을 아름답게 담아드립니다. 자연스럽고 감성적인 웨딩 촬영을 진행합니다.',
          priceOptions: [],
          portfolioImages: [
            'https://images.unsplash.com/photo-1511285560929-80b456fea0bc?w=400&h=300&fit=crop',
            'https://images.unsplash.com/photo-1606800052052-a08af7148866?w=400&h=300&fit=crop',
            'https://images.unsplash.com/photo-1594736797933-d0501ba2fe65?w=400&h=300&fit=crop',
          ],
        ),
        PhotoService(
          id: 2,
          photographerId: 1,
          title: '가족사진 촬영',
          imageUrl:
              'https://images.unsplash.com/photo-1511895426328-dc8714191300?w=800&h=600&fit=crop&crop=center',
          categories: ['가족사진'],
          price: 300000,
          rating: 4.7,
          reviewCount: 18,
          isLiked: false,
          description: '가족의 행복한 모습을 자연스럽게 포착합니다. 따뜻하고 편안한 분위기에서 촬영합니다.',
          priceOptions: [],
          portfolioImages: [
            'https://images.unsplash.com/photo-1609220136736-443140cffec6?w=400&h=300&fit=crop',
            'https://images.unsplash.com/photo-1581833971358-2c8b550f87b3?w=400&h=300&fit=crop',
            'https://images.unsplash.com/photo-1576091160550-2173dba999ef?w=400&h=300&fit=crop',
          ],
        ),
        PhotoService(
          id: 3,
          photographerId: 1,
          title: '프로필 촬영',
          imageUrl:
              'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=800&h=600&fit=crop&crop=face',
          categories: ['프로필'],
          price: 200000,
          rating: 4.9,
          reviewCount: 35,
          isLiked: true,
          description: '전문적이고 매력적인 프로필 사진을 촬영해드립니다. 개인의 특성을 살린 포트레이트.',
          priceOptions: [],
          portfolioImages: [
            'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=400&h=300&fit=crop&crop=face',
            'https://images.unsplash.com/photo-1494790108755-2616b612b093?w=400&h=300&fit=crop&crop=face',
            'https://images.unsplash.com/photo-1463453091185-61582044d556?w=400&h=300&fit=crop&crop=face',
          ],
        ),
        PhotoService(
          id: 4,
          photographerId: 1,
          title: '커플 스냅',
          imageUrl:
              'https://images.unsplash.com/photo-1516589178581-6cd7833ae3b2?w=800&h=600&fit=crop&crop=center',
          categories: ['커플'],
          price: 250000,
          rating: 4.6,
          reviewCount: 12,
          isLiked: false,
          description: '연인의 달콤한 순간을 기록합니다. 로맨틱하고 자연스러운 커플 촬영.',
          priceOptions: [],
          portfolioImages: [
            'https://images.unsplash.com/photo-1502164980785-f8aa41d53611?w=400&h=300&fit=crop',
            'https://images.unsplash.com/photo-1524250502761-1ac6f2e30d43?w=400&h=300&fit=crop',
            'https://images.unsplash.com/photo-1522098543979-ffc74a901cee?w=400&h=300&fit=crop',
          ],
        ),
        PhotoService(
          id: 5,
          photographerId: 1,
          title: '졸업사진 촬영',
          imageUrl:
              'https://images.unsplash.com/photo-1541339907198-e08756dedf3f?w=400&h=300&fit=crop',
          categories: ['졸업사진'],
          price: 150000,
          rating: 4.5,
          reviewCount: 8,
          isLiked: false,
          description: '인생의 중요한 순간을 기념하는 졸업사진을 촬영합니다.',
          priceOptions: [],
          portfolioImages: [
            'https://images.unsplash.com/photo-1541339907198-e08756dedf3f?w=400&h=300&fit=crop',
            'https://images.unsplash.com/photo-1544717297-fa95b6ee9643?w=400&h=300&fit=crop',
            'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400&h=300&fit=crop',
          ],
        ),
        PhotoService(
          id: 6,
          photographerId: 1,
          title: '돌잔치 촬영',
          imageUrl:
              'https://images.unsplash.com/photo-1515488764276-beab7607c1e6?w=800&h=600&fit=crop&crop=center',
          categories: ['돌잔치'],
          price: 400000,
          rating: 4.8,
          reviewCount: 15,
          isLiked: true,
          description: '아이의 첫 번째 생일을 특별하게 기록해드립니다.',
          priceOptions: [],
          portfolioImages: [
            'https://images.unsplash.com/photo-1544807978-54e2de0c8d41?w=400&h=300&fit=crop',
            'https://images.unsplash.com/photo-1587835124815-b8b69618ed5b?w=400&h=300&fit=crop',
            'https://images.unsplash.com/photo-1555252333-9f8e92e65df9?w=400&h=300&fit=crop',
          ],
        ),
      ];

      state = state.copyWith(services: mockServices, isLoading: false);

      // 원래 API 호출 코드 (시연 후 되돌릴 때 사용)
      // final services = await _apiService.getServices();
      // state = state.copyWith(services: services, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // 포토그래퍼별 서비스 로드 메서드 추가
  Future<void> loadServicesByPhotographer(int photographerId) async {
    try {
      // 시연용: 바로 전체 서비스를 해당 포토그래퍼의 서비스로 할당
      final services = state.services;

      // 캐시에 저장
      final updatedCache =
          Map<int, List<PhotoService>>.from(state.photographerServices);
      updatedCache[photographerId] = services;

      state = state.copyWith(
        photographerServices: updatedCache,
        isLoading: false,
      );

      // 원래 API 호출 코드 (시연 후 되돌릴 때 사용)
      // final services = await _apiService.getServicesByPhotographer(photographerId);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // 포토그래퍼의 서비스 목록 가져오기 (캐시된 데이터 반환)
  List<PhotoService> getPhotographerServices(int photographerId) {
    return state.photographerServices[photographerId] ?? [];
  }

  Future<void> toggleLike(int serviceId) async {
    try {
      // 전체 서비스 목록에서 업데이트
      final services = state.services.map((service) {
        if (service.id == serviceId) {
          final newLikeStatus = !service.isLiked;
          _apiService.updateLikeStatus(serviceId, newLikeStatus);
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
            return service.copyWith(isLiked: !service.isLiked);
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
    }
  }
}

// Provider
final photoServiceNotifierProvider =
    StateNotifierProvider<ServiceNotifier, ServiceState>((ref) {
  final apiService = ref.read(photoServiceApiServiceProvider);
  return ServiceNotifier(apiService);
});
