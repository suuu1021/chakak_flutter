import '../../../data/models/review/review_dto.dart';

// 스크롤 테스트를 위해 20개 생성
final List<ReviewDto> dummyReviews = List.generate(20, (index) {
  return ReviewDto(
    id: (index + 1).toString(),
    reviewerId: "user_${100 + index}",
    serviceId: (500 + (index % 3)).toString(), // ✅ 서비스 ID 3개 순환
    rating: (index % 5) + 1,
    comment: "이것은 ${index + 1}번째 리뷰 코멘트입니다. 촬영이 매우 즐거웠습니다!",
    createdAt: DateTime.now().subtract(Duration(days: index)),
  );
});
