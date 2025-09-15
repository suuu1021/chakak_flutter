// features/booking/data/dto/booking_detail_dto.dart

/// 예약 상세 응답 DTO
class BookingDetailDto {
  final String photographerProfileId;
  final String userProfileId;
  final String bookingDate;
  final String bookingTime;

  BookingDetailDto({
    required this.photographerProfileId,
    required this.userProfileId,
    required this.bookingDate,
    required this.bookingTime,
  });

  /// 서버 응답 JSON에서 DTO 생성
  factory BookingDetailDto.fromJson(Map<String, dynamic> json) {
    return BookingDetailDto(
      photographerProfileId: json['photographerProfileId']?.toString() ?? '',
      userProfileId: json['userProfileId']?.toString() ?? '',
      bookingDate: json['bookingDate'] as String? ?? '',
      bookingTime: json['bookingTime'] as String? ?? '',
    );
  }

  /// 서버 전송용 JSON 변환
  Map<String, dynamic> toJson() {
    return {
      'photographerProfileId': photographerProfileId,
      'userProfileId': userProfileId,
      'bookingDate': bookingDate,
      'bookingTime': bookingTime,
    };
  }

  @override
  String toString() {
    return 'BookingDetailDto('
        'photographerProfileId: $photographerProfileId, '
        'userProfileId: $userProfileId, '
        'bookingDate: $bookingDate, '
        'bookingTime: $bookingTime'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BookingDetailDto &&
        other.photographerProfileId == photographerProfileId &&
        other.userProfileId == userProfileId &&
        other.bookingDate == bookingDate &&
        other.bookingTime == bookingTime;
  }

  @override
  int get hashCode {
    return Object.hash(
      photographerProfileId,
      userProfileId,
      bookingDate,
      bookingTime,
    );
  }
}
