// Repository Provider
import 'package:chakak_flutter/provider/global/photographer/photographer_api_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/photographer.dart';
import '../../../data/models/repositories/photographer_repository.dart';

final photographerRepositoryProvider = Provider<PhotographerRepository>((ref) {
  return PhotographerRepositoryImpl();
});

// API Service Provider
final photographerApiServiceProvider = Provider<PhotographerApiService>((ref) {
  final repository = ref.read(photographerRepositoryProvider);
  return PhotographerApiService(repository);
});

// State 클래스
class PhotographerState {
  final List<Photographer> photographers;
  final bool isLoading;
  final String? error;

  PhotographerState({
    this.photographers = const [],
    this.isLoading = false,
    this.error,
  });

  PhotographerState copyWith({
    List<Photographer>? photographers,
    bool? isLoading,
    String? error,
  }) {
    return PhotographerState(
      photographers: photographers ?? this.photographers,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Notifier 클래스
class PhotographerNotifier extends StateNotifier<PhotographerState> {
  final PhotographerApiService _apiService;

  PhotographerNotifier(this._apiService) : super(PhotographerState());

  Future<void> loadPhotographers() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final photographers = await _apiService.getPhotographers();
      state = state.copyWith(photographers: photographers, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> toggleLike(int photographerId) async {
    try {
      final photographers = state.photographers.map((photographer) {
        if (photographer.id == photographerId) {
          final newLikeStatus = !photographer.isLiked;
          _apiService.updateLikeStatus(photographerId, newLikeStatus);
          return photographer.copyWith(isLiked: newLikeStatus);
        }
        return photographer;
      }).toList();

      state = state.copyWith(photographers: photographers);
    } catch (e) {
      print('포토그래퍼 좋아요 상태 변경 실패: $e');
    }
  }
}

// Provider
final photographerNotifierProvider =
    StateNotifierProvider<PhotographerNotifier, PhotographerState>((ref) {
  final apiService = ref.read(photographerApiServiceProvider);
  return PhotographerNotifier(apiService);
});
