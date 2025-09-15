import 'dart:io';
import 'package:dio/dio.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/dtos/payment/payment_dto.dart';
import '../data/dtos/payment/payment_requenst_dto.dart';
import '../data/dtos/payment/payment_response_dto.dart';

class PaymentService {
  final Dio _dio;

  PaymentService(this._dio);

  // 결제 준비 API 호출
  Future<PaymentReadyResponseDto> paymentReady(int bookingInfoId) async {
    try {
      final request = PaymentReadyRequestDto(bookingInfoId: bookingInfoId);

      final response = await _dio.post(
        '/api/payment/ready',
        data: request.toJson(),
      );

      return PaymentReadyResponseDto.fromJson(response.data);
    } catch (e) {
      throw Exception('결제 준비 요청 실패: $e');
    }
  }

  // 결제 화면 열기 (카카오페이)
  Future<void> openPaymentPage(PaymentReadyResponseDto paymentReady) async {
    String paymentUrl;

    // 플랫폼별 URL 선택
    if (Platform.isAndroid) {
      paymentUrl = paymentReady.nextRedirectMobileUrl;
    } else if (Platform.isIOS) {
      paymentUrl = paymentReady.nextRedirectMobileUrl;
    } else {
      paymentUrl = paymentReady.nextRedirectPcUrl;
    }

    final uri = Uri.parse(paymentUrl);

    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } else {
      throw Exception('결제 페이지를 열 수 없습니다');
    }
  }

  // 사용자의 결제 내역 조회
  Future<List<PaymentDto>> getUserPayments() async {
    try {
      final response = await _dio.get('/api/payment/user/payments');

      // 백엔드 응답 구조에 맞춰 수정
      final responseData = response.data;

      // 응답이 리스트인 경우
      if (responseData is List) {
        return responseData.map((json) => PaymentDto.fromJson(json)).toList();
      }

      // 응답이 객체이고 data 필드가 있는 경우
      if (responseData is Map<String, dynamic> &&
          responseData['data'] != null) {
        final List<dynamic> paymentList = responseData['data'];
        return paymentList.map((json) => PaymentDto.fromJson(json)).toList();
      }

      // 그 외의 경우 빈 리스트 반환
      return [];
    } catch (e) {
      throw Exception('결제 내역 조회 실패: $e');
    }
  }
}
