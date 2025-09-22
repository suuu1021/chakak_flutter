class ReviewDto {
  final String id;
  final String reviewerId; // 리뷰 작성자
  final String serviceId; // 리뷰가 달린 서비스 ID
  final int bookingId; // 리뷰가 속한 예약 ID
  final double rating; // 별점 (1~5)
  final String? comment; // 코멘트
  final DateTime createdAt;

  ReviewDto({
    required this.id,
    required this.reviewerId,
    required this.serviceId,
    required this.bookingId,
    required this.rating,
    this.comment,
    required this.createdAt,
  });

  factory ReviewDto.fromJson(Map<String, dynamic> json) {
    // 서버 응답에서 'booking_id'라는 키로 예약 ID가 온다고 가정합니다.
    // 만약 키 이름이나 타입이 다르면 이 부분을 수정해야 합니다.
    final bookingIdFromJson = json['booking_id'];
    if (bookingIdFromJson == null){
      // 여기서 예약 ID는 필수적이기에 에러를 던지는것으로 함
      throw FormatException("[ReviewDto.fromJson 오류] 서버 응답에 'booking_id' 필드가 없거나 null입니다."); //
    }
    if (bookingIdFromJson is! int){
      throw FormatException(
          "[ReviewDto.fromJson 오류] 'booking_id' 필드가 정수 타입이 아닙니다. 수신된 값: $bookingIdFromJson"
      );
    }
    return ReviewDto(
      id: json['id'] as String,
      reviewerId: json['reviewer_id'] as String,
      serviceId: json['service_id'] as String,
      bookingId: bookingIdFromJson,
      rating: (json['rating'] as num).toDouble(),
      comment: json['comment'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
