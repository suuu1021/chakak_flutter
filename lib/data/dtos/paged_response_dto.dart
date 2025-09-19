class PagedResponseDto<T> {
  final List<T> content;
  final int totalPages;
  final int totalElements;
  final bool last;
  final int size;
  final int number; // 현재 페이지 번호 (0부터 시작)
  final bool first;
  final int numberOfElements; // 현재 페이지의 요소 수
  final bool empty;

  PagedResponseDto({
    required this.content,
    required this.totalPages,
    required this.totalElements,
    required this.last,
    required this.size,
    required this.number,
    required this.first,
    required this.numberOfElements,
    required this.empty,
  });

  factory PagedResponseDto.fromJson(
      Map<String, dynamic> json, T Function(dynamic json) fromJsonT) {
    return PagedResponseDto<T>(
      content: (json['content'] as List<dynamic>)
          .map((itemJsom) => fromJsonT(itemJsom))
          .toList(),
      totalPages: json['totalPages'] as int,
      totalElements: json['totalElements'] as int,
      last: json['last'] as bool,
      size: json['size'] as int,
      number: json['number'] as int,
      first: json['first'] as bool,
      numberOfElements: json['numberOfElements'] as int,
      empty: json['empty'] as bool,
    );
  }
}
