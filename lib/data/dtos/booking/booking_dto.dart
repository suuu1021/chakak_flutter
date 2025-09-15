import '../../models/booking.dart';

class BookingDto {
  final int bookingInfoId;
  final int userProfileId;
  final int photographerProfileId;
  final int photoServiceInfoId;
  final int priceInfoId;
  final String bookingDate;
  final String? specialRequests;
  final String status;
  final String createdAt;
  final String updatedAt;

  // 조인된 추가 정보
  final String? photographerName;
  final String? serviceName;
  final int? price;

  BookingDto({
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

  factory BookingDto.fromJson(Map<String, dynamic> json) {
    return BookingDto(
      bookingInfoId: json['bookingInfoId'] ?? 0,
      userProfileId: json['userProfileId'] ?? 0,
      photographerProfileId: json['photographerProfileId'] ?? 0,
      photoServiceInfoId: json['photoServiceInfoId'] ?? 0,
      priceInfoId: json['priceInfoId'] ?? 0,
      bookingDate: json['bookingDate'] ?? '',
      specialRequests: json['specialRequests'],
      status: json['status'] ?? 'PENDING',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      photographerName: json['photographerName'],
      serviceName: json['serviceName'],
      price: json['price'],
    );
  }

  // DTO를 Model로 변환
  Booking toModel() {
    return Booking(
      bookingInfoId: bookingInfoId,
      userProfileId: userProfileId,
      photographerProfileId: photographerProfileId,
      photoServiceInfoId: photoServiceInfoId,
      priceInfoId: priceInfoId,
      bookingDate: bookingDate,
      specialRequests: specialRequests,
      status: _parseStatus(status),
      createdAt: DateTime.parse(createdAt),
      updatedAt: DateTime.parse(updatedAt),
      photographerName: photographerName,
      serviceName: serviceName,
      price: price,
    );
  }

  BookingStatus _parseStatus(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return BookingStatus.pending;
      case 'CONFIRMED':
        return BookingStatus.confirmed;
      case 'COMPLETED':
        return BookingStatus.completed;
      case 'CANCELLED':
        return BookingStatus.cancelled;
      default:
        return BookingStatus.pending;
    }
  }
}
