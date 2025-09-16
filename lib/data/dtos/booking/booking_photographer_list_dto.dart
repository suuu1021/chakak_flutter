import '../../models/booking/booking_model.dart';
import '../../models/photo_service/photo_service.dart';

/// 포토그래퍼 예약 목록 응답 DTO
class BookingPhotographerListDto {
  final String userProfileId;
  final String photographerProfileId;
  final String bookingDate;
  final String bookingTime;
  final String status;
  final int? bookingInfoId;
  final String? userName;
  final String? serviceName;
  final int? price;
  final double? rating;
  final String? imageUrl;

  BookingPhotographerListDto({
    required this.userProfileId,
    required this.photographerProfileId,
    required this.bookingDate,
    required this.bookingTime,
    required this.status,
    this.bookingInfoId,
    this.userName,
    this.serviceName,
    this.price,
    this.rating,
    this.imageUrl,
  });

  /// 서버 응답 JSON에서 DTO 생성
  factory BookingPhotographerListDto.fromJson(Map<String, dynamic> json) {
    return BookingPhotographerListDto(
      userProfileId: json['userProfileId']?.toString() ?? '',
      photographerProfileId: json['photographerProfileId']?.toString() ?? '',
      bookingDate: json['bookingDate'] as String? ?? '',
      bookingTime: json['bookingTime'] as String? ?? '',
      status: json['status'] as String? ?? 'PENDING',
      bookingInfoId: json['bookingInfoId'] as int?,
      userName: json['userName'] as String?,
      serviceName: json['serviceName'] as String?,
      price: json['price'] as int?,
      rating: (json['rating'] as num?)?.toDouble(),
      imageUrl: json['imageUrl'] as String?,
    );
  }

  /// 서버 전송용 JSON 변환
  Map<String, dynamic> toJson() {
    return {
      'userProfileId': userProfileId,
      'photographerProfileId': photographerProfileId,
      'bookingDate': bookingDate,
      'bookingTime': bookingTime,
      'status': status,
      'bookingInfoId': bookingInfoId,
      'userName': userName,
      'serviceName': serviceName,
      'price': price,
    };
  }

  /// DTO를 BookingListItem 모델로 변환 (포토그래퍼 관점)
  BookingListItem toBookingListItem() {
    DateTime bookingDateTime;
    try {
      final dateTimeString = '${bookingDate}T$bookingTime';
      bookingDateTime = DateTime.parse(dateTimeString);
    } catch (e) {
      bookingDateTime = DateTime.now();
      print('날짜 파싱 실패: $bookingDate $bookingTime, 오류: $e');
    }

    // serviceName, price, rating이 있을 때 PhotoService 생성
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
      // 포토그래퍼 관점에서는 사용자 정보를 표시
      photographerProfileId: int.tryParse(userProfileId) ?? 0,
      bookingDateTime: bookingDateTime,
      status: _parseServerStatus(status),
      photographerName: userName ?? '사용자',
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
    return 'BookingPhotographerListDto('
        'userProfileId: $userProfileId, '
        'photographerProfileId: $photographerProfileId, '
        'bookingDate: $bookingDate, '
        'bookingTime: $bookingTime, '
        'status: $status, '
        'bookingInfoId: $bookingInfoId'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BookingPhotographerListDto &&
        other.userProfileId == userProfileId &&
        other.photographerProfileId == photographerProfileId &&
        other.bookingDate == bookingDate &&
        other.bookingTime == bookingTime &&
        other.status == status &&
        other.bookingInfoId == bookingInfoId;
  }

  @override
  int get hashCode {
    return Object.hash(
      userProfileId,
      photographerProfileId,
      bookingDate,
      bookingTime,
      status,
      bookingInfoId,
    );
  }
}
