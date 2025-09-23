import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/booking/booking_model.dart';
import '../../../data/dtos/booking/booking_request_dto.dart';
import '../../../data/models/repositories/booking_repository.dart';
import '../../auth/session_provider.dart';
import '../../../data/dtos/booking/booking_dto.dart';
import '../../../data/models/booking/booking_list_item.dart';

final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  final repository = BookingRepository();
  repository.init();

  // 세션에서 JWT 토큰 가져와서 설정
  final session = ref.watch(sessionProvider);
  if (session.isLogin && session.jwtToken != null) {
    repository.setAuthToken(session.jwtToken);
  }

  return repository;
});

class BookingListNotifier extends Notifier<BookingListState> {
  late BookingRepository _repository;

  @override
  BookingListState build() {
    _repository = ref.watch(bookingRepositoryProvider);
    return BookingListState.initial();
  }

  /// 내 예약 목록 로드 (userType에 따라 자동 분기)
  Future<void> loadMyBookings() async {
    print('=== loadMyBookings 시작 ==='); // 디버깅용

    final session = ref.read(sessionProvider);

    if (!session.isLogin || session.userId == null) {
      print(
          '로그인 상태 확인 실패 - isLogin: ${session.isLogin}, userId: ${session.userId}');
      state = state.copyWith(errorMessage: '로그인이 필요합니다', isLoading: false);
      return;
    }

    state = state.copyWith(isLoading: true, forceErrorMessageNull: true);

    try {
      final userType = session.userTypeCode; // "user" or "photographer"
      final userId = session.userId!;

      print('사용자 정보 - userType: $userType, userId: $userId');

      List<BookingListItem> bookings = [];

      if (userType == "user") {
        print('사용자 예약 목록 조회 중...');
        final dtoList = await _repository.getUserBookingList(userId);
        print('서버에서 받은 데이터 개수: ${dtoList.length}');

        // BookingMapper.toUserBookingListItem을 사용하여 변환
        bookings = dtoList
            .map((dto) => BookingMapper.toUserBookingListItem(dto,
                photographerUserId: userId)) // userId 전달
            .toList();
      } else if (userType == "photographer") {
        print('포토그래퍼 예약 목록 조회 중...');
        final dtoList = await _repository.getPhotographerBookingList(userId);
        print('서버에서 받은 데이터 개수: ${dtoList.length}');

        // BookingMapper.toPhotographerBookingListItem을 사용하여 변환
        bookings = dtoList
            .map((dto) => BookingMapper.toPhotographerBookingListItem(dto,
                photographerUserId: userId)) // userId 전달
            .toList();
      } else {
        print('잘못된 사용자 타입: $userType');
        state = state.copyWith(
            errorMessage: '잘못된 사용자 타입입니다: $userType', isLoading: false);
        return;
      }

      print('변환된 예약 목록 개수: ${bookings.length}');
      state = state.copyWith(bookings: bookings, isLoading: false);
    } catch (e) {
      print('예약 목록 로드 중 오류 발생: $e');
      state = state.copyWith(errorMessage: '예약 목록 로드 실패: $e', isLoading: false);
    }
  }

  /// 예약 취소 (사용자만 가능)
  Future<void> cancelBooking(int bookingInfoId) async {
    final session = ref.read(sessionProvider);

    if (session.userTypeCode != "user") {
      state = state.copyWith(errorMessage: '사용자만 예약을 취소할 수 있습니다');
      return;
    }

    try {
      await _repository.cancelBooking(bookingInfoId);

      // 취소된 예약의 상태를 CANCELED로 업데이트
      final updatedBookings = state.bookings.map((booking) {
        if (booking.bookingInfoId == bookingInfoId) {
          return booking.copyWith(status: BookingStatus.CANCELED);
        }
        return booking;
      }).toList();

      state = state.copyWith(bookings: updatedBookings);
    } catch (e) {
      state = state.copyWith(errorMessage: '예약 취소 실패: $e');
    }
  }

  /// 결제완료 확인 (포토그래퍼만 가능)
  Future<void> confirmBooking(int bookingInfoId) async {
    final session = ref.read(sessionProvider);

    if (session.userTypeCode != "photographer") {
      state = state.copyWith(errorMessage: '포토그래퍼만 결제확인을 할 수 있습니다');
      return;
    }

    try {
      await _repository.confirmBooking(bookingInfoId);

      final updatedBookings = state.bookings.map((booking) {
        if (booking.bookingInfoId == bookingInfoId) {
          return booking.copyWith(status: BookingStatus.CONFIRMED);
        }
        return booking;
      }).toList();

      state = state.copyWith(bookings: updatedBookings);
    } catch (e) {
      state = state.copyWith(errorMessage: '결제확인 실패: $e');
    }
  }

  /// 촬영완료 처리 (포토그래퍼만 가능)
  Future<void> completeBooking(int bookingInfoId) async {
    final session = ref.read(sessionProvider);

    if (session.userTypeCode != "photographer") {
      state = state.copyWith(errorMessage: '포토그래퍼만 촬영완료 처리를 할 수 있습니다');
      return;
    }

    try {
      await _repository.completeBooking(bookingInfoId);

      final updatedBookings = state.bookings.map((booking) {
        if (booking.bookingInfoId == bookingInfoId) {
          return booking.copyWith(status: BookingStatus.COMPLETED);
        }
        return booking;
      }).toList();

      state = state.copyWith(bookings: updatedBookings);
    } catch (e) {
      state = state.copyWith(errorMessage: '촬영완료 처리 실패: $e');
    }
  }

  /// 새로고침
  Future<void> refresh() async {
    await loadMyBookings();
  }

  /// 상태별 필터링
  void setFilter(BookingStatus? filter) {
    state = state.copyWith(selectedFilter: filter);
  }

  /// 에러 초기화
  void clearError() {
    state = state.copyWith(forceErrorMessageNull: true);
  }
}

/// 예약 생성 상태
class BookingCreateState {
  final bool isLoading;
  final String? error;

  BookingCreateState({
    this.isLoading = false,
    this.error,
  });

  BookingCreateState copyWith({
    bool? isLoading,
    String? error,
  }) {
    return BookingCreateState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// 예약 생성 Notifier
class BookingCreateNotifier extends Notifier<BookingCreateState> {
  late BookingRepository _repository;

  @override
  BookingCreateState build() {
    _repository = ref.watch(bookingRepositoryProvider);
    return BookingCreateState();
  }

  /// 예약 생성
  Future<bool> createBooking(BookingCreateRequestDto request) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _repository.createBooking(request);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  /// 에러 초기화
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Provider 등록
final bookingListProvider =
    NotifierProvider<BookingListNotifier, BookingListState>(() {
  return BookingListNotifier();
});

final bookingCreateProvider =
    NotifierProvider<BookingCreateNotifier, BookingCreateState>(() {
  return BookingCreateNotifier();
});
