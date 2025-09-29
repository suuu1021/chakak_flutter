import '../photo_service/photo_service_dto.dart';

class ApiBookingItemDto {
  final int bookingInfoId;
  final String bookingDate;
  final String bookingStatus;
  final PhotoServiceDto photoServiceInfo;

  ApiBookingItemDto({
    required this.bookingInfoId,
    required this.bookingDate,
    required this.bookingStatus,
    required this.photoServiceInfo,
  });

  factory ApiBookingItemDto.fromJson(Map<String, dynamic> json) {
    return ApiBookingItemDto(
      bookingInfoId: json['bookingInfoId'] as int,
      bookingDate: json['bookingDate'] as String,
      bookingStatus: json['bookingStatus'] as String,
      photoServiceInfo: PhotoServiceDto.fromJson(
          json['photoServiceInfo'] as Map<String, dynamic>),
    );
  }
}
