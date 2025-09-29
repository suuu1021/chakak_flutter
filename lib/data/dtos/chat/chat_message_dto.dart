import 'package:chakak_flutter/_core/constants/sender_type.dart';

class ChatMessageDto {
  final int? chatMessageId;
  final int chatRoomId;
  final SenderType senderType;
  final int senderId;
  final String messageType;
  final String message;
  final String? createdAt;
  final String? imageBase64;
  final String? imageOriginalName;
  final String? imageUrl;
  final int? fileSize;
  final int? paymentAmount;
  final String? paymentOrderId;
  final bool? isRead;
  final String? paymentDescription;
  final int? photoServiceInfoId;
  final int? priceInfoId;
  final int? bookingInfoId;

  ChatMessageDto({
    this.chatMessageId,
    required this.chatRoomId,
    required this.senderType,
    required this.senderId,
    required this.messageType,
    required this.message,
    this.createdAt,
    this.imageBase64,
    this.imageOriginalName,
    this.imageUrl,
    this.fileSize,
    this.paymentAmount,
    this.paymentOrderId,
    this.isRead,
    this.paymentDescription,
    this.photoServiceInfoId,
    this.priceInfoId,
    this.bookingInfoId,
  });

  factory ChatMessageDto.fromJson(Map<String, dynamic> json) {
    return ChatMessageDto(
      chatMessageId: json['chatMessageId'],
      chatRoomId: json['chatRoomId'],
      senderType: SenderType.fromJson(json['senderType'] ?? 'UNKNOWN'),
      senderId: json['senderId'],
      messageType: json['messageType'],
      message: json['message'] ?? '',
      createdAt: json['createdAt'],
      imageUrl: json['imageUrl'],
      imageOriginalName: json['imageOriginalName'],
      paymentAmount: json['paymentAmount'],
      paymentOrderId: json['paymentOrderId'],
      isRead: json['isRead'],
      paymentDescription: json['paymentDescription'],
      photoServiceInfoId: json['photoServiceInfoId'],
      priceInfoId: json['priceInfoId'],
      bookingInfoId: json['bookingInfoId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chatMessageId': chatMessageId,
      'chatRoomId': chatRoomId,
      'senderType': senderType.toJson,
      'senderId': senderId,
      'messageType': messageType,
      'message': message,
      'createdAt': createdAt,
      'imageBase64': imageBase64,
      'imageOriginalName': imageOriginalName,
      'imageUrl': imageUrl,
      'fileSize': fileSize,
      'paymentAmount': paymentAmount,
      'paymentOrderId': paymentOrderId,
      'isRead': isRead,
      'paymentDescription': paymentDescription,
      'photoServiceInfoId': photoServiceInfoId,
      'priceInfoId': priceInfoId,
      'bookingInfoId': bookingInfoId,
    };
  }

  bool get isImageMessage => messageType == 'IMAGE';
  bool get hasImageUrl => imageUrl != null && imageUrl!.isNotEmpty;
}
