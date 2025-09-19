import 'package:dio/dio.dart';

import '../review/reviewCreationRequestDto.dart';
import '../review/review_dto.dart';

class ReviewRepository {
  final Dio _dio;

  ReviewRepository(this._dio);

  // API 엔드포인트 상수
  static const String _createReviewEndpoint = '/api/v1/photo-services/review';
  static const String _myBookingsEndpoint = '/api/bookings/my-bookings';

  /// 리뷰 생성 API 호출
  Future<ReviewDto> createReview(ReviewCreationRequestDto requestDto) async {
    try {
      final response = await _dio.post(
        _createReviewEndpoint,
        data: requestDto.toJson(),
      );

      // 서버응 답이 {"status": ..., "body":{...ReviewDto}} 구조라는 가정
      if (response.statusCode == 201 &&
          response.data != null &&
          response.data['body'] != null) {
        return ReviewDto.fromJson(
            response.data['body'] as Map<String, dynamic>);
      } else {
        throw Exception('리뷰 생성에 실패 서버 응답: (코드: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('[ReviewRepository] createReview 알 수 없는 에러: $e');
      throw Exception('알수 없는 오류로 리뷰 생성에 실패했습니다.');
    }
  }

  // /// 내 예약 목록 조회 API 호출
  // Future<PageResponseDto<ApiBookingItemDto>> getMyBookings(>
}
