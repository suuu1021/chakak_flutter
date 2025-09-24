import '../../models/review.dart'; // Review, AuthorInfo 모델 임포트
import 'package:flutter/foundation.dart'; // For kDebugMode and print

class ReviewDto {
  final String id;
  final String reviewerId;
  final String? serviceId;
  final int? bookingId;
  final double rating;
  final String? reviewContent;
  final DateTime createdAt;
  final String? reviewerNickname;
  final String? thumbnailUrl;

  ReviewDto({
    required this.id,
    required this.reviewerId,
    this.serviceId,
    this.bookingId,
    required this.rating,
    this.reviewContent,
    required this.createdAt,
    this.reviewerNickname,
    this.thumbnailUrl,
  });

  factory ReviewDto.fromJson(Map<String, dynamic> json) {
    if (kDebugMode) {
      print("[ReviewDto.fromJson] Attempting to parse JSON: $json");
    }

    String parsedId = json['reviewId']?.toString() ?? '0';
    double parsedRating = (json['rating'] as num?)?.toDouble() ?? 0.0;
    String? parsedContent = json['content'] as String? ?? json['reviewContent'] as String?;
    String? parsedThumbnailUrl = json['thumbnailUrl'] as String?;
    
    DateTime parsedCreatedAt;
    String? createdAtString = json['createdAt'] as String?;
    if (createdAtString != null) {
      try {
        parsedCreatedAt = DateTime.parse(createdAtString);
      } catch (e) {
        if (kDebugMode) {
          print("[ReviewDto.fromJson] Error parsing 'createdAt' string: \"$createdAtString\". Error: $e. Falling back to DateTime.now().");
        }
        parsedCreatedAt = DateTime.now();
      }
    } else {
      if (kDebugMode) {
        print("[ReviewDto.fromJson] 'createdAt' field is null. Falling back to DateTime.now().");
      }
      parsedCreatedAt = DateTime.now();
    }

    String finalReviewerId = '0';
    String? finalReviewerNickname;
    final dynamic authorField = json['author'];

    if (authorField is Map<String, dynamic>) {
        finalReviewerId = authorField['userId']?.toString() ?? '0';
        finalReviewerNickname = authorField['nickname'] as String?;
    } else if (json['userId'] != null) { 
        finalReviewerId = json['userId']?.toString() ?? '0'; 
        finalReviewerNickname = (json['nickname'] ?? json['reviewerNickname']) as String?; // 수정된 부분
        if (authorField != null && !(authorField is Map) && kDebugMode) {
            print("[ReviewDto.fromJson] Warning: 'author' field was present but not a Map (type: ${authorField.runtimeType}, value: '$authorField'). Top-level 'userId' was used.");
        }
    } else if (authorField is String) {
        finalReviewerNickname = authorField;
        if (kDebugMode) {
            print("[ReviewDto.fromJson] Warning: 'author' field is a String ('$authorField') and top-level 'userId' is absent. Using string as nickname; ID for reviewer remains default ('$finalReviewerId').");
        }
    } else {
         if (kDebugMode) {
            // print("[ReviewDto.fromJson] No parsable author information found. Reviewer ID will be default ('0') and nickname null.");
         }
    }
    
    return ReviewDto(
      id: parsedId,
      reviewerId: finalReviewerId,
      serviceId: json['serviceId']?.toString(),
      bookingId: json['bookingId'] as int?,
      rating: parsedRating,
      reviewContent: parsedContent,
      createdAt: parsedCreatedAt,
      reviewerNickname: finalReviewerNickname,
      thumbnailUrl: parsedThumbnailUrl,
    );
  }

  Review toModel() {
    return Review(
      reviewId: int.tryParse(id) ?? 0,
      serviceId: serviceId, // <<<<<<< serviceId 전달 추가
      rating: rating,
      content: reviewContent ?? '',
      thumbnailUrl: thumbnailUrl,
      author: AuthorInfo(
        userId: int.tryParse(reviewerId) ?? 0, 
        nickname: reviewerNickname ?? "사용자", 
      ),
      createdAt: createdAt.toIso8601String(),
    );
  }
}
