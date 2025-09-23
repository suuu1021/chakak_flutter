import 'dart:convert';

import 'package:chakak_flutter/data/dtos/paged_response_dto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart'; // kDebugMode 사용을 위해 추가

import '../../dtos/booking/api_booking_item_dto.dart';
import '../../dtos/review/reviewCreationRequestDto.dart';
import '../../dtos/review/review_dto.dart';
import '../../dtos/review/review_status_dto.dart';

class ReviewRepository {
  final Dio _dio;

  ReviewRepository(this._dio);

  static const String _createReviewEndpoint = '/api/v1/photo-services/reviews';
  static const String _myBookingsEndpoint = '/api/bookings/my-bookings';
  static const String _photoServicesBaseEndpoint = '/api/v1/photo-services';

  Future<ReviewDto> createReview(ReviewCreationRequestDto requestDto) async {
    // ... (createReview 메소드는 현재 디버깅 대상이 아니므로 기존 코드 유지) ...
    // 필요하다면 이 메소드에도 유사한 디버깅 로그를 추가할 수 있습니다.
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
        throw Exception('리뷰 생성에 실패: $serverMsg (코드: ${response.statusCode})');
      }
    } on DioException catch (e) {
      String errorMessage = '[ReviewRepository] createReview Dio 에러: $e';
      if (e.response != null && e.response?.data?['msg'] != null) {
        errorMessage =
            '[ReviewRepository] createReview 서버 에러 (코드: ${e.response?.statusCode}): ${e.response?.data?['msg']}';
      }
      if (kDebugMode) {
        print(errorMessage);
      }
      throw Exception('리뷰 생성 중 오류가 발생했습니다.');
    } catch (e) {
      if (kDebugMode) {
        print('[ReviewRepository] createReview 일반 에러: $e');
      }
      throw Exception('리뷰 생성 중 알 수 없는 오류가 발생했습니다.');
    }
  }

  Future<PagedResponseDto<ApiBookingItemDto>> getMyBookings(
      {int page = 0, int size = 10}) async {
    // ... (getMyBookings 메소드는 현재 디버깅 대상이 아니므로 기존 코드 유지) ...
    try {
      final response = await _dio.get(
        _myBookingsEndpoint,
        queryParameters: {
          'page': page,
          'size': size,
        },
      );
      if (response.statusCode == 200 &&
          response.data != null &&
          response.data['body'] != null) {
        return PagedResponseDto.fromJson(
          response.data['body'] as Map<String, dynamic>,
          (json) => ApiBookingItemDto.fromJson(json as Map<String, dynamic>),
        );
      } else {
        String serverMsg = response.data?['msg'] ?? '알 수 없는 서버 오류';
        throw Exception(
            '내 예약 목록 조회에 실패: $serverMsg (코드: ${response.statusCode})');
      }
    } on DioException catch (e) {
      String errorMessage = '[ReviewRepository] getMyBookings Dio 에러: $e';
      if (e.response != null && e.response?.data?['msg'] != null) {
        errorMessage =
            '[ReviewRepository] getMyBookings 서버 에러 (코드: ${e.response?.statusCode}): ${e.response?.data?['msg']}';
      }
      if (kDebugMode) {
        print(errorMessage);
      }
      throw Exception('내 예약 목록 조회 중 오류가 발생했습니다.');
    } catch (e) {
      if (kDebugMode) {
        print('[ReviewRepository] getMyBookings 일반 에러: $e');
      }
      throw Exception('내 예약 목록 조회 중 알 수 없는 오류가 발생했습니다.');
    }
  }

  /// 특정 사진 서비스의 리뷰 통계(평균 평점, 총 리뷰 수) 조회 API 호출
  Future<ReviewStatusDto> getReviewStatus(int serviceId) async {
    if (kDebugMode) {
      // 디버그 모드에서만 실행: 메소드 호출 시작 및 serviceId 값 로깅
      print('[리뷰 통계 조회 시작] 서비스 ID: $serviceId');
    }

    final String endpoint =
        '$_photoServicesBaseEndpoint/$serviceId/reviews/stats';
    if (kDebugMode) {
      // 디버그 모드에서만 실행: 실제 요청될 API 엔드포인트 로깅
      print('[리뷰 통계 조회 요청] API 엔드포인트: $endpoint');
    }

    try {
      final response = await _dio.get(endpoint);

      if (kDebugMode) {
        // 디버그 모드에서만 실행: API 응답 상태 코드 및 데이터 로깅
        print('[리뷰 통계 조회 응답] 상태 코드: ${response.statusCode}');
        print('[리뷰 통계 조회 응답] 데이터: ${response.data}');
      }

      if (response.statusCode == 200 &&
          response.data != null &&
          response.data['body'] != null) {
        // 성공적으로 데이터를 받아와 ReviewStatusDto 객체로 변환하여 반환
        return ReviewStatusDto.fromJson(
            response.data['body'] as Map<String, dynamic>);
      } else {
        // 예상치 못한 응답 코드 또는 데이터 형식일 경우 에러 처리
        String serverMsg = response.data?['msg'] ?? '알 수 없는 서버 오류 메시지';
        if (kDebugMode) {
          print(
              '[리뷰 통계 조회 실패] 서버 메시지: $serverMsg, 응답 코드: ${response.statusCode}');
        }
        throw Exception(
            '리뷰 통계 조회에 실패: $serverMsg (코드: ${response.statusCode})');
      }
    } on DioException catch (e) {
      // Dio 관련 예외 발생 시 (네트워크 오류, HTTP 오류 등)
      if (kDebugMode) {
        print('----------------------------------------------------');
        print('[리뷰 통계 조회 DioException 발생] 서비스 ID: $serviceId');
        print('[리뷰 통계 조회 DioException] 요청 경로: ${e.requestOptions.path}');
        print('[리뷰 통계 조회 DioException] 에러 타입: ${e.type}');
        print('[리뷰 통계 조회 DioException] 에러 메시지: ${e.message}');
        if (e.response != null) {
          print('[리뷰 통계 조회 DioException] 응답 상태 코드: ${e.response?.statusCode}');
          print('[리뷰 통계 조회 DioException] 응답 데이터: ${e.response?.data}');
        } else {
          print('[리뷰 통계 조회 DioException] 응답 객체가 없습니다 (네트워크 연결 문제 등).');
        }
        print('----------------------------------------------------');
      }
      // UI에 표시될 일반적인 에러 메시지
      throw Exception('리뷰 통계 조회 중 오류가 발생했습니다.');
    } catch (e) {
      // 기타 예외 발생 시
      if (kDebugMode) {
        print('----------------------------------------------------');
        print('[리뷰 통계 조회 일반 Exception 발생] 서비스 ID: $serviceId, 에러: $e');
        print('----------------------------------------------------');
      }
      // UI에 표시될 일반적인 에러 메시지
      throw Exception('리뷰 통계 조회 중 알 수 없는 오류가 발생했습니다.');
    }
  }

  /// 특정 사진 서비스의 리뷰 목록 조회 API 호출 (페이징 및 정렬 포함)
  Future<PagedResponseDto<ReviewDto>> getReviews(
    int serviceId, {
    int page = 0,
    int size = 10,
    String? sortBy,
    String? sortDir,
  }) async {
    if (kDebugMode) {
      // 디버그 모드에서만 실행: 메소드 호출 시작 및 파라미터 로깅
      print(
          '[리뷰 목록 조회 시작] 서비스 ID: $serviceId, 페이지: $page, 크기: $size, 정렬 기준: $sortBy, 정렬 방향: $sortDir');
    }

    final String endpoint = '$_photoServicesBaseEndpoint/$serviceId/reviews';
    final Map<String, dynamic> queryParams = {
      'page': page,
      'size': size,
    };
    if (sortBy != null) {
      queryParams['sortBy'] = sortBy;
    }
    if (sortDir != null) {
      // API 문서에 filterDir로 되어있다면 아래와 같이 수정 필요 (현재는 sortDir로 가정)
      // queryParams['filterDir'] = sortDir;
      queryParams['sortDir'] = sortDir; // 만약 API 스펙이 sortDir이라면 이대로 유지
    }

    if (kDebugMode) {
      // 디버그 모드에서만 실행: 실제 요청될 API 엔드포인트 및 쿼리 파라미터 로깅
      print('[리뷰 목록 조회 요청] API 엔드포인트: $endpoint');
      print('[리뷰 목록 조회 요청] 쿼리 파라미터: $queryParams');
    }

    try {
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParams,
      );

      if (kDebugMode) {
        // 디버그 모드에서만 실행: API 응답 상태 코드 및 데이터 로깅
        print('[리뷰 목록 조회 응답] 상태 코드: ${response.statusCode}');
        print('[리뷰 목록 조회 응답] 데이터: ${response.data}');
      }

      if (response.statusCode == 200 &&
          response.data != null &&
          response.data['body'] != null) {
        // 성공적으로 데이터를 받아와 PagedResponseDto 객체로 변환하여 반환
        return PagedResponseDto.fromJson(
          response.data['body'] as Map<String, dynamic>,
          (json) => ReviewDto.fromJson(json as Map<String, dynamic>),
        );
      } else {
        // 예상치 못한 응답 코드 또는 데이터 형식일 경우 에러 처리
        String serverMsg = response.data?['msg'] ?? '알 수 없는 서버 오류 메시지';
        if (kDebugMode) {
          print(
              '[리뷰 목록 조회 실패] 서버 메시지: $serverMsg, 응답 코드: ${response.statusCode}');
        }
        throw Exception(
            '리뷰 목록 조회에 실패: $serverMsg (코드: ${response.statusCode})');
      }
    } on DioException catch (e) {
      // Dio 관련 예외 발생 시
      if (kDebugMode) {
        print('----------------------------------------------------');
        print('[리뷰 목록 조회 DioException 발생] 서비스 ID: $serviceId');
        print('[리뷰 목록 조회 DioException] 요청 경로: ${e.requestOptions.path}');
        print('[리뷰 목록 조회 DioException] 에러 타입: ${e.type}');
        print('[리뷰 목록 조회 DioException] 에러 메시지: ${e.message}');
        if (e.response != null) {
          print('[리뷰 목록 조회 DioException] 응답 상태 코드: ${e.response?.statusCode}');
          print('[리뷰 목록 조회 DioException] 응답 데이터: ${e.response?.data}');
        } else {
          print('[리뷰 목록 조회 DioException] 응답 객체가 없습니다 (네트워크 연결 문제 등).');
        }
        print('----------------------------------------------------');
      }
      // UI에 표시될 일반적인 에러 메시지
      throw Exception('리뷰 목록 조회 중 오류가 발생했습니다.');
    } catch (e) {
      // 기타 예외 발생 시
      if (kDebugMode) {
        print('----------------------------------------------------');
        print('[리뷰 목록 조회 일반 Exception 발생] 서비스 ID: $serviceId, 에러: $e');
        print('----------------------------------------------------');
      }
      // UI에 표시될 일반적인 에러 메시지
      throw Exception('리뷰 목록 조회 중 알 수 없는 오류가 발생했습니다.');
    }
  }
}
