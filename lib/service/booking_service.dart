import 'package:dio/dio.dart';
import '../data/dtos/booking/booking_dto.dart';
import '../data/dtos/booking/booking_request_dto.dart';

class BookingService {
  final Dio _dio;

  BookingService(this._dio);

  // 응답 데이터 추출 헬퍼 메서드
  T _extractResponseData<T>(Response response, T Function(dynamic) parser) {
    final responseData = response.data;

    // 응답이 객체이고 data 필드가 있는 경우
    if (responseData is Map<String, dynamic> &&
        responseData.containsKey('data')) {
      return parser(responseData['data']);
    }

    // 직접 데이터인 경우
    return parser(responseData);
  }

  // 사용자의 예약 목록 조회
  Future<List<BookingDto>> getUserBookings() async {
    try {
      final response = await _dio.get('/api/booking/user/bookings');

      return _extractResponseData<List<BookingDto>>(
        response,
        (data) {
          if (data is List) {
            return data.map((json) => BookingDto.fromJson(json)).toList();
          }
          return <BookingDto>[];
        },
      );
    } on DioException catch (e) {
      throw Exception('예약 목록 조회 실패: ${e.message ?? e.toString()}');
    } catch (e) {
      throw Exception('예약 목록 조회 실패: $e');
    }
  }

  // 새 예약 생성
  Future<BookingDto> createBooking(BookingCreateRequestDto request) async {
    try {
      final response = await _dio.post(
        '/api/booking/create',
        data: request.toJson(),
      );

      return _extractResponseData<BookingDto>(
        response,
        (data) => BookingDto.fromJson(data),
      );
    } on DioException catch (e) {
      throw Exception('예약 생성 실패: ${e.message ?? e.toString()}');
    } catch (e) {
      throw Exception('예약 생성 실패: $e');
    }
  }

  // 예약 수정
  Future<BookingDto> updateBooking(
      int bookingInfoId, BookingUpdateRequestDto request) async {
    try {
      final response = await _dio.put(
        '/api/booking/$bookingInfoId',
        data: request.toJson(),
      );

      return _extractResponseData<BookingDto>(
        response,
        (data) => BookingDto.fromJson(data),
      );
    } on DioException catch (e) {
      throw Exception('예약 수정 실패: ${e.message ?? e.toString()}');
    } catch (e) {
      throw Exception('예약 수정 실패: $e');
    }
  }

  // 예약 취소
  Future<void> cancelBooking(int bookingInfoId) async {
    try {
      await _dio.put('/api/booking/$bookingInfoId/cancel');
    } on DioException catch (e) {
      throw Exception('예약 취소 실패: ${e.message ?? e.toString()}');
    } catch (e) {
      throw Exception('예약 취소 실패: $e');
    }
  }

  // 특정 예약 상세 조회
  Future<BookingDto> getBooking(int bookingInfoId) async {
    try {
      final response = await _dio.get('/api/booking/$bookingInfoId');

      return _extractResponseData<BookingDto>(
        response,
        (data) => BookingDto.fromJson(data),
      );
    } on DioException catch (e) {
      throw Exception('예약 상세 조회 실패: ${e.message ?? e.toString()}');
    } catch (e) {
      throw Exception('예약 상세 조회 실패: $e');
    }
  }
}
