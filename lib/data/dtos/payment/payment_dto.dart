import '../../models/payment.dart';

class PaymentDto {
  final int paymentId;
  final String tid;
  final String partnerOrderId;
  final String partnerUserId;
  final String itemName;
  final int totalAmount;
  final int vatAmount;
  final int taxFreeAmount;
  final String status;
  final String? paymentMethodType;
  final String? aid;
  final String createdAt;
  final String? approvedAt;

  PaymentDto({
    required this.paymentId,
    required this.tid,
    required this.partnerOrderId,
    required this.partnerUserId,
    required this.itemName,
    required this.totalAmount,
    required this.vatAmount,
    required this.taxFreeAmount,
    required this.status,
    this.paymentMethodType,
    this.aid,
    required this.createdAt,
    this.approvedAt,
  });

  factory PaymentDto.fromJson(Map<String, dynamic> json) {
    return PaymentDto(
      paymentId: json['paymentId'] ?? 0,
      tid: json['tid'] ?? '',
      partnerOrderId: json['partnerOrderId'] ?? '',
      partnerUserId: json['partnerUserId'] ?? '',
      itemName: json['itemName'] ?? '',
      totalAmount: json['totalAmount'] ?? 0,
      vatAmount: json['vatAmount'] ?? 0,
      taxFreeAmount: json['taxFreeAmount'] ?? 0,
      status: json['status'] ?? 'READY',
      paymentMethodType: json['paymentMethodType'],
      aid: json['aid'],
      createdAt: json['createdAt'] ?? '',
      approvedAt: json['approvedAt'],
    );
  }

  // Payment 모델로부터 PaymentDto 생성
  factory PaymentDto.fromPayment(Payment payment) {
    return PaymentDto(
      paymentId: payment.paymentId,
      tid: payment.tid,
      partnerOrderId: payment.partnerOrderId,
      partnerUserId: payment.partnerUserId,
      itemName: payment.itemName,
      totalAmount: payment.totalAmount,
      vatAmount: payment.vatAmount,
      taxFreeAmount: payment.taxFreeAmount,
      status: payment.status.name.toUpperCase(),
      paymentMethodType: payment.paymentMethodType,
      aid: payment.aid,
      createdAt: payment.createdAt.toIso8601String(),
      approvedAt: payment.approvedAt?.toIso8601String(),
    );
  }

  // DTO를 Model로 변환
  Payment toModel() {
    return Payment(
      paymentId: paymentId,
      tid: tid,
      partnerOrderId: partnerOrderId,
      partnerUserId: partnerUserId,
      itemName: itemName,
      totalAmount: totalAmount,
      vatAmount: vatAmount,
      taxFreeAmount: taxFreeAmount,
      status: _parseStatus(status),
      paymentMethodType: paymentMethodType,
      aid: aid,
      createdAt: DateTime.parse(createdAt),
      approvedAt: approvedAt != null ? DateTime.parse(approvedAt!) : null,
    );
  }

  PaymentStatus _parseStatus(String status) {
    switch (status.toUpperCase()) {
      case 'READY':
        return PaymentStatus.ready;
      case 'APPROVED':
        return PaymentStatus.approved;
      case 'CANCELED':
        return PaymentStatus.canceled;
      case 'FAILED':
        return PaymentStatus.failed;
      default:
        return PaymentStatus.ready;
    }
  }
}
