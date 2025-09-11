import '../../../data/models/repositories/search_history_repository.dart';
import '../../../data/models/search_history.dart';

class SearchApiService {
  final SearchHistoryRepository _repository;

  SearchApiService(this._repository);

  Future<List<SearchHistory>> getRecentSearches() async {
    return await _repository.getRecentSearches();
  }

  Future<List<SearchHistory>> getPopularSearches() async {
    return await _repository.getPopularSearches();
  }

  Future<void> addSearchHistory(String keyword) async {
    return await _repository.addSearchHistory(keyword);
  }

  Future<void> removeSearchHistory(String id) async {
    return await _repository.removeSearchHistory(id);
  }

  Future<void> clearAllHistory() async {
    return await _repository.clearAllHistory();
  }
}
