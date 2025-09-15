class BookingCreateRequestDto {
  final int photographerProfileId;
  final int photoServiceInfoId;
  final int priceInfoId;
  final String bookingDate;
  final String? specialRequests;

  BookingCreateRequestDto({
    required this.photographerProfileId,
    required this.photoServiceInfoId,
    required this.priceInfoId,
    required this.bookingDate,
    this.specialRequests,
  });

  Map<String, dynamic> toJson() {
    return {
      'photographerProfileId': photographerProfileId,
      'photoServiceInfoId': photoServiceInfoId,
      'priceInfoId': priceInfoId,
      'bookingDate': bookingDate,
      'specialRequests': specialRequests,
    };
  }
}

class BookingUpdateRequestDto {
  final String? bookingDate;
  final String? specialRequests;
  final String? status;

  BookingUpdateRequestDto({
    this.bookingDate,
    this.specialRequests,
    this.status,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (bookingDate != null) data['bookingDate'] = bookingDate;
    if (specialRequests != null) data['specialRequests'] = specialRequests;
    if (status != null) data['status'] = status;
    return data;
  }
}
