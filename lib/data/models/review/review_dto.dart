class ReviewDto {
  final String id;
  final String reviewerId; // 리뷰 작성자
  final String serviceId; // 리뷰가 달린 서비스 ID
  final double rating; // 별점 (1~5)
  final String? comment; // 코멘트
  final DateTime createdAt;

  ReviewDto({
    required this.id,
    required this.reviewerId,
    required this.serviceId,
    required this.rating,
    this.comment,
    required this.createdAt,
  });

  factory ReviewDto.fromJson(Map<String, dynamic> json) {
    return ReviewDto(
      id: json['id'] as String,
      reviewerId: json['reviewer_id'] as String,
      serviceId: json['service_id'] as String,
      rating: (json['rating'] as num).toDouble(),
      comment: json['comment'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
