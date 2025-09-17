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
        // 웨딩 스냅 촬영 (3개)
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
            'https://images.pexels.com/photos/2253870/pexels-photo-2253870.jpeg?w=400&h=300&fit=crop',
          ],
        ),
        PhotoService(
          id: 7,
          photographerId: 2,
          title: '로맨틱 웨딩 포토',
          imageUrl:
              'https://images.unsplash.com/photo-1583939003579-730e3918a45a?w=400&h=300&fit=crop',
          categories: ['웨딩'],
          price: 650000,
          rating: 4.9,
          reviewCount: 32,
          isLiked: true,
          description: '드라마틱하고 로맨틱한 웨딩 사진으로 평생의 추억을 만들어드립니다.',
          priceOptions: [],
          portfolioImages: [
            'https://images.unsplash.com/photo-1583939003579-730e3918a45a?w=400&h=300&fit=crop',
            'https://images.unsplash.com/photo-1537633552985-df8429e8048b?w=400&h=300&fit=crop',
            'https://images.unsplash.com/photo-1606216794074-735e91aa2c92?w=400&h=300&fit=crop',
          ],
        ),
        PhotoService(
          id: 8,
          photographerId: 3,
          title: '야외 웨딩 촬영',
          imageUrl:
              'https://images.unsplash.com/photo-1520854221256-17451cc331bf?w=800&h=600&fit=crop&crop=center',
          categories: ['웨딩'],
          price: 750000,
          rating: 4.7,
          reviewCount: 18,
          isLiked: false,
          description: '자연의 아름다움과 함께하는 야외 웨딩 촬영. 청춘과 사랑이 가득한 순간을 담습니다.',
          priceOptions: [],
          portfolioImages: [
            'https://images.unsplash.com/photo-1549417229-aa67d3263c09?w=400&h=300&fit=crop',
            'https://images.unsplash.com/photo-1591604129939-f1efa4d9f7fa?w=400&h=300&fit=crop',
            'https://images.unsplash.com/photo-1600298881974-6be191ceeda1?w=400&h=300&fit=crop',
          ],
        ),

        // 가족사진 (3개)
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
            'https://images.pexels.com/photos/160994/family-outdoor-happy-happiness-160994.jpeg?w=400&h=300&fit=crop',
            'https://images.pexels.com/photos/4259140/pexels-photo-4259140.jpeg?w=400&h=300&fit=crop',
          ],
        ),
        PhotoService(
          id: 9,
          photographerId: 2,
          title: '3대 가족 촬영',
          imageUrl:
              'https://images.pexels.com/photos/1835927/pexels-photo-1835927.jpeg?w=400&h=300&fit=crop',
          categories: ['가족사진'],
          price: 350000,
          rating: 4.8,
          reviewCount: 22,
          isLiked: true,
          description: '할머니, 할아버지부터 손자까지 3대가 함께하는 소중한 순간을 기록합니다.',
          priceOptions: [],
          portfolioImages: [
            'https://images.pexels.com/photos/1128318/pexels-photo-1128318.jpeg?w=400&h=300&fit=crop',
            'http://images.pexels.com/photos/302083/pexels-photo-302083.jpeg?w=400&h=300&fit=crop',
            'https://images.pexels.com/photos/2253879/pexels-photo-2253879.jpeg?w=400&h=300&fit=crop',
          ],
        ),
        PhotoService(
          id: 10,
          photographerId: 3,
          title: '신생아 가족 촬영',
          imageUrl:
              'https://images.pexels.com/photos/2133/man-person-cute-young.jpg?w=400&h=300&fit=crop',
          categories: ['가족사진'],
          price: 380000,
          rating: 4.9,
          reviewCount: 26,
          isLiked: false,
          description: '새 생명과 함께하는 가족의 첫 번째 사진. 부드럽고 따뜻한 감성으로 촬영합니다.',
          priceOptions: [],
          portfolioImages: [
            'http://images.pexels.com/photos/15961876/pexels-photo-15961876.jpeg?w=400&h=300&fit=crop',
            'https://images.pexels.com/photos/15961905/pexels-photo-15961905.jpeg?w=400&h=300&fit=crop',
            'https://images.pexels.com/photos/13422753/pexels-photo-13422753.jpeg?w=400&h=300&fit=crop',
          ],
        ),

        // 프로필 촬영 (3개)
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
          id: 11,
          photographerId: 2,
          title: '비즈니스 프로필',
          imageUrl:
              'https://images.unsplash.com/photo-1560250097-0b93528c311a?w=800&h=600&fit=crop&crop=face',
          categories: ['프로필'],
          price: 250000,
          rating: 4.8,
          reviewCount: 28,
          isLiked: false,
          description: '전문성과 신뢰감이 느껴지는 비즈니스 프로필 사진. LinkedIn, 명함용으로 완벽합니다.',
          priceOptions: [],
          portfolioImages: [
            'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=400&h=300&fit=crop&crop=face',
            'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=400&h=300&fit=crop&crop=face',
            'https://images.unsplash.com/photo-1556157382-97eda2d62296?w=400&h=300&fit=crop&crop=face',
          ],
        ),
        PhotoService(
          id: 12,
          photographerId: 3,
          title: '아티스트 프로필',
          imageUrl:
              'https://images.unsplash.com/photo-1531746020798-e6953c6e8e04?w=800&h=600&fit=crop&crop=face',
          categories: ['프로필'],
          price: 280000,
          rating: 4.7,
          reviewCount: 19,
          isLiked: true,
          description: '창작자, 아티스트를 위한 개성있고 독창적인 프로필 촬영. 당신만의 스타일을 표현합니다.',
          priceOptions: [],
          portfolioImages: [
            'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=400&h=300&fit=crop&crop=face',
            'https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e?w=400&h=300&fit=crop&crop=face',
            'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=400&h=300&fit=crop&crop=face',
          ],
        ),

        // 커플 스냅 (3개)
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
          id: 13,
          photographerId: 2,
          title: '야외 커플 촬영',
          imageUrl:
              'https://images.pexels.com/photos/792726/pexels-photo-792726.jpeg?w=400&h=300&fit=crop',
          categories: ['커플'],
          price: 280000,
          rating: 4.8,
          reviewCount: 21,
          isLiked: true,
          description: '자연 속에서의 커플 스냅. 계절의 아름다움과 함께 사랑을 표현합니다.',
          priceOptions: [],
          portfolioImages: [
            'https://images.pexels.com/photos/6213815/pexels-photo-6213815.jpeg?w=400&h=300&fit=crop',
            'https://images.pexels.com/photos/10315695/pexels-photo-10315695.jpeg?w=400&h=300&fit=crop',
            'https://images.pexels.com/photos/935824/pexels-photo-935824.jpeg?w=400&h=300&fit=crop',
          ],
        ),
        PhotoService(
          id: 14,
          photographerId: 3,
          title: '스튜디오 커플 촬영',
          imageUrl:
              'https://images.unsplash.com/photo-1576020799627-aeac74d58064?w=800&h=600&fit=crop&crop=center',
          categories: ['커플'],
          price: 320000,
          rating: 4.7,
          reviewCount: 15,
          isLiked: false,
          description: '세련된 스튜디오에서 진행하는 커플 촬영. 깔끔하고 모던한 분위기를 연출합니다.',
          priceOptions: [],
          portfolioImages: [
            'https://images.unsplash.com/photo-1598300042247-d088f8ab3a91?w=400&h=300&fit=crop',
            'https://images.unsplash.com/photo-1586297135537-94bc9ba060aa?w=400&h=300&fit=crop',
            'https://images.unsplash.com/photo-1571173069043-c1fbaf1e8ce5?w=400&h=300&fit=crop',
          ],
        ),

        // 졸업사진 (3개)
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
          id: 15,
          photographerId: 2,
          title: '대학 졸업 기념촬영',
          imageUrl:
              'https://images.unsplash.com/photo-1557804506-669a67965ba0?w=800&h=600&fit=crop&crop=center',
          categories: ['졸업사진'],
          price: 180000,
          rating: 4.6,
          reviewCount: 14,
          isLiked: true,
          description: '대학 졸업의 감동을 담은 기념사진. 학사모와 가운을 입고 찍는 정식 졸업사진.',
          priceOptions: [],
          portfolioImages: [
            'https://images.unsplash.com/photo-1580894908361-967195033215?w=400&h=300&fit=crop',
            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&h=300&fit=crop',
            'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=400&h=300&fit=crop',
          ],
        ),
        PhotoService(
          id: 16,
          photographerId: 3,
          title: '고등학교 졸업사진',
          imageUrl:
              'https://images.unsplash.com/photo-1522202176988-66273c2fd55f?w=800&h=600&fit=crop&crop=center',
          categories: ['졸업사진'],
          price: 120000,
          rating: 4.4,
          reviewCount: 11,
          isLiked: false,
          description: '청춘의 마지막 순간을 기록하는 고등학교 졸업사진. 친구들과 함께하는 단체 촬영도 가능합니다.',
          priceOptions: [],
          portfolioImages: [
            'https://images.unsplash.com/photo-1523240795612-9a054b0db644?w=400&h=300&fit=crop',
            'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400&h=300&fit=crop',
            'https://images.unsplash.com/photo-1544717297-fa95b6ee9643?w=400&h=300&fit=crop',
          ],
        ),

        // 돌잔치 (3개)
        PhotoService(
          id: 6,
          photographerId: 1,
          title: '돌잔치 촬영',
          imageUrl:
              'https://images.pexels.com/photos/1648375/pexels-photo-1648375.jpeg?w=800&h=600&fit=crop',
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
        PhotoService(
          id: 17,
          photographerId: 2,
          title: '한복 돌잔치 촬영',
          imageUrl:
              'https://images.pexels.com/photos/161709/newborn-baby-feet-basket-161709.jpeg?w=400&h=300&fit=crop',
          categories: ['돌잔치'],
          price: 450000,
          rating: 4.9,
          reviewCount: 20,
          isLiked: false,
          description: '전통 한복을 입고 진행하는 돌잔치 촬영. 한국의 아름다운 전통과 함께 기념합니다.',
          priceOptions: [],
          portfolioImages: [
            'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=400&h=300&fit=crop',
            'https://images.unsplash.com/photo-1590736969955-71cc94901144?w=400&h=300&fit=crop',
            'https://images.unsplash.com/photo-1606579436440-de4d2f56cbcd?w=400&h=300&fit=crop',
          ],
        ),
        PhotoService(
          id: 18,
          photographerId: 3,
          title: '테마 돌잔치 촬영',
          imageUrl:
              'https://images.pexels.com/photos/421884/pexels-photo-421884.jpeg?w=400&h=300&fit=crop',
          categories: ['돌잔치'],
          price: 500000,
          rating: 4.7,
          reviewCount: 17,
          isLiked: true,
          description: '다양한 테마와 소품으로 꾸민 특별한 돌잔치 촬영. 아이만의 개성있는 컨셉으로 진행합니다.',
          priceOptions: [],
          portfolioImages: [
            'https://images.unsplash.com/photo-1580393948537-cd2a47bb7ef5?w=400&h=300&fit=crop',
            'https://images.unsplash.com/photo-1555252333-9f8e92e65df9?w=400&h=300&fit=crop',
            'https://images.unsplash.com/photo-1587835124815-b8b69618ed5b?w=400&h=300&fit=crop',
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
      // 시연용: 해당 포토그래퍼의 서비스만 필터링
      final services = state.services
          .where((service) => service.photographerId == photographerId)
          .toList();

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
