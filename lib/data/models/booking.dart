import 'package:flutter/material.dart';

class Booking {
  final int bookingInfoId;
  final int userProfileId;
  final int photographerProfileId;
  final int photoServiceInfoId;
  final int priceInfoId;
  final String bookingDate;
  final String? specialRequests;
  final BookingStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  // 추가 정보 (조인된 데이터)
  final String? photographerName;
  final String? serviceName;
  final int? price;

  const Booking({
    required this.bookingInfoId,
    required this.userProfileId,
    required this.photographerProfileId,
    required this.photoServiceInfoId,
    required this.priceInfoId,
    required this.bookingDate,
    this.specialRequests,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.photographerName,
    this.serviceName,
    this.price,
  });

  Booking copyWith({
    int? bookingInfoId,
    int? userProfileId,
    int? photographerProfileId,
    int? photoServiceInfoId,
    int? priceInfoId,
    String? bookingDate,
    String? specialRequests,
    BookingStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? photographerName,
    String? serviceName,
    int? price,
  }) {
    return Booking(
      bookingInfoId: bookingInfoId ?? this.bookingInfoId,
      userProfileId: userProfileId ?? this.userProfileId,
      photographerProfileId:
          photographerProfileId ?? this.photographerProfileId,
      photoServiceInfoId: photoServiceInfoId ?? this.photoServiceInfoId,
      priceInfoId: priceInfoId ?? this.priceInfoId,
      bookingDate: bookingDate ?? this.bookingDate,
      specialRequests: specialRequests ?? this.specialRequests,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      photographerName: photographerName ?? this.photographerName,
      serviceName: serviceName ?? this.serviceName,
      price: price ?? this.price,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Booking && other.bookingInfoId == bookingInfoId;
  }

  @override
  int get hashCode => bookingInfoId.hashCode;

  // 편의 메서드들
  String get formattedPrice => price != null
      ? '₩${price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}'
      : '가격 정보 없음';

  String get formattedBookingDate {
    try {
      final date = DateTime.parse(bookingDate);
      return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return bookingDate;
    }
  }

  bool get isConfirmed => status == BookingStatus.confirmed;
  bool get isPending => status == BookingStatus.pending;
  bool get isCompleted => status == BookingStatus.completed;
  bool get isCancelled => status == BookingStatus.cancelled;
}

enum BookingStatus {
  pending,
  confirmed,
  completed,
  cancelled;

  String get displayName {
    switch (this) {
      case BookingStatus.pending:
        return '예약대기';
      case BookingStatus.confirmed:
        return '예약확정';
      case BookingStatus.completed:
        return '촬영완료';
      case BookingStatus.cancelled:
        return '예약취소';
    }
  }

  Color get color {
    switch (this) {
      case BookingStatus.pending:
        return Colors.orange;
      case BookingStatus.confirmed:
        return Colors.blue;
      case BookingStatus.completed:
        return Colors.green;
      case BookingStatus.cancelled:
        return Colors.red;
    }
  }
}
