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

  @override
  String toString() {
    return 'Review(id: $id, reviewerId: $reviewerId, serviceId: $serviceId, bookingId: $bookingId, rating: $rating, reviewContent: $reviewContent, createdAt: $createdAt)';
  }
}

// --- [새로 추가되는 코드] ---

// 2-2. 리뷰 목록 조회의 "body" 부분
class ReviewPage {
  final List<Review2> content;
  final bool last;
  final int totalPages;
  final int totalElements;
  final int size;
  final int number; // 현재 페이지 번호 (0부터 시작)
  final bool first;
  final int numberOfElements;
  final bool empty;

  ReviewPage({
    required this.content,
    required this.last,
    required this.totalPages,
    required this.totalElements,
    required this.size,
    required this.number,
    required this.first,
    required this.numberOfElements,
    required this.empty,
  });

  factory ReviewPage.fromJson(Map<String, dynamic> json) {
    return ReviewPage(
      content:
          (json['content'] as List).map((item) => Review2.fromJson(item)).toList(),
      last: json['last'],
      totalPages: json['totalPages'],
      totalElements: json['totalElements'],
      size: json['size'],
      number: json['number'],
      first: json['first'],
      numberOfElements: json['numberOfElements'],
empty: json['empty'],
    );
  }
}

// 2-2. 리뷰 목록 조회의 "content" 배열 내부 객체
class Review2 {
  final int reviewId;
  final double rating;
  final String content;
  final String? thumbnailUrl;
  final AuthorInfo author;
  final String createdAt;

  Review2({
    required this.reviewId,
    required this.rating,
    required this.content,
    this.thumbnailUrl,
    required this.author,
    required this.createdAt,
  });

  factory Review2.fromJson(Map<String, dynamic> json) {
    return Review2(
      reviewId: json['reviewId'],
      rating: (json['rating'] as num).toDouble(),
      content: json['content'],
      thumbnailUrl: json['thumbnailUrl'],
      author: AuthorInfo.fromJson(json['author']),
      createdAt: json['createdAt'],
    );
  }
}

// 2-2. 리뷰 목록 조회의 "author" 객체
class AuthorInfo {
  final int userId;
  final String nickname;

  AuthorInfo({
    required this.userId,
    required this.nickname,
  });

  factory AuthorInfo.fromJson(Map<String, dynamic> json) {
    return AuthorInfo(
      userId: json['userId'],
      nickname: json['nickname'],
    );
  }
}
