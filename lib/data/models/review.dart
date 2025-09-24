import '../dtos/review/review_dto.dart'; // <<<<<<< ReviewDto import 추가

// API 명세 ("2-2. 특정 서비스(상품)의 리뷰 목록 조회")에 맞춘 Review 모델
class Review {
  final int reviewId;
  final String? serviceId;
  final double rating;
  final String content;
  final String? thumbnailUrl;
  final AuthorInfo author;
  final String createdAt;

  Review({
    required this.reviewId,
    this.serviceId,
    required this.rating,
    required this.content,
    this.thumbnailUrl,
    required this.author,
    required this.createdAt,
  });

  // factory Review.fromJson은 DTO에서 toModel을 사용하므로 여기서는 직접 사용 안 함

  Review copyWith({
    int? reviewId,
    String? serviceId,
    double? rating,
    String? content,
    String? thumbnailUrl,
    AuthorInfo? author,
    String? createdAt,
  }) {
    return Review(
      reviewId: reviewId ?? this.reviewId,
      serviceId: serviceId ?? this.serviceId,
      rating: rating ?? this.rating,
      content: content ?? this.content,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      author: author ?? this.author,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'Review(reviewId: $reviewId, serviceId: $serviceId, rating: $rating, content: $content, thumbnailUrl: $thumbnailUrl, author: $author, createdAt: $createdAt)';
  }
}

// 리뷰 목록의 페이지네이션 정보를 담는 모델
class ReviewPage {
  final List<Review> content;
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
      content: (json['content'] as List)
          .map((item) => ReviewDto.fromJson(item as Map<String, dynamic>).toModel()) // <<<<<<< 수정된 부분
          .toList(),
      last: json['last'] as bool,
      totalPages: json['totalPages'] as int,
      totalElements: json['totalElements'] as int,
      size: json['size'] as int,
      number: json['number'] as int,
      first: json['first'] as bool,
      numberOfElements: json['numberOfElements'] as int,
      empty: json['empty'] as bool,
    );
  }
}

// 리뷰 작성자 정보를 담는 모델 (API 명세와 일치)
class AuthorInfo {
  final int userId;
  final String nickname;

  AuthorInfo({
    required this.userId,
    required this.nickname,
  });

  factory AuthorInfo.fromJson(Map<String, dynamic> json) {
    return AuthorInfo(
      userId: json['userId'] as int,
      nickname: json['nickname'] as String,
    );
  }

  @override
  String toString() {
    return 'AuthorInfo(userId: $userId, nickname: $nickname)';
  }
}
