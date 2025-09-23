import 'package:chakak_flutter/_core/constants/sender_type.dart';
import 'package:flutter/foundation.dart';

class ChatMessageDto {
  final int? chatMessageId;
  final int chatRoomId;
  final SenderType senderType;
  final int senderId;
  final String messageType;
  final String message;
  final int? paymentAmount;
  final String? paymentOrderId;
  final bool? isRead;
  final String? createdAt;
  final String? imageData;
  final String? fileName;
  final int? fileSize;
  final String? paymentDescription;

  // 새로 추가된 필드들
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
    this.paymentAmount,
    this.paymentOrderId,
    this.isRead,
    this.createdAt,
    this.imageData,
    this.fileName,
    this.fileSize,
    this.paymentDescription,
    this.photoServiceInfoId,
    this.priceInfoId,
    this.bookingInfoId,
  });

  factory ChatMessageDto.fromJson(Map<String, dynamic> json) {
    final dto = ChatMessageDto(
      chatMessageId: json['chatMessageId'] as int?,
      chatRoomId: json['chatRoomId'] as int? ?? 0,
      senderType:
          SenderType.fromJson(json['senderType'] as String? ?? 'UNKNOWN'),
      senderId: json['senderId'] as int? ?? 0,
      messageType: json['messageType'] as String? ?? 'UNKNOWN',
      message: json['message'] as String? ?? '',
      paymentAmount: json['paymentAmount'] as int?,
      paymentOrderId: json['paymentOrderId'] as String?,
      isRead: json['isRead'] as bool? ?? false,
      createdAt: json['createdAt'] as String?,
      imageData: json['imageData'] as String?,
      fileName: json['fileName'] as String?,
      fileSize: json['fileSize'] as int?,
      paymentDescription: json['paymentDescription'] as String?,
      // 추가된 필드들
      photoServiceInfoId: json['photoServiceInfoId'] as int?,
      priceInfoId: json['priceInfoId'] as int?,
      bookingInfoId: json['bookingInfoId'] as int?,
    );

    if (kDebugMode) {
      print('[PARSED] ChatMessageDto: ${dto.toString()}');
    }

    return dto;
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'chatMessageId': chatMessageId,
      'chatRoomId': chatRoomId,
      'senderType': senderType.toJson,
      'senderId': senderId,
      'messageType': messageType,
      'message': message,
      'paymentAmount': paymentAmount,
      'paymentOrderId': paymentOrderId,
      'isRead': isRead,
      'createdAt': createdAt,
    };

    if (imageData != null) {
      json['imageData'] = imageData;
    }
    if (fileName != null) {
      json['fileName'] = fileName;
    }
    if (fileSize != null) {
      json['fileSize'] = fileSize;
    }
    if (paymentDescription != null) {
      json['paymentDescription'] = paymentDescription;
    }

    // 추가된 필드는 null이 아닐 때만 추가
    if (photoServiceInfoId != null) {
      json['photoServiceInfoId'] = photoServiceInfoId;
    }
    if (priceInfoId != null) {
      json['priceInfoId'] = priceInfoId;
    }
    if (bookingInfoId != null) {
      json['bookingInfoId'] = bookingInfoId;
    }

    return json;
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
        '  createdAt: $createdAt,\n'
        '  imageData: ${imageData != null ? '[${imageData!.length} chars]' : null},\n'
        '  fileName: $fileName,\n'
        '  fileSize: $fileSize,\n'
        '  paymentDescription: $paymentDescription,\n'
        '  photoServiceInfoId: $photoServiceInfoId,\n'
        '  priceInfoId: $priceInfoId\n'
        '  bookingInfoId: $bookingInfoId\n'
        '}';
  }

  bool get isImageMessage => messageType == 'IMAGE';
  bool get isPaymentRequest => messageType == 'PAYMENT_REQUEST';
  bool get isTextMessage => messageType == 'TEXT';

  bool get hasImageData => imageData != null && imageData!.isNotEmpty;

  String get readableFileSize {
    if (fileSize == null) return '0 B';

    const suffixes = ['B', 'KB', 'MB', 'GB'];
    var size = fileSize!.toDouble();
    var suffixIndex = 0;

    while (size >= 1024 && suffixIndex < suffixes.length - 1) {
      size /= 1024;
      suffixIndex++;
    }

    return '${size.toStringAsFixed(1)} ${suffixes[suffixIndex]}';
  }
}
