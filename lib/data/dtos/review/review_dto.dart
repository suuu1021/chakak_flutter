import '../../models/review.dart';

class ReviewDto {
  final String id;
  final String reviewerId;
  final String? serviceId;
  final int? bookingId;
  final double rating;
  final String? reviewContent;
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
    String parsedId = json['reviewId'].toString();

    final int userIdFromServer = json['userId'];
    final dynamic rawServiceId = json['serviceId'];
    final num ratingFromServer = json['rating'];
    final String createdAtString = json['createdAt'];

    return ReviewDto(
      id: parsedId,
      reviewerId: userIdFromServer.toString(),
      serviceId: rawServiceId?.toString(),
      bookingId: json['bookingId'] as int?,
      rating: ratingFromServer.toDouble(),
      reviewContent: json['reviewContent']?.toString(),
      createdAt: DateTime.parse(createdAtString),
    );
  }

  /// ✅ Review 모델로 변환하는 헬퍼
  Review toModel() {
    return Review(
      id: id,
      reviewerId: reviewerId,
      serviceId: serviceId,
      bookingId: bookingId,
      rating: rating,
      reviewContent: reviewContent,
      createdAt: createdAt,
    );
  }
}
