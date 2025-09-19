// lib/data/models/booking/booking_model.dart

import 'package:chakak_flutter/data/models/booking/booking_list_item.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum BookingStatus {
  // 백엔드와 일치하도록 상태 설명 수정
  PENDING(
    description: '예약대기',
    nextStatus: [BookingStatus.CONFIRMED, BookingStatus.CANCELED],
  ),
  CONFIRMED(
    description: '예약확정', // '결제완료'에서 '예약확정'으로 수정
    nextStatus: [BookingStatus.COMPLETED],
  ),
  COMPLETED(
    description: '촬영완료',
    nextStatus: [BookingStatus.REVIEWED],
  ),
  REVIEWED(
    description: '리뷰작성완료', // 백엔드와 일치하도록 수정
    nextStatus: [],
  ),
  CANCELED(
    description: '예약취소',
    nextStatus: [],
  );

  final String description;
  final List<BookingStatus> nextStatus;

  const BookingStatus({
    required this.description,
    required this.nextStatus,
  });

  /// 서버에서 받은 문자열(e.g., "PENDING")을 Enum으로 변환
  static BookingStatus fromString(String? value) {
    if (value == null) return BookingStatus.PENDING;

    return BookingStatus.values.firstWhere(
      (e) => e.name.toUpperCase() == value.toUpperCase(),
      orElse: () => BookingStatus.PENDING,
    );
  }

  /// 현재 상태에서 특정 상태로 변경이 가능한지 확인
  bool canChangeTo(BookingStatus nextStatusToChange) {
    return nextStatus.contains(nextStatusToChange);
  }

  /// 사용자 카드에 표시될 버튼/액션 텍스트
  String get userActionText {
    switch (this) {
      case BookingStatus.PENDING:
        return '예약 대기중';
      case BookingStatus.CONFIRMED:
        return '촬영 예정';
      case BookingStatus.COMPLETED:
        return '리뷰 작성';
      case BookingStatus.REVIEWED:
        return '내 리뷰 보기';
      case BookingStatus.CANCELED:
        return '취소된 예약';
    }
  }

  /// 포토그래퍼 카드에 표시될 버튼/액션 텍스트
  String get photographerActionText {
    switch (this) {
      case BookingStatus.PENDING:
        return '예약 승인';
      case BookingStatus.CONFIRMED:
        return '촬영 예정';
      case BookingStatus.COMPLETED:
        return '촬영 완료됨';
      case BookingStatus.REVIEWED:
        return '리뷰 확인';
      case BookingStatus.CANCELED:
        return '취소된 예약';
    }
  }

  /// 상태별 색상
  Color get statusColor {
    switch (this) {
      case BookingStatus.PENDING:
        return const Color(0xFFFF9800); // 주황색
      case BookingStatus.CONFIRMED:
        return const Color(0xFF4CAF50); // 초록색
      case BookingStatus.COMPLETED:
        return const Color(0xFF2196F3); // 파란색
      case BookingStatus.REVIEWED:
        return const Color(0xFF9C27B0); // 보라색
      case BookingStatus.CANCELED:
        return const Color(0xFFF44336); // 빨간색
    }
  }
}

/// 예약 목록 화면의 상태를 관리하는 모델
class BookingListState {
  final List<BookingListItem> bookings;
  final bool isLoading;
  final String? errorMessage;
  final BookingStatus? selectedFilter;

  const BookingListState({
    this.bookings = const [],
    this.isLoading = false,
    this.errorMessage,
    this.selectedFilter,
  });

  factory BookingListState.initial() => const BookingListState();

  int get totalCount => bookings.length;

  int getCountByStatus(BookingStatus status) {
    return bookings.where((booking) => booking.status == status).length;
  }

  BookingListState copyWith({
    List<BookingListItem>? bookings,
    bool? isLoading,
    String? errorMessage,
    BookingStatus? selectedFilter,
    bool forceErrorMessageNull = false,
  }) {
    return BookingListState(
      bookings: bookings ?? this.bookings,
      isLoading: isLoading ?? this.isLoading,
      errorMessage:
          forceErrorMessageNull ? null : errorMessage ?? this.errorMessage,
      selectedFilter: selectedFilter, // selectedFilter는 null이 될 수 있으므로 그대로 전달
    );
  }
}
