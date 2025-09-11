class SearchHistoryDto {
  final String id;
  final String keyword;
  final DateTime searchedAt;
  final String type; // 'recent', 'popular'

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
}
