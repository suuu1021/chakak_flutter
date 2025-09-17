
import 'package:flutter/foundation.dart';

class ChatMessageDto {
  final int? chatMessageId;
  final int chatRoomId;
  final String senderType;
  final int senderId;
  final String messageType;
  final String message;
  final int? paymentAmount;
  final String? paymentOrderId;
  final bool? isRead;
  final String? createdAt;

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
      createdAt: json['createdAt'] as String?,
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
      'createdAt': createdAt,
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
