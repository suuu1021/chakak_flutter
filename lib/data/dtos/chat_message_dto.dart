
import 'package:flutter/foundation.dart';

class ChatMessageDto {
  final int? chatMessageId; // 서버에서 발급, 보낼 땐 없음 (nullable)
  final int chatRoomId;
  final String senderType;
  final int senderId;
  final String messageType;
  final String message;
  final int? paymentAmount; // 옵션
  final String? paymentOrderId; // 옵션
  final bool? isRead; // 서버에서 발급, 보낼 땐 없음 (nullable)
  final String? createdAt; // 서버에서 발급, 보낼 땐 없음 (nullable String)

  ChatMessageDto({
    this.chatMessageId,
    required this.chatRoomId,
    required this.senderType,
    required this.senderId,
    required this.messageType,
    required this.message,
    this.paymentAmount,
    this.paymentOrderId,
    this.isRead,
    this.createdAt,
  });

  factory ChatMessageDto.fromJson(Map<String, dynamic> json) {
    final dto = ChatMessageDto(
      chatMessageId: json['chatMessageId'] as int?,
      chatRoomId: json['chatRoomId'] as int? ?? 0,
      senderType: json['senderType'] as String? ?? 'UNKNOWN',
      senderId: json['senderId'] as int? ?? 0,
      messageType: json['messageType'] as String? ?? 'UNKNOWN',
      message: json['message'] as String? ?? '',
      paymentAmount: json['paymentAmount'] as int?,
      paymentOrderId: json['paymentOrderId'] as String?,
      isRead: json['isRead'] as bool? ?? false,
      createdAt: json['createdAt'] as String?, // String?으로 받음
    );

    if (kDebugMode) {
      print('[PARSED] ChatMessageDto: ${dto.toString()}');
    }

    return dto;
  }

  Map<String, dynamic> toJson() {
    return {
      'chatMessageId': chatMessageId,
      'chatRoomId': chatRoomId,
      'senderType': senderType,
      'senderId': senderId,
      'messageType': messageType,
      'message': message,
      'paymentAmount': paymentAmount,
      'paymentOrderId': paymentOrderId,
      'isRead': isRead,
      'createdAt': createdAt, // String?을 그대로 전달
    };
  }

  @override
  String toString() {
    return 'ChatMessageDto{\n'
        '  chatMessageId: $chatMessageId,\n'
        '  chatRoomId: $chatRoomId,\n'
        '  senderType: $senderType,\n'
        '  senderId: $senderId,\n'
        '  messageType: $messageType,\n'
        '  message: $message,\n'
        '  paymentAmount: $paymentAmount,\n'
        '  paymentOrderId: $paymentOrderId,\n'
        '  isRead: $isRead,\n'
        '  createdAt: $createdAt\n'
        '}';
  }
}
