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
      // 원래 API 호출 코드 (시연 후 되돌릴 때 사용)
      final categories = await _apiService.getCategories();
      state = state.copyWith(categories: categories, isLoading: false);
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
