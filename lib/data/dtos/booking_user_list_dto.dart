// features/booking/data/dto/booking_user_list_dto.dart

import '../models/booking_model.dart';

/// 사용자 예약 목록 응답 DTO
class BookingUserListDto {
  final String photographerProfileId;
  final String bookingDate;
  final String bookingTime;

  BookingUserListDto({
    required this.photographerProfileId,
    required this.bookingDate,
    required this.bookingTime,
  });

  /// 서버 응답 JSON에서 DTO 생성
  factory BookingUserListDto.fromJson(Map<String, dynamic> json) {
    return BookingUserListDto(
      photographerProfileId: json['photographerProfileId']?.toString() ?? '',
      bookingDate: json['bookingDate'] as String? ?? '',
      bookingTime: json['bookingTime'] as String? ?? '',
    );
  }

  /// 서버 전송용 JSON 변환
  Map<String, dynamic> toJson() {
    return {
      'photographerProfileId': photographerProfileId,
      'bookingDate': bookingDate,
      'bookingTime': bookingTime,
    };
  }

  /// Model에서 DTO 생성
  factory BookingUserListDto.fromModel(BookingListItem model) {
    return BookingUserListDto(
      photographerProfileId: model.photographerProfileId.toString(),
      bookingDate: '${model.bookingDateTime.year}-'
          '${model.bookingDateTime.month.toString().padLeft(2, '0')}-'
          '${model.bookingDateTime.day.toString().padLeft(2, '0')}',
      bookingTime: '${model.bookingDateTime.hour.toString().padLeft(2, '0')}:'
          '${model.bookingDateTime.minute.toString().padLeft(2, '0')}:'
          '${model.bookingDateTime.second.toString().padLeft(2, '0')}',
    );
  }

  /// DTO를 Model로 변환
  BookingListItem toModel() {
    final dateTime = DateTime.parse('${bookingDate}T$bookingTime');
    return BookingListItem(
      photographerProfileId: int.tryParse(photographerProfileId) ?? 0,
      bookingDateTime: dateTime,
      status: BookingStatus.pending, // 임시로 고정
      photographerName: '작가 $photographerProfileId', // 임시 이름
    );
  }

  @override
  String toString() {
    return 'BookingUserListDto('
        'photographerProfileId: $photographerProfileId, '
        'bookingDate: $bookingDate, '
        'bookingTime: $bookingTime'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BookingUserListDto &&
        other.photographerProfileId == photographerProfileId &&
        other.bookingDate == bookingDate &&
        other.bookingTime == bookingTime;
  }

  @override
  int get hashCode {
    return Object.hash(
      photographerProfileId,
      bookingDate,
      bookingTime,
    );
  }
}
