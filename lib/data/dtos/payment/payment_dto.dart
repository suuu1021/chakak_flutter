import '../../models/payment.dart';

class PaymentDto {
  final int paymentId;
  final String tid;
  final String partnerOrderId;
  final String itemName;
  final int totalAmount;
  final String status;
  final String? paymentMethodType;
  final String? aid;
  final String createdAt;
  final String? approvedAt;
  final int? bookingInfoId;
  final String? photographerName;
  final String? serviceTitle;
  final bool? completed;
  final bool? approved;
  final String? statusDescription;

  PaymentDto({
    required this.paymentId,
    required this.tid,
    required this.partnerOrderId,
    required this.itemName,
    required this.totalAmount,
    required this.status,
    this.paymentMethodType,
    this.aid,
    required this.createdAt,
    this.approvedAt,
    this.bookingInfoId,
    this.photographerName,
    this.serviceTitle,
    this.completed,
    this.approved,
    this.statusDescription,
  });

  factory PaymentDto.fromJson(Map<String, dynamic> json) {
    return PaymentDto(
      paymentId: json['paymentId'] ?? 0,
      tid: json['tid'] ?? '',
      partnerOrderId: json['partnerOrderId'] ?? '',
      itemName: json['itemName'] ?? '',
      totalAmount: json['totalAmount'] ?? 0,
      status: json['status'] ?? 'READY',
      paymentMethodType: json['paymentMethodType'],
      aid: json['aid'],
      createdAt: json['createdAt'] ?? '',
      approvedAt: json['approvedAt'],
      bookingInfoId: json['bookingInfoId'],
      photographerName: json['photographerName'],
      serviceTitle: json['serviceTitle'],
      completed: json['completed'],
      approved: json['approved'],
      statusDescription: json['statusDescription'],
    );
  }

  // Payment 모델로부터 PaymentDto 생성
  factory PaymentDto.fromPayment(Payment payment) {
    return PaymentDto(
      paymentId: payment.paymentId,
      tid: payment.tid,
      partnerOrderId: payment.partnerOrderId,
      itemName: payment.itemName,
      totalAmount: payment.totalAmount,
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
      partnerUserId: '', // 백엔드 응답에 없음
      itemName: itemName,
      totalAmount: totalAmount,
      vatAmount: 0, // 백엔드 응답에 없음
      taxFreeAmount: 0, // 백엔드 응답에 없음
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
