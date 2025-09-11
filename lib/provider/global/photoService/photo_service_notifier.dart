import 'package:chakak_flutter/provider/global/photoService/photo_service_api_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/photo_service.dart';
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
  final bool isLoading;
  final String? error;

  ServiceState({
    this.services = const [],
    this.isLoading = false,
    this.error,
  });

  ServiceState copyWith({
    List<PhotoService>? services,
    bool? isLoading,
    String? error,
  }) {
    return ServiceState(
      services: services ?? this.services,
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
      final services = await _apiService.getServices();
      state = state.copyWith(services: services, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> toggleLike(int serviceId) async {
    try {
      final services = state.services.map((service) {
        if (service.id == serviceId) {
          final newLikeStatus = !service.isLiked;
          _apiService.updateLikeStatus(serviceId, newLikeStatus);
          return service.copyWith(isLiked: newLikeStatus);
        }
        return service;
      }).toList();

      state = state.copyWith(services: services);
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
