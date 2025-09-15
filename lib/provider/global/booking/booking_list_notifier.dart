// features/booking/presentation/notifier/booking_list_notifier.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/dtos/booking_user_list_dto.dart';
import '../../../data/models/booking_model.dart';
import '../../../data/models/repositories/booking_repository.dart';

/// BookingRepository Provider
final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  final repository = BookingRepository();
  repository.init();

  // 콜백 함수 설정
  repository.onAuthRequired = () {
    // TODO: 로그인 화면으로 이동
    print('로그인이 필요합니다');
  };

  repository.onNetworkError = (error) {
    print('네트워크 오류: $error');
  };

  repository.onBookingCreated = () {
    print('예약이 생성되었습니다');
  };

  repository.onBookingCanceled = () {
    print('예약이 취소되었습니다');
  };

  return repository;
});

/// 사용자 예약 목록 Notifier
class UserBookingListNotifier extends StateNotifier<BookingListState> {
  final BookingRepository _repository;
  final int _userId;

  UserBookingListNotifier(this._repository, this._userId)
      : super(BookingListState.initial()) {
    _initializeRepository();
    loadBookings();
  }

  /// Repository 콜백 초기화
  void _initializeRepository() {
    _repository.onAuthRequired = () {
      state = state.error('로그인이 필요합니다');
    };

    _repository.onNetworkError = (error) {
      state = state.error(error);
    };
  }

  /// 예약 목록 조회
  Future<void> loadBookings() async {
    state = state.loading();

    try {
      final dtoList = await _repository.getUserBookingList(_userId);
      final bookings = _convertDtoListToModels(dtoList);
      state = state.success(bookings);
    } catch (e) {
      state = state.error(e.toString());
    }
  }

  /// DTO List를 Model List로 변환
  List<BookingListItem> _convertDtoListToModels(
      List<BookingUserListDto> dtoList) {
    return dtoList.map((dto) {
      final dateTime = DateTime.parse('${dto.bookingDate}T${dto.bookingTime}');
      return BookingListItem(
        photographerProfileId: int.tryParse(dto.photographerProfileId) ?? 0,
        bookingDateTime: dateTime,
        status: BookingStatus.pending, // 임시로 고정
        photographerName: '작가 ${dto.photographerProfileId}', // 임시 이름
      );
    }).toList();
  }

  /// 새로고침
  Future<void> refresh() async {
    await loadBookings();
  }

  /// 상태 필터 변경
  void setFilter(BookingStatus? filter) {
    state = state.copyWith(selectedFilter: filter);
  }

  /// 필터 초기화
  void clearFilter() {
    state = state.copyWith(selectedFilter: null);
  }

  /// 예약 취소
  Future<void> cancelBooking(int bookingInfoId) async {
    try {
      await _repository.cancelBooking(bookingInfoId);
      // 목록 새로고침
      await loadBookings();
    } catch (e) {
      state = state.error('예약 취소 중 오류가 발생했습니다: $e');
    }
  }

  /// 리소스 해제
  @override
  void dispose() {
    _repository.dispose();
    super.dispose();
  }
}

/// 포토그래퍼 예약 목록 Notifier
class PhotographerBookingListNotifier extends StateNotifier<BookingListState> {
  final BookingRepository _repository;
  final int _userId;

  PhotographerBookingListNotifier(this._repository, this._userId)
      : super(BookingListState.initial()) {
    _initializeRepository();
    loadBookings();
  }

  /// Repository 콜백 초기화
  void _initializeRepository() {
    _repository.onAuthRequired = () {
      state = state.error('로그인이 필요합니다');
    };

    _repository.onNetworkError = (error) {
      state = state.error(error);
    };
  }

  /// 예약 목록 조회
  Future<void> loadBookings() async {
    state = state.loading();

    try {
      final dtoList = await _repository.getPhotographerBookingList(_userId);
      final bookings = _convertDtoListToModels(dtoList);
      state = state.success(bookings);
    } catch (e) {
      state = state.error(e.toString());
    }
  }

  /// DTO List를 Model List로 변환
  List<BookingListItem> _convertDtoListToModels(dtoList) {
    return dtoList.map((dto) {
      final dateTime = DateTime.parse('${dto.bookingDate}T${dto.bookingTime}');
      return BookingListItem(
        photographerProfileId:
            int.tryParse(dto.userProfileId) ?? 0, // 임시로 userProfileId 사용
        bookingDateTime: dateTime,
        status: BookingStatus.pending, // 임시로 고정
        photographerName: '사용자 ${dto.userProfileId}', // 임시 이름
      );
    }).toList();
  }

  /// 새로고침
  Future<void> refresh() async {
    await loadBookings();
  }

  /// 상태 필터 변경
  void setFilter(BookingStatus? filter) {
    state = state.copyWith(selectedFilter: filter);
  }

  /// 예약 승인
  Future<void> confirmBooking(int bookingInfoId) async {
    try {
      await _repository.confirmBooking(bookingInfoId);
      // 목록 새로고침
      await loadBookings();
    } catch (e) {
      state = state.error('예약 승인 중 오류가 발생했습니다: $e');
    }
  }

  /// 예약 거절
  Future<void> rejectBooking(int bookingInfoId) async {
    try {
      await _repository.rejectBooking(bookingInfoId);
      // 목록 새로고침
      await loadBookings();
    } catch (e) {
      state = state.error('예약 거절 중 오류가 발생했습니다: $e');
    }
  }

  /// 촬영 완료 처리
  Future<void> completeBooking(int bookingInfoId) async {
    try {
      await _repository.completeBooking(bookingInfoId);
      // 목록 새로고침
      await loadBookings();
    } catch (e) {
      state = state.error('촬영 완료 처리 중 오류가 발생했습니다: $e');
    }
  }

  /// 리소스 해제
  @override
  void dispose() {
    _repository.dispose();
    super.dispose();
  }
}

/// 사용자 예약 목록 Provider
final userBookingListProvider = StateNotifierProvider.family<
    UserBookingListNotifier, BookingListState, int>((ref, userId) {
  final repository = ref.watch(bookingRepositoryProvider);
  return UserBookingListNotifier(repository, userId);
});

/// 포토그래퍼 예약 목록 Provider
final photographerBookingListProvider = StateNotifierProvider.family<
    PhotographerBookingListNotifier, BookingListState, int>((ref, userId) {
  final repository = ref.watch(bookingRepositoryProvider);
  return PhotographerBookingListNotifier(repository, userId);
});

/// 현재 사용자 ID Provider (임시)
final currentUserIdProvider = Provider<int>((ref) {
  // TODO: 실제 인증 시스템에서 가져오기
  return 1; // 임시 사용자 ID
});

/// 사용자 타입 Provider (사용자 vs 포토그래퍼)
enum UserType { user, photographer }

final currentUserTypeProvider = Provider<UserType>((ref) {
  // TODO: 실제 사용자 정보에서 가져오기
  return UserType.user; // 임시로 일반 사용자
});
