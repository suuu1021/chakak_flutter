class ReviewStatusDto {
  final double averageRating;
  final int totalReviews;

  ReviewStatusDto({
    required this.averageRating,
    required this.totalReviews,
  });
  // factory 생성자는 서버 응답의 "body" 객체 내용을 Map으로 받았을 때 사용합니다.
  factory ReviewStatusDto.fromJson(Map<String, dynamic> json) {
    return ReviewStatusDto(
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0.0,
      totalReviews: json['totalReviews'] as int? ?? 0,
    );
  }

  // (선택 사항 ) 디버깅이나 로깅을 위한 toString 메서드
  @override
  String toString() {
    return 'ReviewStatusDto(averageRating: $averageRating, totalReviews: $totalReviews)';
  }
}
