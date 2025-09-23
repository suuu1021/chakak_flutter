// 창고 데이터
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/photo_service_category.dart';
import '../../../data/models/repositories/photo_service_category_repository.dart';
import '../../core/dio_provider.dart';

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
} // end of PhotoServiceCategoryState

// 창고 메뉴얼 (확장된 VM 개념)
class PhotoServiceCategoryNotifier extends Notifier<PhotoServiceCategoryState> {
  late PhotoServiceCategoryRepository _repository;
  late Dio _dio; // Dio 인스턴스 추가

  PhotoServiceCategoryRepository get repository => _repository;

  @override
  PhotoServiceCategoryState build() {
    _dio = ref.watch(dioProvider); // dioProvider에서 공통 Dio 인스턴스 가져오기
    _repository = PhotoServiceCategoryRepositoryImpl(_dio); // Dio 인스턴스 주입

    return PhotoServiceCategoryState();
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
  Future<void> createCategory(PhotoServiceCategory category) async {
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
      String categoryId, PhotoServiceCategory updatedCategory) async {
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
final photoServiceCategoryProvider =
    NotifierProvider<PhotoServiceCategoryNotifier, PhotoServiceCategoryState>(
  () => PhotoServiceCategoryNotifier(),
);
