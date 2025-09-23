class BookingCreateRequestDto {
  final int photographerProfileId;
  final int? userProfileId; // 일반 사용자 ID 추가 (선택적)
  final int photoServiceInfoId;
  final int priceInfoId;
  final String bookingDate;
  final String bookingTime;
  final String? specialRequests;

  BookingCreateRequestDto({
    required this.photographerProfileId,
    this.userProfileId, // 추가
    required this.photoServiceInfoId,
    required this.priceInfoId,
    required this.bookingDate,
    required this.bookingTime,
    this.specialRequests,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'photographerProfileId': photographerProfileId,
      'photoServiceId': photoServiceInfoId,
      'priceInfoId': priceInfoId,
      'bookingDate': bookingDate,
      'bookingTime': bookingTime,
    };

    if (userProfileId != null) {
      data['userProfileId'] = userProfileId;
    }

    if (specialRequests != null) {
      data['specialRequests'] = specialRequests;
    }

    return data;
  }
}

class BookingUpdateRequestDto {
  final String? bookingDate;
  final String? bookingTime; // bookingTime 필드 추가
  final String? specialRequests;
  final String? status;

  BookingUpdateRequestDto({
    this.bookingDate,
    this.bookingTime, // 추가
    this.specialRequests,
    this.status,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (bookingDate != null) data['bookingDate'] = bookingDate;
    if (bookingTime != null) data['bookingTime'] = bookingTime; // 추가
    if (specialRequests != null) data['specialRequests'] = specialRequests;
    if (status != null) data['status'] = status;
    return data;
  }
}
