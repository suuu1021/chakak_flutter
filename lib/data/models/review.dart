class Review {
  final String id;
  final String reviewerId; // 리뷰 작성자 ID
  final String? serviceId; // 리뷰가 달린 서비스 ID
  final int? bookingId; // 이 리뷰가 속한 예약 ID
  final double rating; // 별점 (1~5)
  final String? reviewContent; // 리뷰 내용 (선택 사항)
  final DateTime createdAt; // 리뷰 생성일

  Review({
    required this.id,
    required this.reviewerId,
    this.serviceId,
    this.bookingId,
    required this.rating,
    this.reviewContent,
    required this.createdAt,
  });

  // 이 Review 모델의 데이터를 복사하면서 일부 필드만 변경하는 copyWith 메소드 (선택 사항이지만 유용함)
  Review copyWith({
    String? id,
    String? reviewerId,
    String? serviceId,
    int? bookingId,
    double? rating,
    String? reviewContent,
    DateTime? createdAt,
  }) {
    return Review(
      id: id ?? this.id,
      reviewerId: reviewerId ?? this.reviewerId,
      serviceId: serviceId ?? this.serviceId,
      bookingId: bookingId ?? this.bookingId,
      rating: rating ?? this.rating,
      reviewContent: reviewContent ?? this.reviewContent,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // 디버깅이나 로깅을 위한 toString 메소드 (선택 사항)
  @override
  String toString() {
    return 'Review(id: $id, reviewerId: $reviewerId, serviceId: $serviceId, bookingId: $bookingId, rating: $rating, reviewContent: $reviewContent, createdAt: $createdAt)';
  }

  // 만약 이 모델을 Map으로 변환하거나 (예: 로컬 DB 저장용),
  // Map에서 이 모델을 생성하는 로직이 필요하다면 여기에 추가할 수 있습니다.
  // (서버 API와의 직접적인 변환은 ReviewDto에서 담당할 예정입니다.)
}
