import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/photographer_category.dart';
import '../../../data/models/repositories/photographer_category_repository.dart';
import 'photographer_category_api_service.dart';

// Repository Provider
final photographerCategoryRepositoryProvider = Provider<PhotographerCategoryRepository>((ref) {
  return PhotographerCategoryRepositoryImpl();
});

// API Service Provider
final photographerCategoryApiServiceProvider = Provider<PhotographerCategoryApiService>((ref) {
  final repository = ref.read(photographerCategoryRepositoryProvider);
  return PhotographerCategoryApiService(repository);
});

// State 클래스
class PhotographerCategoryState {
  final List<PhotographerCategory> categories;
  final bool isLoading;
  final String? error;

  PhotographerCategoryState({
    this.categories = const [],
    this.isLoading = false,
    this.error,
  });

  PhotographerCategoryState copyWith({
    List<PhotographerCategory>? categories,
    bool? isLoading,
    String? error,
  }) {
    return PhotographerCategoryState(
      categories: categories ?? this.categories,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Notifier 클래스
class PhotographerCategoryNotifier extends StateNotifier<PhotographerCategoryState> {
  final PhotographerCategoryApiService _apiService;

  PhotographerCategoryNotifier(this._apiService) : super(PhotographerCategoryState());

  Future<void> loadCategories() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final categories = await _apiService.getCategories();
      state = state.copyWith(categories: categories, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

// Provider
final photographerCategoryNotifierProvider = StateNotifierProvider<PhotographerCategoryNotifier, PhotographerCategoryState>((ref) {
  final apiService = ref.read(photographerCategoryApiServiceProvider);
  return PhotographerCategoryNotifier(apiService);
});