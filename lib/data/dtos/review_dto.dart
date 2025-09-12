class ReviewDto {
  final String id;
  final String reviewerId;       // 리뷰 작성자
  final String photographerId;   // 대상 작가
  final int rating;              // 별점 (1~5)
  final String? comment;         // 코멘트
  final DateTime createdAt;

  ReviewDto({
    required this.id,
    required this.reviewerId,
    required this.photographerId,
    required this.rating,
    this.comment,
    required this.createdAt,
  });

  factory ReviewDto.fromJson(Map<String, dynamic> json) {
    return ReviewDto(
      id: json['id'],
      reviewerId: json['reviewer_id'],
      photographerId: json['photographer_id'],
      rating: json['rating'],
      comment: json['comment'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
