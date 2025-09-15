import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/payment.dart';
import '../../../data/dtos/payment/payment_dto.dart';
import '../../../data/dtos/payment/payment_response_dto.dart';
import '../../../service/payment_service.dart';
import '../core/dio_provider.dart';

// State 클래스
class PaymentState {
  final List<Payment> payments;
  final bool isLoading;
  final String? errorMessage;
  final PaymentReadyResponseDto? currentPaymentReady;

  const PaymentState({
    this.payments = const [],
    this.isLoading = false,
    this.errorMessage,
    this.currentPaymentReady,
  });

  PaymentState copyWith({
    List<Payment>? payments,
    bool? isLoading,
    String? errorMessage,
    PaymentReadyResponseDto? currentPaymentReady,
    bool clearErrorMessage = false,
  }) {
    return PaymentState(
      payments: payments ?? this.payments,
      isLoading: isLoading ?? this.isLoading,
      errorMessage:
          clearErrorMessage ? null : errorMessage ?? this.errorMessage,
      currentPaymentReady: currentPaymentReady ?? this.currentPaymentReady,
    );
  }
}

// Notifier 클래스
class PaymentNotifier extends StateNotifier<PaymentState> {
  final PaymentService _paymentService;

  PaymentNotifier(this._paymentService) : super(const PaymentState());

  // 결제 시작
  Future<void> startPayment(int bookingInfoId) async {
    try {
      state = state.copyWith(isLoading: true, clearErrorMessage: true);

      // 1. 결제 준비 API 호출
      final paymentReady = await _paymentService.paymentReady(bookingInfoId);

      // 2. 상태 업데이트
      state = state.copyWith(
        currentPaymentReady: paymentReady,
        isLoading: false,
      );

      // 3. 결제 페이지 열기
      await _paymentService.openPaymentPage(paymentReady);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  // 결제 내역 조회
  Future<void> loadPayments() async {
    try {
      state = state.copyWith(isLoading: true, clearErrorMessage: true);

      final paymentDtos = await _paymentService.getUserPayments();
      final payments = paymentDtos.map((dto) => dto.toModel()).toList();

      state = state.copyWith(
        payments: payments,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '결제 내역을 불러오는데 실패했습니다.',
      );
    }
  }

  Future<void> refresh() async {
    await loadPayments();
  }
}

// Provider
final paymentProvider =
    StateNotifierProvider<PaymentNotifier, PaymentState>((ref) {
  final dio = ref.watch(dioProvider);
  final paymentService = PaymentService(dio);
  return PaymentNotifier(paymentService);
});
