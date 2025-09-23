import '../../models/review.dart'; // Review 모델 사용 여부에 따라 유지 또는 제거

class ReviewDto {
  final String id;
  final String reviewerId; // 리뷰 작성자 (서버에서는 userId (int)로 옴)
  final String? serviceId; // 리뷰가 달린 서비스 ID
  final int? bookingId; // 리뷰가 속한 예약 ID
  final double rating; // 별점 (1~5)
  final String? reviewContent; // 코멘트
  final DateTime createdAt;

  ReviewDto({
    required this.id,
    required this.reviewerId,
    this.serviceId,
    this.bookingId,
    required this.rating,
    this.reviewContent,
    required this.createdAt,
  });

  factory ReviewDto.fromJson(Map<String, dynamic> json) {
    String? parsedId;
    final dynamic reviewIdField = json['reviewId'];
    if (reviewIdField is String) {
      parsedId = reviewIdField;
    } else if (reviewIdField is int) {
      parsedId = reviewIdField.toString();
    } else if (reviewIdField is num) {
      // In case it's a double, though unlikely for an ID
      parsedId = reviewIdField.toString();
    }

    if (parsedId == null) {
      throw FormatException(
          "[ReviewDto.fromJson 오류] 'reviewId' 필드가 없거나 null이거나 유효한 타입이 아닙니다 (String 또는 int 필요). 실제 값: ${json['reviewId']}");
    }

    final int? userIdFromServer = json['userId'] as int?;
    if (userIdFromServer == null) {
      throw FormatException(
          "[ReviewDto.fromJson 오류] 'userId' 필드가 없거나 null입니다.");
    }

    final int? bookingIdFromServer = json['bookingId'] as int?;

    // serviceId 파싱 수정
    final dynamic rawServiceId = json['serviceId'];
    String? parsedServiceId;
    if (rawServiceId != null) {
      parsedServiceId = rawServiceId.toString();
    }

    final num? ratingFromServer = json['rating'] as num?;
    if (ratingFromServer == null) {
      throw FormatException(
          "[ReviewDto.fromJson 오류] 'rating' 필드가 없거나 null입니다.");
    }

    final String? createdAtString = json['createdAt'] as String?;
    if (createdAtString == null) {
      throw FormatException(
          "[ReviewDto.fromJson 오류] 'createdAt' 필드가 없거나 null입니다.");
    }

    // reviewContent 파싱은 이전 수정 유지
    final dynamic rawReviewContent = json['reviewContent'];
    String? parsedReviewContent;
    if (rawReviewContent != null) {
      parsedReviewContent = rawReviewContent.toString();
    }

    return ReviewDto(
      id: parsedId,
      reviewerId: userIdFromServer.toString(),
      serviceId: parsedServiceId, // 수정된 serviceId 사용
      bookingId: bookingIdFromServer,
      rating: ratingFromServer.toDouble(),
      reviewContent: parsedReviewContent,
      createdAt: DateTime.parse(createdAtString),
    );
  }
}
