import 'booking_model.dart';
import '../photo_service/photo_service.dart';

class BookingListItem {
  final int? bookingInfoId;
  final int otherPartyProfileId; // 예약 상대방(사용자 또는 포토그래퍼)의 ID
  final String otherPartyName; // 예약 상대방(사용자 또는 포토그래퍼)의 이름
  final DateTime bookingDateTime;
  final BookingStatus status;
  final PhotoService? photoService;

  const BookingListItem({
    this.bookingInfoId,
    required this.otherPartyProfileId,
    required this.otherPartyName,
    required this.bookingDateTime,
    required this.status,
    this.photoService,
  });

  BookingListItem copyWith({
    int? bookingInfoId,
    int? otherPartyProfileId,
    String? otherPartyName,
    DateTime? bookingDateTime,
    BookingStatus? status,
    PhotoService? photoService,
  }) {
    return BookingListItem(
      bookingInfoId: bookingInfoId ?? this.bookingInfoId,
      otherPartyProfileId: otherPartyProfileId ?? this.otherPartyProfileId,
      otherPartyName: otherPartyName ?? this.otherPartyName,
      bookingDateTime: bookingDateTime ?? this.bookingDateTime,
      status: status ?? this.status,
      photoService: photoService ?? this.photoService,
    );
  }

  @override
  String toString() {
    return 'BookingListItem{bookingInfoId: $bookingInfoId, otherPartyName: $otherPartyName, status: $status}';
  }
}
