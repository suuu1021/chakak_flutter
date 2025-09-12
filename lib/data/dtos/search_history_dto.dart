import '../models/search_history.dart';

class SearchHistoryDto {
  final String id;
  final String keyword;
  final DateTime searchedAt;
  final SearchType type;

  SearchHistoryDto({
    required this.id,
    required this.keyword,
    required this.searchedAt,
    required this.type,
  });

  factory SearchHistoryDto.fromJson(Map<String, dynamic> json) {
    return SearchHistoryDto(
      id: json['id'],
      keyword: json['keyword'],
      searchedAt: DateTime.parse(json['searched_at']),
      type: json['type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'keyword': keyword,
      'searched_at': searchedAt.toIso8601String(),
      'type': type,
    };
  }

  // Model에서 DTO로 변환
  factory SearchHistoryDto.fromModel(SearchHistory model) {
    return SearchHistoryDto(
      id: model.id,
      keyword: model.keyword,
      searchedAt: model.searchedAt,
      type: model.type,
    );
  }

  // DTO에서 Model로 변환
  SearchHistory toModel() {
    return SearchHistory(
      id: id,
      keyword: keyword,
      searchedAt: searchedAt,
      type: type,
    );
  }
}
