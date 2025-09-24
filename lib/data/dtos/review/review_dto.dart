import '../../models/review.dart'; // Review, AuthorInfo 모델 임포트

class ReviewDto {
  final String id; // 리뷰의 고유 ID (서버에서는 reviewId로 올 수 있음)
  final String reviewerId; // 리뷰 작성자의 사용자 ID (서버에서는 userId로 올 수 있음)
  final String? serviceId;
  final int? bookingId;
  final double rating;
  final String? reviewContent; // 리뷰 내용 (서버에서는 content로 올 수 있음)
  final DateTime createdAt;
  final String? reviewerNickname; // DTO에 닉네임 필드가 있다면 사용
  final String? thumbnailUrl;   // DTO에 썸네일 필드가 있다면 사용

  ReviewDto({
    required this.id,
    required this.reviewerId,
    this.serviceId,
    this.bookingId,
    required this.rating,
    this.reviewContent,
    required this.createdAt,
    this.reviewerNickname, // 생성자에 추가
    this.thumbnailUrl,   // 생성자에 추가
  });

  // JSON으로부터 ReviewDto 객체를 생성하는 factory 생성자
  // 서버 응답 필드명에 따라 유연하게 파싱하도록 수정
  factory ReviewDto.fromJson(Map<String, dynamic> json) {
    // 서버 응답에서 reviewId 또는 id를 사용, userId 또는 reviewerId를 사용 등 변형에 대처
    String parsedId = (json['reviewId'] ?? json['id'])?.toString() ?? '0';
    String parsedReviewerId = (json['userId'] ?? json['reviewerId'])?.toString() ?? '0';
    String? parsedContent = (json['content'] ?? json['reviewContent'])?.toString();
    String? parsedNickname = (json['author'] is Map ? json['author']['nickname'] : json['reviewerNickname'])?.toString();
    String? parsedThumbnailUrl = (json['thumbnailUrl'] ?? json['imageUrls']?.firstWhere((img) => img['isThumbnail'] == true, orElse: () => null)?['imageUrl'])?.toString();


    return ReviewDto(
      id: parsedId,
      reviewerId: parsedReviewerId,
      serviceId: json['serviceId']?.toString(),
      bookingId: json['bookingId'] as int?,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewContent: parsedContent,
      createdAt: DateTime.parse(json['createdAt'] as String? ?? DateTime.now().toIso8601String()),
      reviewerNickname: parsedNickname,
      thumbnailUrl: parsedThumbnailUrl,
    );
  }

  /// ✅ 변경된 Review 모델로 변환하는 헬퍼
  Review toModel() {
    return Review(
      reviewId: int.tryParse(id) ?? 0, // String -> int
      rating: rating,
      content: reviewContent ?? '', // null이면 빈 문자열
      thumbnailUrl: thumbnailUrl, // DTO의 thumbnailUrl 사용
      author: AuthorInfo(
        userId: int.tryParse(reviewerId) ?? 0, // String -> int
        // DTO에 reviewerNickname 필드가 있다면 사용, 없다면 임시값
        nickname: reviewerNickname ?? "작성자 ${reviewerId.substring(0, reviewerId.length < 3 ? reviewerId.length : 3)}",
      ),
      createdAt: createdAt.toIso8601String(), // DateTime -> String
    );
  }
}
