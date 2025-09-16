import '../../models/booking/booking_model.dart';
import '../../models/photo_service/photo_service.dart';

/// 사용자 예약 목록 응답 DTO
class BookingUserListDto {
  final String photographerProfileId;
  final String userProfileId;
  final String bookingDate;
  final String bookingTime;
  final String status;
  final int? bookingInfoId;
  final String? photographerName;
  final String? serviceName;
  final double? rating;
  final String? imageUrl;
  final int? price;

  BookingUserListDto({
    required this.photographerProfileId,
    required this.userProfileId,
    required this.bookingDate,
    required this.bookingTime,
    required this.status,
    this.bookingInfoId,
    this.photographerName,
    this.serviceName,
    this.rating,
    this.imageUrl,
    this.price,
  });

  /// 서버 응답 JSON에서 DTO 생성
  factory BookingUserListDto.fromJson(Map<String, dynamic> json) {
    return BookingUserListDto(
      photographerProfileId: json['photographerProfileId']?.toString() ?? '',
      userProfileId: json['userProfileId']?.toString() ?? '',
      bookingDate: json['bookingDate'] as String? ?? '',
      bookingTime: json['bookingTime'] as String? ?? '',
      status: json['status'] as String? ?? 'PENDING',
      bookingInfoId: json['bookingInfoId'] as int?,
      photographerName: json['photographerName'] as String?,
      serviceName: json['serviceName'] as String?,
      rating: (json['rating'] as num?)?.toDouble(),
      imageUrl: json['imageUrl'] as String?,
      price: json['price'] as int?,
    );
  }

  /// DTO를 BookingListItem 모델로 변환
  BookingListItem toBookingListItem() {
    DateTime bookingDateTime;
    try {
      final dateTimeString = '${bookingDate}T$bookingTime';
      bookingDateTime = DateTime.parse(dateTimeString);
    } catch (e) {
      bookingDateTime = DateTime.now();
      print('날짜 파싱 실패: $bookingDate $bookingTime, 오류: $e');
    }

    // serviceName, rating, imageUrl, price가 있을 때 PhotoService 생성
    PhotoService? photoService;
    if (serviceName != null && price != null) {
      photoService = PhotoService(
        id: 0, // 임시값
        photographerId: int.tryParse(photographerProfileId) ?? 0,
        title: serviceName!,
        imageUrl: imageUrl ?? '',
        categories: [],
        price: price!,
        rating: rating ?? 0.0,
        reviewCount: 0,
      );
    }

    return BookingListItem(
      photographerProfileId: int.tryParse(photographerProfileId) ?? 0,
      bookingDateTime: bookingDateTime,
      status: _parseServerStatus(status),
      photographerName: photographerName ?? '포토그래퍼',
      bookingInfoId: bookingInfoId,
      photoService: photoService,
    );
  }

  /// 서버 상태를 BookingStatus enum으로 변환
  BookingStatus _parseServerStatus(String serverStatus) {
    switch (serverStatus.toUpperCase()) {
      case 'PENDING':
        return BookingStatus.pending;
      case 'CONFIRMED':
        return BookingStatus.confirmed;
      case 'REJECTED':
        return BookingStatus.rejected;
      case 'CANCELED':
        return BookingStatus.canceled;
      case 'COMPLETED':
        return BookingStatus.completed;
      case 'REVIEWED':
        return BookingStatus.reviewed;
      default:
        return BookingStatus.pending;
    }
  }

  @override
  String toString() {
    return 'BookingUserListDto('
        'photographerProfileId: $photographerProfileId, '
        'userProfileId: $userProfileId, '
        'bookingDate: $bookingDate, '
        'bookingTime: $bookingTime, '
        'status: $status, '
        'bookingInfoId: $bookingInfoId'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BookingUserListDto &&
        other.photographerProfileId == photographerProfileId &&
        other.userProfileId == userProfileId &&
        other.bookingDate == bookingDate &&
        other.bookingTime == bookingTime &&
        other.status == status &&
        other.bookingInfoId == bookingInfoId;
  }

  @override
  int get hashCode {
    return Object.hash(
      photographerProfileId,
      userProfileId,
      bookingDate,
      bookingTime,
      status,
      bookingInfoId,
    );
  }
}
