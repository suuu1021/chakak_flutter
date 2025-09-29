class ReviewStatusDto {
  final double averageRating;
  final int totalReviews;

  ReviewStatusDto({
    required this.averageRating,
    required this.totalReviews,
  });
  factory ReviewStatusDto.fromJson(Map<String, dynamic> json) {
    return ReviewStatusDto(
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0.0,
      totalReviews: json['totalReviews'] as int? ?? 0,
    );
  }

  @override
  String toString() {
    return 'ReviewStatusDto(averageRating: $averageRating, totalReviews: $totalReviews)';
  }
}
