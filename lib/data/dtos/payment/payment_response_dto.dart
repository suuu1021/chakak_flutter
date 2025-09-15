class PaymentReadyResponseDto {
  final String tid;
  final String nextRedirectMobileUrl;
  final String nextRedirectPcUrl;
  final String androidAppScheme;
  final String iosAppScheme;
  final String partnerOrderId;
  final String itemName;
  final int price;

  PaymentReadyResponseDto({
    required this.tid,
    required this.nextRedirectMobileUrl,
    required this.nextRedirectPcUrl,
    required this.androidAppScheme,
    required this.iosAppScheme,
    required this.partnerOrderId,
    required this.itemName,
    required this.price,
  });

  factory PaymentReadyResponseDto.fromJson(Map<String, dynamic> json) {
    return PaymentReadyResponseDto(
      tid: json['tid'] ?? '',
      nextRedirectMobileUrl: json['nextRedirectMobileUrl'] ?? '',
      nextRedirectPcUrl: json['nextRedirectPcUrl'] ?? '',
      androidAppScheme: json['androidAppScheme'] ?? '',
      iosAppScheme: json['iosAppScheme'] ?? '',
      partnerOrderId: json['partnerOrderId'] ?? '',
      itemName: json['itemName'] ?? '',
      price: json['price'] ?? 0,
    );
  }
}

class PaymentApproveCompleteResponseDto {
  final String aid;
  final String tid;
  final String partnerOrderId;
  final String itemName;
  final int totalAmount;
  final String paymentMethodType;
  final String approvedAt;
  final int bookingInfoId;

  PaymentApproveCompleteResponseDto({
    required this.aid,
    required this.tid,
    required this.partnerOrderId,
    required this.itemName,
    required this.totalAmount,
    required this.paymentMethodType,
    required this.approvedAt,
    required this.bookingInfoId,
  });

  factory PaymentApproveCompleteResponseDto.fromJson(
      Map<String, dynamic> json) {
    return PaymentApproveCompleteResponseDto(
      aid: json['aid'] ?? '',
      tid: json['tid'] ?? '',
      partnerOrderId: json['partnerOrderId'] ?? '',
      itemName: json['itemName'] ?? '',
      totalAmount: json['totalAmount'] ?? 0,
      paymentMethodType: json['paymentMethodType'] ?? '',
      approvedAt: json['approvedAt'] ?? '',
      bookingInfoId: json['bookingInfoId'] ?? 0,
    );
  }
}
