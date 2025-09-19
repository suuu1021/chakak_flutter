// 창고 데이터
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/photographer_category.dart';
import '../../../data/models/repositories/photographer_category_repository.dart';

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
} // end of PhotographerCategoryState

// 창고 메뉴얼 (확장된 VM 개념)
class PhotographerCategoryNotifier extends Notifier<PhotographerCategoryState> {
  late PhotographerCategoryRepository _repository;

  PhotographerCategoryRepository get repository => _repository;

  @override
  PhotographerCategoryState build() {
    _repository = PhotographerCategoryRepositoryImpl();

    return PhotographerCategoryState();
  }

  Future<void> loadCategories() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final categories = await _repository.getCategories();
      state = state.copyWith(categories: categories, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // 카테고리 생성 (관리자만)
  Future<void> createCategory(PhotographerCategory category) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      await _repository.createCategory(category);
      await loadCategories(); // 목록 새로고침
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // 카테고리 수정 (관리자만)
  Future<void> updateCategory(
      String categoryId, PhotographerCategory updatedCategory) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      await _repository.updateCategory(categoryId, updatedCategory);
      await loadCategories(); // 목록 새로고침
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // 카테고리 삭제 (관리자만)
  Future<void> deleteCategory(String categoryId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      await _repository.deleteCategory(categoryId);
      await loadCategories(); // 목록 새로고침
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // 에러 초기화
  void clearError() {
    state = state.copyWith(error: null);
  }
}

// 실제 창고 개설
final photographerCategoryProvider =
    NotifierProvider<PhotographerCategoryNotifier, PhotographerCategoryState>(
  () => PhotographerCategoryNotifier(),
);
