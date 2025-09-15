import 'package:flutter/material.dart';

class Payment {
  final int paymentId;
  final String tid;
  final String partnerOrderId;
  final String partnerUserId;
  final String itemName;
  final int totalAmount;
  final int vatAmount;
  final int taxFreeAmount;
  final PaymentStatus status;
  final String? paymentMethodType;
  final String? aid;
  final DateTime createdAt;
  final DateTime? approvedAt;

  const Payment({
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

  Payment copyWith({
    int? paymentId,
    String? tid,
    String? partnerOrderId,
    String? partnerUserId,
    String? itemName,
    int? totalAmount,
    int? vatAmount,
    int? taxFreeAmount,
    PaymentStatus? status,
    String? paymentMethodType,
    String? aid,
    DateTime? createdAt,
    DateTime? approvedAt,
  }) {
    return Payment(
      paymentId: paymentId ?? this.paymentId,
      tid: tid ?? this.tid,
      partnerOrderId: partnerOrderId ?? this.partnerOrderId,
      partnerUserId: partnerUserId ?? this.partnerUserId,
      itemName: itemName ?? this.itemName,
      totalAmount: totalAmount ?? this.totalAmount,
      vatAmount: vatAmount ?? this.vatAmount,
      taxFreeAmount: taxFreeAmount ?? this.taxFreeAmount,
      status: status ?? this.status,
      paymentMethodType: paymentMethodType ?? this.paymentMethodType,
      aid: aid ?? this.aid,
      createdAt: createdAt ?? this.createdAt,
      approvedAt: approvedAt ?? this.approvedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Payment && other.paymentId == paymentId;
  }

  @override
  int get hashCode => paymentId.hashCode;

  // 편의 메서드들
  String get formattedAmount =>
      '₩${totalAmount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
  bool get isCompleted => status == PaymentStatus.approved;
  bool get isPending => status == PaymentStatus.ready;
  bool get isFailed =>
      status == PaymentStatus.failed || status == PaymentStatus.canceled;
}

enum PaymentStatus {
  ready, // 결제준비
  approved, // 결제승인완료
  canceled, // 결제취소
  failed; // 결제실패

  String get displayName {
    switch (this) {
      case PaymentStatus.ready:
        return '결제준비';
      case PaymentStatus.approved:
        return '결제승인완료';
      case PaymentStatus.canceled:
        return '결제취소';
      case PaymentStatus.failed:
        return '결제실패';
    }
  }

  Color get color {
    switch (this) {
      case PaymentStatus.ready:
        return Colors.orange;
      case PaymentStatus.approved:
        return Colors.green;
      case PaymentStatus.canceled:
        return Colors.grey;
      case PaymentStatus.failed:
        return Colors.red;
    }
  }
}
