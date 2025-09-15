// features/booking/domain/model/booking_model.dart

/// 예약 상태 열거형
enum BookingStatus {
  pending('예약대기'),
  confirmed('예약승낙'),
  rejected('예약거절'),
  canceled('예약취소'),
  completed('촬영완료'),
  reviewed('리뷰작성완료');

  const BookingStatus(this.description);
  final String description;
}

/// 예약 목록 아이템 모델
class BookingListItem {
  final int photographerProfileId;
  final DateTime bookingDateTime;
  final BookingStatus status;
  final String photographerName;

  const BookingListItem({
    required this.photographerProfileId,
    required this.bookingDateTime,
    required this.status,
    required this.photographerName,
  });

  /// 날짜 포맷팅 (2024년 3월 15일)
  String get formattedDate {
    return '${bookingDateTime.year}년 ${bookingDateTime.month}월 ${bookingDateTime.day}일';
  }

  /// 시간 포맷팅 (오후 2:30)
  String get formattedTime {
    final hour = bookingDateTime.hour;
    final minute = bookingDateTime.minute.toString().padLeft(2, '0');

    if (hour == 0) return '오전 12:$minute';
    if (hour < 12) return '오전 $hour:$minute';
    if (hour == 12) return '오후 12:$minute';
    return '오후 ${hour - 12}:$minute';
  }

  /// 상태별 색상 (Hex 코드)
  String get statusColorHex {
    switch (status) {
      case BookingStatus.pending:
        return '#FF9800'; // 주황색
      case BookingStatus.confirmed:
        return '#4CAF50'; // 초록색
      case BookingStatus.rejected:
      case BookingStatus.canceled:
        return '#F44336'; // 빨간색
      case BookingStatus.completed:
        return '#2196F3'; // 파란색
      case BookingStatus.reviewed:
        return '#9C27B0'; // 보라색
    }
  }

  /// copyWith 메서드
  BookingListItem copyWith({
    int? photographerProfileId,
    DateTime? bookingDateTime,
    BookingStatus? status,
    String? photographerName,
  }) {
    return BookingListItem(
      photographerProfileId:
          photographerProfileId ?? this.photographerProfileId,
      bookingDateTime: bookingDateTime ?? this.bookingDateTime,
      status: status ?? this.status,
      photographerName: photographerName ?? this.photographerName,
    );
  }

  @override
  String toString() {
    return 'BookingListItem('
        'photographerProfileId: $photographerProfileId, '
        'bookingDateTime: $bookingDateTime, '
        'status: $status, '
        'photographerName: $photographerName'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BookingListItem &&
        other.photographerProfileId == photographerProfileId &&
        other.bookingDateTime == bookingDateTime &&
        other.status == status &&
        other.photographerName == photographerName;
  }

  @override
  int get hashCode {
    return Object.hash(
      photographerProfileId,
      bookingDateTime,
      status,
      photographerName,
    );
  }
}

/// 예약 목록 상태 모델
class BookingListState {
  final List<BookingListItem> bookings;
  final bool isLoading;
  final String? errorMessage;
  final BookingStatus? selectedFilter;

  const BookingListState({
    required this.bookings,
    required this.isLoading,
    this.errorMessage,
    this.selectedFilter,
  });

  /// 초기 상태
  factory BookingListState.initial() {
    return const BookingListState(
      bookings: [],
      isLoading: false,
    );
  }

  /// 로딩 상태
  BookingListState loading() {
    return copyWith(isLoading: true, errorMessage: null);
  }

  /// 성공 상태
  BookingListState success(List<BookingListItem> bookings) {
    return copyWith(
      bookings: bookings,
      isLoading: false,
      errorMessage: null,
    );
  }

  /// 에러 상태
  BookingListState error(String message) {
    return copyWith(
      isLoading: false,
      errorMessage: message,
    );
  }

  /// 필터링된 예약 목록
  List<BookingListItem> get filteredBookings {
    if (selectedFilter == null) return bookings;
    return bookings
        .where((booking) => booking.status == selectedFilter)
        .toList();
  }

  /// 상태별 개수 계산
  int getCountByStatus(BookingStatus status) {
    return bookings.where((booking) => booking.status == status).length;
  }

  /// copyWith 메서드
  BookingListState copyWith({
    List<BookingListItem>? bookings,
    bool? isLoading,
    String? errorMessage,
    BookingStatus? selectedFilter,
  }) {
    return BookingListState(
      bookings: bookings ?? this.bookings,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      selectedFilter: selectedFilter ?? this.selectedFilter,
    );
  }

  @override
  String toString() {
    return 'BookingListState('
        'bookings: ${bookings.length} items, '
        'isLoading: $isLoading, '
        'errorMessage: $errorMessage, '
        'selectedFilter: $selectedFilter'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BookingListState &&
        other.bookings == bookings &&
        other.isLoading == isLoading &&
        other.errorMessage == errorMessage &&
        other.selectedFilter == selectedFilter;
  }

  @override
  int get hashCode {
    return Object.hash(
      bookings,
      isLoading,
      errorMessage,
      selectedFilter,
    );
  }
}
