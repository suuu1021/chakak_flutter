import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/booking/booking_list_item.dart';
import '../../models/booking/booking_model.dart';
import '../../models/photo_service/photo_service.dart';

/// 예약 정보를 담는 통합 DTO
/// 서버 API 응답을 받기 위한 데이터 구조
class BookingDto {
  final int? bookingInfoId;
  final String userProfileId;
  final String photographerProfileId;
  final String bookingDate;
  final String bookingTime;
  final String status;
  final String? otherName; // 사용자 이름 또는 포토그래퍼 이름
  final String? serviceName;
  final int? price;
  final double? rating;
  final String? imageUrl;
  final int? photoServiceInfoId;

  BookingDto({
    this.bookingInfoId,
    required this.userProfileId,
    required this.photographerProfileId,
    required this.bookingDate,
    required this.bookingTime,
    required this.status,
    this.otherName,
    this.serviceName,
    this.price,
    this.rating,
    this.imageUrl,
    this.photoServiceInfoId,
  });

  /// JSON 데이터로부터 BookingDto 인스턴스를 생성하는 팩토리 생성자
  /// 백엔드 BookingUserListDTO 응답에 맞게 수정
  factory BookingDto.fromJson(Map<String, dynamic> json) {
    print('[BookingDto.fromJson] Raw JSON: $json'); // 최상단에 전체 JSON 로깅

    int? parsedPhotoServiceInfoId;
    try {
      final dynamic photoServiceIdValue = json['photoServiceInfoId'];
      print(
          '[BookingDto.fromJson] photoServiceInfoId raw value: $photoServiceIdValue, type: ${photoServiceIdValue.runtimeType}');
      if (photoServiceIdValue != null) {
        if (photoServiceIdValue is int) {
          parsedPhotoServiceInfoId = photoServiceIdValue;
        } else if (photoServiceIdValue is String) {
          parsedPhotoServiceInfoId = int.tryParse(photoServiceIdValue);
          if (parsedPhotoServiceInfoId == null) {
            print(
                '[BookingDto.fromJson] WARNING: photoServiceInfoId was a String but could not be parsed to int: "$photoServiceIdValue"');
          }
        } else {
          print(
              '[BookingDto.fromJson] WARNING: photoServiceInfoId is not an int or String, actual type: ${photoServiceIdValue.runtimeType}');
        }
      } else {
        print('[BookingDto.fromJson] photoServiceInfoId is null in JSON');
      }
    } catch (e, s) {
      print(
          '[BookingDto.fromJson] EXCEPTION while parsing photoServiceInfoId: $e');
      print(s);
    }
    print(
        '[BookingDto.fromJson] Parsed photoServiceInfoId: $parsedPhotoServiceInfoId');

    return BookingDto(
      bookingInfoId: json['bookingInfoId'] as int?,
      photoServiceInfoId: parsedPhotoServiceInfoId, // 여기서 파싱된 값 사용

      // 백엔드 BookingUserListDTO 기준으로 수정
      userProfileId: json['userProfileId']?.toString() ?? '',
      photographerProfileId: json['photographerProfileId']?.toString() ?? '',

      // 날짜/시간 필드명 확인 필요 - 백엔드 응답에 따라 조정
      bookingDate: json['bookingDate']?.toString() ?? '',
      bookingTime: json['bookingTime']?.toString() ?? '',

      // 상태 필드
      status: json['status']?.toString() ?? 'PENDING',

      // 상대방 이름 - 사용자/포토그래퍼에 따라 달라짐
      // 백엔드 응답 구조에 따라 필드명 조정 필요
      otherName: (json['photographerName'] ??
          json['photographerNickname'] ??
          json['userName'] ??
          json['userNickname'] ??
          json['businessName']) as String?,

      // 서비스 정보 - 백엔드 BookingUserListDTO 필드명에 맞게 수정
      serviceName: (json['title'] ??
          json['serviceName'] ??
          json['serviceTitle']) as String?,

      // 가격 정보
      price: json['price'] as int?,

      // 리뷰/평점 정보
      rating:
          (json['review'] ?? json['rating'] ?? json['reviewScore'])?.toDouble(),

      // 이미지 정보 - 백엔드 응답 필드명에 맞게 조정
      imageUrl: (json['photoServiceImageData'] ??
          json['imageUrl'] ??
          json['imageData']) as String?,
    );
  }
}

/// DTO를 모델로 변환하는 클래스 (Mapper)
/// UI에 필요한 BookingListItem 모델로 변환하는 역할을 수행
class BookingMapper {
  /// BookingDto를 BookingListItem으로 변환 (사용자 관점)
  static BookingListItem toUserBookingListItem(BookingDto dto,
      {required int photographerUserId}) {
    final bookingDateTime = _parseDateTime(dto.bookingDate, dto.bookingTime);
    final photoService = _createPhotoService(dto, photographerUserId);

    return BookingListItem(
      bookingInfoId: dto.bookingInfoId,
      otherPartyProfileId: int.tryParse(dto.photographerProfileId) ?? 0,
      otherPartyName: dto.otherName ?? '포토그래퍼',
      bookingDateTime: bookingDateTime,
      status: _parseStatus(dto.status),
      photoService: photoService,
    );
  }

  /// BookingDto를 BookingListItem으로 변환 (포토그래퍼 관점)
  static BookingListItem toPhotographerBookingListItem(BookingDto dto,
      {required int photographerUserId}) {
    final bookingDateTime = _parseDateTime(dto.bookingDate, dto.bookingTime);
    final photoService = _createPhotoService(dto, photographerUserId);

    return BookingListItem(
      bookingInfoId: dto.bookingInfoId,
      otherPartyProfileId: int.tryParse(dto.userProfileId) ?? 0,
      otherPartyName: dto.otherName ?? '사용자',
      bookingDateTime: bookingDateTime,
      status: _parseStatus(dto.status),
      photoService: photoService,
    );
  }

  /// PhotoService 생성 로직을 별도 메서드로 분리 (코드 중복 제거)
  static PhotoService? _createPhotoService(
      BookingDto dto, int photographerUserId) {
    if (dto.serviceName != null && dto.price != null) {
      return PhotoService(
        id: dto.photoServiceInfoId ??
            0, // 수정된 부분: BookingDto의 photoServiceInfoId 사용
        photographerId: int.tryParse(dto.photographerProfileId) ?? 0,
        photographerUserId: photographerUserId, // 여기에 값 전달
        title: dto.serviceName!,
        imageUrl: dto.imageUrl ?? '',
        categories: [],
        price: dto.price!,
        rating: dto.rating ?? 0.0,
        reviewCount: 0,
      );
    }
    return null;
  }

  /// 공통 날짜/시간 파싱 로직 - 백엔드 응답 형식에 맞게 개선
  static DateTime _parseDateTime(String date, String time) {
    try {
      // 백엔드에서 LocalDate, LocalTime으로 반환할 가능성
      // 다양한 형식 지원
      if (date.isNotEmpty && time.isNotEmpty) {
        // ISO 형식: 2024-01-15T14:30:00
        final dateTimeString = '${date}T$time';
        return DateTime.parse(dateTimeString);
      } else if (date.isNotEmpty) {
        // 날짜만 있는 경우
        final parsedDate = DateTime.parse(date);
        return parsedDate;
      }
    } catch (e) {
      print('날짜 파싱 실패: $date $time, 오류: $e');
    }

    return DateTime.now();
  }

  /// 공통 상태 변환 로직 - 백엔드 BookingStatus enum과 일치
  static BookingStatus _parseStatus(String serverStatus) {
    switch (serverStatus.toUpperCase()) {
      case 'PENDING':
        return BookingStatus.PENDING;
      case 'CONFIRMED':
        return BookingStatus.CONFIRMED;
      case 'CANCELED':
      case 'CANCELLED': // 백엔드에서 CANCELLED로 올 가능성도 고려
        return BookingStatus.CANCELED;
      case 'COMPLETED':
        return BookingStatus.COMPLETED;
      case 'REVIEWED':
        return BookingStatus.REVIEWED;
      default:
        print('알 수 없는 상태: $serverStatus, PENDING으로 처리');
        return BookingStatus.PENDING;
    }
  }
}
