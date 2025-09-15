import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/dtos/booking/booking_request_dto.dart';
import '../../data/models/booking.dart';
import '../../service/booking_service.dart';
import '../core/dio_provider.dart';

// State 클래스
class BookingState {
  final List<Booking> bookings;
  final bool isLoading;
  final String? errorMessage;
  final Booking? selectedBooking;

  const BookingState({
    this.bookings = const [],
    this.isLoading = false,
    this.errorMessage,
    this.selectedBooking,
  });

  BookingState copyWith({
    List<Booking>? bookings,
    bool? isLoading,
    String? errorMessage,
    Booking? selectedBooking,
    bool clearErrorMessage = false,
  }) {
    return BookingState(
      bookings: bookings ?? this.bookings,
      isLoading: isLoading ?? this.isLoading,
      errorMessage:
          clearErrorMessage ? null : errorMessage ?? this.errorMessage,
      selectedBooking: selectedBooking ?? this.selectedBooking,
    );
  }
}

// Notifier 클래스
class BookingNotifier extends StateNotifier<BookingState> {
  final BookingService _bookingService;

  BookingNotifier(this._bookingService) : super(const BookingState());

  // 예약 목록 로드
  Future<void> loadBookings() async {
    try {
      state = state.copyWith(isLoading: true, clearErrorMessage: true);

      final bookingDtos = await _bookingService.getUserBookings();
      final bookings = bookingDtos.map((dto) => dto.toModel()).toList();

      state = state.copyWith(
        bookings: bookings,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '예약 목록을 불러오는데 실패했습니다.',
      );
    }
  }

  // 새 예약 생성
  Future<bool> createBooking({
    required int photographerProfileId,
    required int photoServiceInfoId,
    required int priceInfoId,
    required String bookingDate,
    String? specialRequests,
  }) async {
    try {
      state = state.copyWith(isLoading: true, clearErrorMessage: true);

      final request = BookingCreateRequestDto(
        photographerProfileId: photographerProfileId,
        photoServiceInfoId: photoServiceInfoId,
        priceInfoId: priceInfoId,
        bookingDate: bookingDate,
        specialRequests: specialRequests,
      );

      await _bookingService.createBooking(request);

      // 예약 목록 새로고침
      await loadBookings();

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '예약 생성에 실패했습니다.',
      );
      return false;
    }
  }

  // 예약 취소
  Future<bool> cancelBooking(int bookingInfoId) async {
    try {
      state = state.copyWith(isLoading: true, clearErrorMessage: true);

      await _bookingService.cancelBooking(bookingInfoId);

      // 예약 목록 새로고침
      await loadBookings();

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '예약 취소에 실패했습니다.',
      );
      return false;
    }
  }

  // 예약 상세 조회
  Future<void> loadBookingDetail(int bookingInfoId) async {
    try {
      state = state.copyWith(isLoading: true, clearErrorMessage: true);

      final bookingDto = await _bookingService.getBooking(
          bookingInfoId); // getBooking 메서드가 BookingService에 있는지 확인 필요
      final booking = bookingDto.toModel();

      state = state.copyWith(
        selectedBooking: booking,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '예약 상세 정보를 불러오는데 실패했습니다.',
      );
    }
  }

  Future<void> refresh() async {
    await loadBookings();
  }
}

// Provider
final bookingProvider =
    StateNotifierProvider<BookingNotifier, BookingState>((ref) {
  final dio = ref.watch(dioProvider);
  final bookingService = BookingService(dio);
  return BookingNotifier(bookingService);
});
