import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../search_history.dart';

abstract class SearchHistoryRepository {
  Future<List<SearchHistory>> getRecentSearches();
  Future<List<SearchHistory>> getPopularSearches();
  Future<void> addSearchHistory(String keyword);
  Future<void> removeSearchHistory(String id);
  Future<void> clearAllHistory();
}

class SearchHistoryRepositoryImpl implements SearchHistoryRepository {
  static const String _recentSearchKey = 'recent_searches';
  static const int _maxHistoryCount = 20;

  @override
  Future<List<SearchHistory>> getRecentSearches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> searchStrings =
          prefs.getStringList(_recentSearchKey) ?? [];

      return searchStrings.map((searchString) {
        final Map<String, dynamic> json = jsonDecode(searchString);
        return SearchHistory.fromMap(json);
      }).toList();
    } catch (e) {
      print('최근 검색어 로드 실패: $e');
      return [];
    }
  }

  @override
  Future<List<SearchHistory>> getPopularSearches() async {
    // 인기 검색어는 하드코딩된 데이터 사용 (서버 없이)
    await Future.delayed(const Duration(milliseconds: 100));

    final mockData = [
      SearchHistory(
        id: 'p1',
        keyword: '웨딩',
        searchedAt: DateTime.now(),
        type: SearchType.popular,
      ),
      SearchHistory(
        id: 'p2',
        keyword: '가족사진',
        searchedAt: DateTime.now(),
        type: SearchType.popular,
      ),
      SearchHistory(
        id: 'p3',
        keyword: '프로필',
        searchedAt: DateTime.now(),
        type: SearchType.popular,
      ),
      SearchHistory(
        id: 'p4',
        keyword: '커플',
        searchedAt: DateTime.now(),
        type: SearchType.popular,
      ),
      SearchHistory(
        id: 'p5',
        keyword: '졸업',
        searchedAt: DateTime.now(),
        type: SearchType.popular,
      ),
      SearchHistory(
        id: 'p6',
        keyword: '돌잔치',
        searchedAt: DateTime.now(),
        type: SearchType.popular,
      ),
      SearchHistory(
        id: 'p7',
        keyword: '스튜디오',
        searchedAt: DateTime.now(),
        type: SearchType.popular,
      ),
    ];

    return mockData;
  }

  @override
  Future<void> addSearchHistory(String keyword) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> searchStrings =
          prefs.getStringList(_recentSearchKey) ?? [];

      // 새로운 검색어 생성
      final newSearch = SearchHistory(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        keyword: keyword.trim(),
        searchedAt: DateTime.now(),
        type: SearchType.recent,
      );

      // 기존 리스트를 SearchHistory로 변환
      List<SearchHistory> searches = searchStrings.map((searchString) {
        final Map<String, dynamic> json = jsonDecode(searchString);
        return SearchHistory.fromMap(json);
      }).toList();

      // 중복 제거
      searches.removeWhere((search) => search.keyword == keyword.trim());

      // 새 검색어를 맨 앞에 추가
      searches.insert(0, newSearch);

      // 최대 개수 제한
      if (searches.length > _maxHistoryCount) {
        searches = searches.take(_maxHistoryCount).toList();
      }

      // JSON 문자열로 변환하여 저장
      final updatedSearchStrings = searches.map((search) {
        return jsonEncode(search.toMap());
      }).toList();

      await prefs.setStringList(_recentSearchKey, updatedSearchStrings);
    } catch (e) {
      print('검색어 추가 실패: $e');
    }
  }

  @override
  Future<void> removeSearchHistory(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> searchStrings =
          prefs.getStringList(_recentSearchKey) ?? [];

      // 해당 ID의 검색어 제거
      final updatedSearchStrings = searchStrings.where((searchString) {
        final Map<String, dynamic> json = jsonDecode(searchString);
        return json['id'] != id;
      }).toList();

      await prefs.setStringList(_recentSearchKey, updatedSearchStrings);
    } catch (e) {
      print('검색어 삭제 실패: $e');
    }
  }

  @override
  Future<void> clearAllHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_recentSearchKey);
    } catch (e) {
      print('전체 검색 기록 삭제 실패: $e');
    }
  }
}
