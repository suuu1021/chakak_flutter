import '../dtos/search_history_dto.dart';

class SearchHistory {
  final String id;
  final String keyword;
  final DateTime searchedAt;
  final SearchType type;

  SearchHistory({
    required this.id,
    required this.keyword,
    required this.searchedAt,
    required this.type,
  });

  factory SearchHistory.fromDto(SearchHistoryDto dto) {
    return SearchHistory(
      id: dto.id,
      keyword: dto.keyword,
      searchedAt: dto.searchedAt,
      type: dto.type,
    );
  }

  SearchHistoryDto toDto() {
    return SearchHistoryDto(
      id: id,
      keyword: keyword,
      searchedAt: searchedAt,
      type: type,
    );
  }

  factory SearchHistory.fromMap(Map<String, dynamic> map) {
    return SearchHistory(
      id: map['id'],
      keyword: map['keyword'],
      searchedAt: DateTime.parse(map['searchedAt']),
      type: SearchType.fromString(map['type']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'keyword': keyword,
      'searchedAt': searchedAt.toIso8601String(),
      'type': type.value,
    };
  }

  SearchHistory copyWith({
    String? id,
    String? keyword,
    DateTime? searchedAt,
    SearchType? type,
  }) {
    return SearchHistory(
      id: id ?? this.id,
      keyword: keyword ?? this.keyword,
      searchedAt: searchedAt ?? this.searchedAt,
      type: type ?? this.type,
    );
  }
}

enum SearchType {
  recent('recent'),
  popular('popular');

  const SearchType(this.value);

  final String value;

  static SearchType fromString(String value) {
    return SearchType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => SearchType.recent,
    );
  }
}
