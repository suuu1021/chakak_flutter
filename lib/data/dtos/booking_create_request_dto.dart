// features/booking/data/dto/booking_create_request_dto.dart

/// 예약 생성 요청 DTO
class BookingCreateRequestDto {
  final String photographerProfileId;
  final String photoServiceId;
  final String priceInfoId;
  final String bookingDate;
  final String bookingTime;

  BookingCreateRequestDto({
    required this.photographerProfileId,
    required this.photoServiceId,
    required this.priceInfoId,
    required this.bookingDate,
    required this.bookingTime,
  });

  /// 서버 전송용 JSON 변환
  Map<String, dynamic> toJson() {
    return {
      'photographerProfileId': photographerProfileId,
      'photoServiceId': photoServiceId,
      'priceInfoId': priceInfoId,
      'bookingDate': bookingDate,
      'bookingTime': bookingTime,
    };
  }

  /// 팩토리 생성자 - 개별 매개변수로 생성
  factory BookingCreateRequestDto.create({
    required int photographerProfileId,
    required int photoServiceId,
    required int priceInfoId,
    required DateTime bookingDateTime,
  }) {
    final bookingDate = '${bookingDateTime.year}-'
        '${bookingDateTime.month.toString().padLeft(2, '0')}-'
        '${bookingDateTime.day.toString().padLeft(2, '0')}';

    final bookingTime = '${bookingDateTime.hour.toString().padLeft(2, '0')}:'
        '${bookingDateTime.minute.toString().padLeft(2, '0')}:'
        '${bookingDateTime.second.toString().padLeft(2, '0')}';

    return BookingCreateRequestDto(
      photographerProfileId: photographerProfileId.toString(),
      photoServiceId: photoServiceId.toString(),
      priceInfoId: priceInfoId.toString(),
      bookingDate: bookingDate,
      bookingTime: bookingTime,
    );
  }

  @override
  String toString() {
    return 'BookingCreateRequestDto('
        'photographerProfileId: $photographerProfileId, '
        'photoServiceId: $photoServiceId, '
        'priceInfoId: $priceInfoId, '
        'bookingDate: $bookingDate, '
        'bookingTime: $bookingTime'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BookingCreateRequestDto &&
        other.photographerProfileId == photographerProfileId &&
        other.photoServiceId == photoServiceId &&
        other.priceInfoId == priceInfoId &&
        other.bookingDate == bookingDate &&
        other.bookingTime == bookingTime;
  }

  @override
  int get hashCode {
    return Object.hash(
      photographerProfileId,
      photoServiceId,
      priceInfoId,
      bookingDate,
      bookingTime,
    );
  }
}
