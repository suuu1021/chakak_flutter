import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../dtos/review/reviewCreationRequestDto.dart';
import '../../dtos/review/review_dto.dart';
import '../../dtos/review/review_status_dto.dart';
import '../../dtos/paged_response_dto.dart';

class ReviewRepository {
  final Dio _dio;


  ReviewRepository(this._dio);

  static const String _createReviewEndpoint = '/api/v1/photo-services/reviews';
  static const String _photoServicesBaseEndpoint = '/api/v1/photo-services';

  /// 리뷰 생성
  Future<ReviewDto> createReview(ReviewCreationRequestDto requestDto) async {
    try {
      final response = await _dio.post(
        _createReviewEndpoint,
        data: requestDto.toJson(),
      );

      if (response.statusCode == 201 &&
          response.data != null &&
          response.data['body'] != null) {
        return ReviewDto.fromJson(
            response.data['body'] as Map<String, dynamic>);
      } else {
        String serverMsg = response.data?['msg'] ?? '알 수 없는 서버 오류';
        throw Exception('리뷰 생성 실패: $serverMsg');
      }
    } catch (e) {
      if (kDebugMode) print('[ReviewRepository] createReview 에러: $e');
      rethrow;
    }
  }

  /// 리뷰 통계 조회
  Future<ReviewStatusDto> getReviewStatus(int serviceId) async {
    final String endpoint =
        '$_photoServicesBaseEndpoint/$serviceId/reviews/stats';

    try {
      final response = await _dio.get(endpoint);

      if (response.statusCode == 200 &&
          response.data != null &&
          response.data['body'] != null) {
        return ReviewStatusDto.fromJson(
            response.data['body'] as Map<String, dynamic>);
      } else {
        throw Exception('리뷰 통계 조회 실패');
      }
    } catch (e) {
      if (kDebugMode) print('[ReviewRepository] getReviewStatus 에러: $e');
      rethrow;
    }
  }

  /// 리뷰 목록 조회 (페이징)
  Future<PagedResponseDto<ReviewDto>> getReviews(
      int serviceId, {
        int page = 0,
        int size = 10,
        String? sortBy,
        String? sortDir,
      }) async {
    final String endpoint = '$_photoServicesBaseEndpoint/$serviceId/reviews';
    final Map<String, dynamic> queryParams = {
      'page': page,
      'size': size,
      if (sortBy != null) 'sortBy': sortBy,
      if (sortDir != null) 'sortDir': sortDir,
    };

    try {
      final response = await _dio.get(endpoint, queryParameters: queryParams);

      if (response.statusCode == 200 &&
          response.data != null &&
          response.data['body'] != null) {
        return PagedResponseDto.fromJson(
          response.data['body'] as Map<String, dynamic>,
              (json) => ReviewDto.fromJson(json as Map<String, dynamic>),
        );
      } else {
        // 공통 응답 형식에 따라 msg 필드를 사용하도록 수정
        String serverMsg = response.data?['msg'] ?? '알 수 없는 오류';
        throw Exception('리뷰 목록 조회 실패: $serverMsg');
      }
    } catch (e) {
      if (kDebugMode) print('[ReviewRepository] getReviews 에러: $e');
      rethrow;
    }
  }

  /// ✅ 최근 리뷰 조회 (5개만)
  Future<List<ReviewDto>> getRecentReviews(int serviceId) async {
    // ⚠️ 서버에 /recent API가 없을 경우, getReviews로 size=5, sortBy=createdAt, sortDir=desc 대체 가능
    final String endpoint =
        '$_photoServicesBaseEndpoint/$serviceId/reviews/recent';

    try {
      final response = await _dio.get(endpoint);

      if (response.statusCode == 200 &&
          response.data != null &&
          response.data['body'] != null) {
        final List<dynamic> list = response.data['body'] as List<dynamic>;
        return list
            .map((json) => ReviewDto.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        // 공통 응답 형식에 따라 msg 필드를 사용하도록 수정
        String serverMsg = response.data?['msg'] ?? '알 수 없는 오류';
        throw Exception('최근 리뷰 조회 실패: $serverMsg');
      }
    } catch (e) {
      if (kDebugMode) print('[ReviewRepository] getRecentReviews 에러: $e');
      rethrow;
    }
  }

  /// 내가 작성한 리뷰 목록 조회 (페이징)
  Future<PagedResponseDto<ReviewDto>> getMyReviews({
    int page = 0,
    int size = 10,
  }) async {
    const String endpoint = '$_photoServicesBaseEndpoint/my-reviews'; // API 2-3 URL
    final Map<String, dynamic> queryParams = {
      'page': page,
      'size': size,
    };

    try {
      // API 2-3은 인증이 필요함. _dio 인스턴스가 이미 인증 헤더를 처리한다고 가정.
      final response = await _dio.get(endpoint, queryParameters: queryParams);

      if (response.statusCode == 200 &&
          response.data != null &&
          response.data['body'] != null) {
        return PagedResponseDto.fromJson(
          response.data['body'] as Map<String, dynamic>,
          (json) => ReviewDto.fromJson(json as Map<String, dynamic>),
        );
      } else {
        // 공통 응답 형식에 따라 msg 필드를 사용하도록 수정
        String serverMsg = response.data?['msg'] ?? '알 수 없는 오류';
        throw Exception('내가 작성한 리뷰 목록 조회 실패: $serverMsg');
      }
    } catch (e) {
      if (kDebugMode) print('[ReviewRepository] getMyReviews 에러: $e');
      rethrow; // 에러를 다시 던져서 UI 레이어에서 처리할 수 있도록 함
    }
  }
}
