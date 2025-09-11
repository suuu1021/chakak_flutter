import 'package:chakak_flutter/provider/global/search/search_api_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/repositories/search_history_repository.dart';
import '../../../data/models/search_history.dart';

// Repository Provider
final searchHistoryRepositoryProvider =
    Provider<SearchHistoryRepository>((ref) {
  return SearchHistoryRepositoryImpl();
});

// API Service Provider
final searchApiServiceProvider = Provider<SearchApiService>((ref) {
  final repository = ref.read(searchHistoryRepositoryProvider);
  return SearchApiService(repository);
});

// State 클래스
class SearchState {
  final List<SearchHistory> recentSearches;
  final List<SearchHistory> popularSearches;
  final String currentQuery;
  final bool isLoading;
  final String? error;

  SearchState({
    this.recentSearches = const [],
    this.popularSearches = const [],
    this.currentQuery = '',
    this.isLoading = false,
    this.error,
  });

  SearchState copyWith({
    List<SearchHistory>? recentSearches,
    List<SearchHistory>? popularSearches,
    String? currentQuery,
    bool? isLoading,
    String? error,
  }) {
    return SearchState(
      recentSearches: recentSearches ?? this.recentSearches,
      popularSearches: popularSearches ?? this.popularSearches,
      currentQuery: currentQuery ?? this.currentQuery,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Notifier 클래스
class SearchNotifier extends StateNotifier<SearchState> {
  final SearchApiService _apiService;

  SearchNotifier(this._apiService) : super(SearchState());

  Future<void> loadSearchData() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final recentFuture = _apiService.getRecentSearches();
      final popularFuture = _apiService.getPopularSearches();

      final results = await Future.wait([recentFuture, popularFuture]);

      state = state.copyWith(
        recentSearches: results[0],
        popularSearches: results[1],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void updateQuery(String query) {
    state = state.copyWith(currentQuery: query);
  }

  Future<void> addSearch(String keyword) async {
    try {
      print('Repository addSearch 호출 전');
      await _apiService.addSearchHistory(keyword);
      print('Repository addSearch 호출 후');

      // 최근 검색어를 다시 로드하지 말고 직접 업데이트
      final recentSearches = await _apiService.getRecentSearches();
      state = state.copyWith(recentSearches: recentSearches);
      print('State 업데이트 완료');
    } catch (e) {
      print('검색어 추가 실패: $e');
    }
  }

  Future<void> removeRecentSearch(String id) async {
    try {
      await _apiService.removeSearchHistory(id);

      // 로컬 상태에서도 제거
      final updatedRecentSearches =
          state.recentSearches.where((search) => search.id != id).toList();

      state = state.copyWith(recentSearches: updatedRecentSearches);
    } catch (e) {
      print('검색어 삭제 실패: $e');
    }
  }

  Future<void> clearAllHistory() async {
    try {
      await _apiService.clearAllHistory();
      state = state.copyWith(recentSearches: []);
    } catch (e) {
      print('전체 검색 기록 삭제 실패: $e');
    }
  }
}

// Provider
final searchNotifierProvider =
    StateNotifierProvider<SearchNotifier, SearchState>((ref) {
  final apiService = ref.read(searchApiServiceProvider);
  return SearchNotifier(apiService);
});
