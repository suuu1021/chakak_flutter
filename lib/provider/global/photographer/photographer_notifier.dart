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

      // 시연용 더미 데이터
      await Future.delayed(const Duration(milliseconds: 500));

      final mockPhotographers = [
        Photographer(
          id: 1,
          businessName: '스냅스튜디오',
          imageUrl:
              'https://images.unsplash.com/photo-1519741497674-611481863552?w=400&h=300&fit=crop',
          categories: ['웨딩', '프로필', '가족사진'],
          rating: 4.8,
          reviewCount: 124,
          isLiked: false,
        ),
        Photographer(
          id: 2,
          businessName: '모멘트 포토',
          imageUrl:
              'https://images.unsplash.com/photo-1516589178581-6cd7833ae3b2?w=400&h=300&fit=crop',
          categories: ['스냅', '커플'],
          rating: 4.7,
          reviewCount: 89,
          isLiked: true,
        ),
        Photographer(
          id: 3,
          businessName: '아트필름',
          imageUrl:
              'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?w=400&h=300&fit=crop',
          categories: ['프로필', '상업촬영'],
          rating: 4.9,
          reviewCount: 156,
          isLiked: false,
        ),
        Photographer(
          id: 4,
          businessName: '클래식 포토',
          imageUrl:
              'https://images.unsplash.com/photo-1463453091185-61582044d556?w=400&h=300&fit=crop&crop=face',
          categories: ['웨딩', '클래식'],
          rating: 4.6,
          reviewCount: 98,
          isLiked: false,
        ),
        Photographer(
          id: 5,
          businessName: '라이프 스튜디오',
          imageUrl:
              'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=400&h=300&fit=crop&crop=face',
          categories: ['가족사진', '돌잔치'],
          rating: 4.8,
          reviewCount: 76,
          isLiked: true,
        ),
        Photographer(
          id: 6,
          businessName: '프리즘 포토',
          imageUrl:
              'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400&h=300&fit=crop&crop=face',
          categories: ['컨셉촬영', '프로필'],
          rating: 4.5,
          reviewCount: 67,
          isLiked: false,
        ),
        Photographer(
          id: 7,
          businessName: '내츄럴 스냅',
          imageUrl:
              'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400&h=300&fit=crop&crop=face',
          categories: ['자연스냅', '가족사진'],
          rating: 4.9,
          reviewCount: 143,
          isLiked: false,
        ),
      ];

      state =
          state.copyWith(photographers: mockPhotographers, isLoading: false);

      // 원래 API 호출 코드 (시연 후 되돌릴 때 사용)
      // final photographers = await _apiService.getPhotographers();
      // state = state.copyWith(photographers: photographers, isLoading: false);
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
