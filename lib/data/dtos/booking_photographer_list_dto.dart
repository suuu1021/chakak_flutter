// features/booking/data/dto/booking_photographer_list_dto.dart

/// 포토그래퍼 예약 목록 응답 DTO
class BookingPhotographerListDto {
  final String userProfileId;
  final String bookingDate;
  final String bookingTime;

  BookingPhotographerListDto({
    required this.userProfileId,
    required this.bookingDate,
    required this.bookingTime,
  });

  /// 서버 응답 JSON에서 DTO 생성
  factory BookingPhotographerListDto.fromJson(Map<String, dynamic> json) {
    return BookingPhotographerListDto(
      userProfileId: json['userProfileId']?.toString() ?? '',
      bookingDate: json['bookingDate'] as String? ?? '',
      bookingTime: json['bookingTime'] as String? ?? '',
    );
  }

  /// 서버 전송용 JSON 변환
  Map<String, dynamic> toJson() {
    return {
      'userProfileId': userProfileId,
      'bookingDate': bookingDate,
      'bookingTime': bookingTime,
    };
  }

  @override
  String toString() {
    return 'BookingPhotographerListDto('
        'userProfileId: $userProfileId, '
        'bookingDate: $bookingDate, '
        'bookingTime: $bookingTime'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BookingPhotographerListDto &&
        other.userProfileId == userProfileId &&
        other.bookingDate == bookingDate &&
        other.bookingTime == bookingTime;
  }

  @override
  int get hashCode {
    return Object.hash(
      userProfileId,
      bookingDate,
      bookingTime,
    );
  }
}
