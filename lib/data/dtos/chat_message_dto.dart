class ChatMessageDto {
  final int? chatMessageId;
  final int chatRoomId;
  final String senderType; // USER 또는 PHOTOGRAPHER
  final int senderId;
  final String messageType; // TEXT 또는 PAYMENT_REQUEST
  final String? message; // TEXT 타입일 때 메시지 내용
  final int? paymentAmount; // PAYMENT_REQUEST 타입일 때 금액
  final String? paymentOrderId; // PAYMENT_REQUEST 타입일 때 주문 ID
  final bool isRead;
  final String createdAt;

  ChatMessageDto({
    this.chatMessageId,
    required this.chatRoomId,
    required this.senderType,
    required this.senderId,
    required this.messageType,
    this.message,
    this.paymentAmount,
    this.paymentOrderId,
    required this.isRead,
    required this.createdAt,
  });

  factory ChatMessageDto.fromJson(Map<String, dynamic> json) {
    return ChatMessageDto(
      chatMessageId: json['chatMessageId'] as int?,
      chatRoomId: json['chatRoomId'] as int,
      senderType: json['senderType'] as String,
      senderId: json['senderId'] as int,
      messageType: json['messageType'] as String,
      message: json['message'] as String?,
      paymentAmount: json['paymentAmount'] as int?,
      paymentOrderId: json['paymentOrderId'] as String?,
      isRead: json['isRead'] as bool? ?? false,
      createdAt: json['createdAt'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (chatMessageId != null) 'chatMessageId': chatMessageId,
      'chatRoomId': chatRoomId,
      'senderType': senderType,
      'senderId': senderId,
      'messageType': messageType,
      if (message != null) 'message': message,
      if (paymentAmount != null) 'paymentAmount': paymentAmount,
      if (paymentOrderId != null) 'paymentOrderId': paymentOrderId,
      'isRead': isRead,
      'createdAt': createdAt,
    };
  }
}

enum SenderType { USER, PHOTOGRAPHER }

enum MessageType { TEXT, PAYMENT_REQUEST }
