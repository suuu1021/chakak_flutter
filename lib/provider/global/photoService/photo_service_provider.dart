import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/photo_service/photo_service.dart';
import '../../../data/models/repositories/photo_service_repository.dart';

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
} // end of ServiceState

// 창고 메뉴얼 (확장된 VM 개념)
class ServiceNotifier extends Notifier<ServiceState> {
  late PhotoServiceRepository _repository;

  PhotoServiceRepository get repository => _repository;

  @override
  ServiceState build() {
    _repository = PhotoServiceRepositoryImpl();

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

  // 포토그래퍼별 서비스 로드 메서드 추가
  Future<void> loadServicesByPhotographer(int photographerId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final services =
          await _repository.getServicesByPhotographer(photographerId);

      // 캐시에 저장
      final updatedCache =
          Map<int, List<PhotoService>>.from(state.photographerServices);
      updatedCache[photographerId] = services;

      state = state.copyWith(
        photographerServices: updatedCache,
        isLoading: false,
      );
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

  // 에러 초기화
  void clearError() {
    state = state.copyWith(error: null);
  }
}

// 실제 창고 개설
final photoServiceProvider = NotifierProvider<ServiceNotifier, ServiceState>(
  () => ServiceNotifier(),
);
