class BookingDetailDto {
  final String photographerProfileId;
  final String userProfileId;
  final String bookingDate;
  final String bookingTime;
  final String status;
  final int? bookingInfoId;
  final String? photographerName;
  final String? serviceName;
  final int? price;

  BookingDetailDto({
    required this.photographerProfileId,
    required this.userProfileId,
    required this.bookingDate,
    required this.bookingTime,
    required this.status,
    this.bookingInfoId,
    this.photographerName,
    this.serviceName,
    this.price,
  });

  factory BookingDetailDto.fromJson(Map<String, dynamic> json) {
    return BookingDetailDto(
      photographerProfileId: json['photographerProfileId']?.toString() ?? '',
      userProfileId: json['userProfileId']?.toString() ?? '',
      bookingDate: json['bookingDate'] as String? ?? '',
      bookingTime: json['bookingTime'] as String? ?? '',
      status: json['status'] as String? ?? 'PENDING',
      bookingInfoId: json['bookingInfoId'] as int?,
      photographerName: json['photographerName'] as String?,
      serviceName: json['serviceName'] as String?,
      price: json['price'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'photographerProfileId': photographerProfileId,
      'userProfileId': userProfileId,
      'bookingDate': bookingDate,
      'bookingTime': bookingTime,
      'status': status,
      'bookingInfoId': bookingInfoId,
      'photographerName': photographerName,
      'serviceName': serviceName,
      'price': price,
    };
  }
}
