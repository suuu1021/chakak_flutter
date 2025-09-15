class PaymentReadyRequestDto {
  final int bookingInfoId;

  PaymentReadyRequestDto({
    required this.bookingInfoId,
  });

  Map<String, dynamic> toJson() {
    return {
      'bookingInfoId': bookingInfoId,
    };
  }
}
