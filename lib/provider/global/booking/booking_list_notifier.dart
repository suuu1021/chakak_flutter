import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/payment.dart';
import '../../../data/models/repositories/payment_repository.dart';
import '../../auth/session_provider.dart';

/// PaymentRepository Provider
final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  final repository = PaymentRepository();
  repository.init();

  // 세션에서 JWT 토큰 가져와서 설정
  final session = ref.watch(sessionProvider);
  if (session.isLogin && session.jwtToken != null) {
    repository.setAuthToken(session.jwtToken);
  }

  // 콜백 함수 설정
  repository.onAuthRequired = () {
    print('로그인이 필요합니다');
    // TODO: 로그인 화면으로 이동
  };

  repository.onNetworkError = (error) {
    print('네트워크 오류: $error');
  };

  return repository;
});

/// 결제 내역 상태 모델
class PaymentListState {
  final List<Payment> payments;
  final bool isLoading;
  final String? errorMessage;
  final bool hasMoreData;
  final int currentPage;

  const PaymentListState({
    required this.payments,
    required this.isLoading,
    this.errorMessage,
    this.hasMoreData = true,
    this.currentPage = 0,
  });

  /// 초기 상태
  factory PaymentListState.initial() {
    return const PaymentListState(
      payments: [],
      isLoading: false,
      hasMoreData: true,
      currentPage: 0,
    );
  }

  /// 로딩 상태
  PaymentListState loading() {
    return copyWith(isLoading: true, errorMessage: null);
  }

  /// 성공 상태
  PaymentListState success(List<Payment> payments, {bool hasMoreData = true}) {
    return copyWith(
      payments: payments,
      isLoading: false,
      errorMessage: null,
      hasMoreData: hasMoreData,
    );
  }

  /// 에러 상태
  PaymentListState error(String message) {
    return copyWith(
      isLoading: false,
      errorMessage: message,
    );
  }

  /// copyWith 메서드
  PaymentListState copyWith({
    List<Payment>? payments,
    bool? isLoading,
    String? errorMessage,
    bool? hasMoreData,
    int? currentPage,
  }) {
    return PaymentListState(
      payments: payments ?? this.payments,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      hasMoreData: hasMoreData ?? this.hasMoreData,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

/// 결제 내역 목록 Notifier
class PaymentListNotifier extends StateNotifier<PaymentListState> {
  final PaymentRepository _repository;

  PaymentListNotifier(this._repository) : super(PaymentListState.initial()) {
    _initializeRepository();
    loadPayments();
  }

  void _initializeRepository() {
    _repository.onAuthRequired = () {
      state = state.error('로그인이 필요합니다');
    };

    _repository.onNetworkError = (error) {
      state = state.error(error);
    };
  }

  /// 결제 내역 조회
  Future<void> loadPayments({bool isRefresh = false}) async {
    if (isRefresh) {
      state = PaymentListState.initial().loading();
    } else {
      state = state.loading();
    }

    try {
      final dtoList = await _repository.getUserPayments(page: 0, size: 20);
      final payments = dtoList.map((dto) => dto.toModel()).toList();

      state = state.success(payments, hasMoreData: payments.length >= 20);
    } catch (e) {
      state = state.error(e.toString());
    }
  }

  /// 새로고침
  Future<void> refresh() async {
    await loadPayments(isRefresh: true);
  }

  /// 더 많은 데이터 로드 (페이지네이션)
  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMoreData) return;

    try {
      final nextPage = state.currentPage + 1;
      final dtoList =
          await _repository.getUserPayments(page: nextPage, size: 20);
      final newPayments = dtoList.map((dto) => dto.toModel()).toList();

      final allPayments = [...state.payments, ...newPayments];

      state = state.copyWith(
        payments: allPayments,
        currentPage: nextPage,
        hasMoreData: newPayments.length >= 20,
      );
    } catch (e) {
      state = state.error('추가 데이터 로드 실패: $e');
    }
  }

  @override
  void dispose() {
    _repository.dispose();
    super.dispose();
  }
}

/// 결제 내역 목록 Provider
final paymentListProvider =
    StateNotifierProvider<PaymentListNotifier, PaymentListState>((ref) {
  final repository = ref.watch(paymentRepositoryProvider);
  return PaymentListNotifier(repository);
});
