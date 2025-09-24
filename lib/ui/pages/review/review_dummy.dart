// 스크롤 테스트를 위해 20개 생성

import '../../../data/models/review.dart'; // Review와 AuthorInfo 모델을 포함

final List<Review> dummyReviews = List.generate(20, (index) {
  return Review(
    reviewId: index + 1, // String -> int, 필드명 변경
    author: AuthorInfo( // reviewerId -> author 객체
      userId: 100 + index,
      nickname: "더미사용자 ${index + 1}",
    ),
    rating: ((index % 5) + 1).toDouble(), // 정수를 double로 변환
    content: "이것은 ${index + 1}번째 리뷰 코멘트입니다. 촬영이 매우 즐거웠습니다!", // reviewContent -> content
    createdAt: DateTime.now().subtract(Duration(days: index)).toIso8601String(), // DateTime -> String
    thumbnailUrl: null, // 새로운 nullable 필드 추가
    // serviceId 와 bookingId는 Review 모델에서 제거됨
  );
});
