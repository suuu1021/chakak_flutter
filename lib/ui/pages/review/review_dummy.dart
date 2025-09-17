import '../../../data/dtos/review_dto.dart';

// 스크롤 테스트를 위해 20개 생성
final List<ReviewDto> dummyReviews = List.generate(20, (index) {
  return ReviewDto(
    id: (index + 1).toString(),
    reviewerId: "user_${100 + index}",
    photographerId: "photo_${200 + (index % 3)}", // 작가 3명 순환
    rating: (index % 5) + 1, // 1~5 별점 순환
    comment: "이것은 ${index + 1}번째 리뷰 코멘트입니다. 촬영이 매우 즐거웠습니다!",
    createdAt: DateTime.now().subtract(Duration(days: index)),
  );
});
