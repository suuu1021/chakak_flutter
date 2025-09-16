import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/photo_service_category.dart';
import '../../../data/models/repositories/photo_service_category_repository.dart';
import 'photo_service_category_api_service.dart';

// Repository Provider
final photoServiceCategoryRepositoryProvider =
    Provider<PhotoServiceCategoryRepository>((ref) {
  return PhotoServiceCategoryRepositoryImpl();
});

// API Service Provider
final photoServiceCategoryApiServiceProvider =
    Provider<PhotoServiceCategoryApiService>((ref) {
  final repository = ref.read(photoServiceCategoryRepositoryProvider);
  return PhotoServiceCategoryApiService(repository);
});

// State 클래스
class PhotoServiceCategoryState {
  final List<PhotoServiceCategory> categories;
  final bool isLoading;
  final String? error;

  PhotoServiceCategoryState({
    this.categories = const [],
    this.isLoading = false,
    this.error,
  });

  PhotoServiceCategoryState copyWith({
    List<PhotoServiceCategory>? categories,
    bool? isLoading,
    String? error,
  }) {
    return PhotoServiceCategoryState(
      categories: categories ?? this.categories,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Notifier 클래스
class PhotoServiceCategoryNotifier
    extends StateNotifier<PhotoServiceCategoryState> {
  final PhotoServiceCategoryApiService _apiService;

  PhotoServiceCategoryNotifier(this._apiService)
      : super(PhotoServiceCategoryState());

  Future<void> loadCategories() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      // 시연용 더미 데이터
      await Future.delayed(const Duration(milliseconds: 300));

      final mockCategories = [
        PhotoServiceCategory(
          id: '1',
          name: '웨딩',
          categoryImageData:
              'https://images.unsplash.com/photo-1519741497674-611481863552?w=300&h=300&fit=crop',
        ),
        PhotoServiceCategory(
          id: '2',
          name: '가족사진',
          categoryImageData:
              'https://images.unsplash.com/photo-1511895426328-dc8714191300?w=300&h=300&fit=crop',
        ),
        PhotoServiceCategory(
          id: '3',
          name: '프로필',
          categoryImageData:
              'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=300&h=300&fit=crop&crop=face',
        ),
        PhotoServiceCategory(
          id: '4',
          name: '커플',
          categoryImageData:
              'https://images.unsplash.com/photo-1516589178581-6cd7833ae3b2?w=300&h=300&fit=crop',
        ),
        PhotoServiceCategory(
          id: '5',
          name: '졸업사진',
          categoryImageData:
              'https://images.unsplash.com/photo-1541339907198-e08756dedf3f?w=300&h=300&fit=crop',
        ),
        PhotoServiceCategory(
          id: '6',
          name: '돌잔치',
          categoryImageData:
              'https://images.unsplash.com/photo-1515488764276-beab7607c1e6?w=300&h=300&fit=crop',
        ),
      ];

      state = state.copyWith(categories: mockCategories, isLoading: false);

      // 원래 API 호출 코드 (시연 후 되돌릴 때 사용)
      // final categories = await _apiService.getCategories();
      // state = state.copyWith(categories: categories, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

// Provider
final photoServiceCategoryNotifierProvider = StateNotifierProvider<
    PhotoServiceCategoryNotifier, PhotoServiceCategoryState>((ref) {
  final apiService = ref.read(photoServiceCategoryApiServiceProvider);
  return PhotoServiceCategoryNotifier(apiService);
});
