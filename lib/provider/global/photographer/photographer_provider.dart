// 창고 데이터
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/photographer.dart';
import '../../../data/models/repositories/photographer_repository.dart';

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
} // end of PhotographerState

// 창고 메뉴얼 (확장된 VM 개념)
class PhotographerNotifier extends Notifier<PhotographerState> {
  late PhotographerRepository _repository;

  PhotographerRepository get repository => _repository;

  @override
  PhotographerState build() {
    _repository = PhotographerRepositoryImpl();

    return PhotographerState();
  }

  Future<void> loadPhotographers() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final photographers = await _repository.getPhotographers();
      state = state.copyWith(photographers: photographers, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> toggleLike(int photographerId) async {
    try {
      // 현재 좋아요 상태 찾기
      final currentPhotographer = state.photographers
          .firstWhere((photographer) => photographer.id == photographerId);
      final newLikeStatus = !currentPhotographer.isLiked;

      // API 호출
      await _repository.updateLikeStatus(photographerId, newLikeStatus);

      // 상태 업데이트
      final photographers = state.photographers.map((photographer) {
        if (photographer.id == photographerId) {
          return photographer.copyWith(isLiked: newLikeStatus);
        }
        return photographer;
      }).toList();

      state = state.copyWith(photographers: photographers);
    } catch (e) {
      print('포토그래퍼 좋아요 상태 변경 실패: $e');
      // 에러 발생 시 상태 복원 로직 추가 가능
    }
  }

  // 포토그래퍼 ID로 조회
  Photographer? getPhotographerById(int photographerId) {
    try {
      return state.photographers
          .firstWhere((photographer) => photographer.id == photographerId);
    } catch (e) {
      return null;
    }
  }

  // 카테고리로 필터링
  List<Photographer> getPhotographersByCategory(String category) {
    return state.photographers
        .where((photographer) => photographer.categories.contains(category))
        .toList();
  }

  // 에러 초기화
  void clearError() {
    state = state.copyWith(error: null);
  }

// TODO - 추가 비즈니스 로직 설계 (검색, 정렬 등)
}

// 실제 창고 개설
final photographerProvider =
    NotifierProvider<PhotographerNotifier, PhotographerState>(
  () => PhotographerNotifier(),
);
