// lib/data/models/portfolio.dart

class Portfolio {
  final String id; // 클라이언트에서는 String으로 관리
  final String title;
  final String description;
  final String thumbnailUrl; // 대표 이미지 (서버의 thumbnailUrl)
  final List<String> imageUrls; // 포트폴리오 이미지들
  final List<String> categories; // 카테고리 목록 (서버의 portfolioMaps)
  final int likes;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String photographerProfileId; // 서버의 photographerId
  final String? photographerName; // 서버의 photographerName (추가)
  final String photographerUserId;

  const Portfolio({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnailUrl,
    required this.imageUrls,
    required this.categories,
    required this.likes,
    required this.createdAt,
    this.updatedAt,
    required this.photographerProfileId,
    this.photographerName,
    required this.photographerUserId,
  });

  // Normal portfolio constructor (Named)
  factory Portfolio.create({
    required String title,
    required String description,
    required List<String> imageUrls,
    required List<String> categories,
    required String photographerId,
    String? photographerName,
    String? photographerUserId,
  }) {
    return Portfolio(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title.trim(),
      description: description.trim(),
      thumbnailUrl:
          imageUrls.isNotEmpty ? imageUrls.first : '', // 첫 번째 이미지를 썸네일로
      imageUrls: imageUrls,
      categories: categories,
      likes: 0,
      createdAt: DateTime.now(),
      photographerProfileId: photographerId,
      photographerName: photographerName,
      photographerUserId: '0',
    );
  }

  // 서버 응답을 위한 factory (JSON 파싱용) - 서버 구조에 맞게 수정
  factory Portfolio.fromJson(Map<String, dynamic> json) {
    // 이미지 URL 처리: mainImageUrl이 있으면 사용, 없으면 thumbnailUrl 사용
    final List<String> imageUrls = [];
    if (json['mainImageUrl'] != null &&
        json['mainImageUrl'].toString().isNotEmpty) {
      imageUrls.add(json['mainImageUrl'].toString());
    }
    if (json['thumbnailUrl'] != null &&
        json['thumbnailUrl'].toString().isNotEmpty) {
      if (imageUrls.isEmpty ||
          imageUrls.first != json['thumbnailUrl'].toString()) {
        imageUrls.add(json['thumbnailUrl'].toString());
      }
    }

    return Portfolio(
      id: json['portfolioId'].toString(),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      thumbnailUrl: json['thumbnailUrl'] ?? '',
      imageUrls: imageUrls,
      categories: const [], // 서버 응답에 카테고리 정보가 없음
      likes: json['likeCount'] ?? 0,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      photographerProfileId: json['photographerId'].toString(),
      photographerName: json['photographerName'],
      photographerUserId: json['photographerUserId']?.toString() ?? '',
    );
  }

  // 서버 전송을 위한 JSON 변환
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'thumbnailUrl': thumbnailUrl,
      'imageUrls': imageUrls,
      'categories': categories,
      'photographerId': photographerProfileId,
    };
  }

  // Time formatting > Util?
  String get formattedDate {
    return '${createdAt.year}.${createdAt.month.toString().padLeft(2, '0')}.${createdAt.day.toString().padLeft(2, '0')}';
  }

  // 첫 번째 이미지 URL (카드에서 사용) - thumbnailUrl 사용
  String get firstImageUrl => thumbnailUrl.isNotEmpty
      ? thumbnailUrl
      : (imageUrls.isNotEmpty ? imageUrls.first : '');

  // 총 이미지 개수
  int get imageCount => imageUrls.length;

  // 주요 카테고리 (첫 번째 카테고리)
  String get category => categories.isNotEmpty ? categories.first : '기타';

  // Popular portfolio bool
  bool get isPopular {
    return likes >= 100;
  }

  // My portfolio bool (UI checking)
  bool isMyPortfolio(String currentPhotographerId) {
    return photographerProfileId == currentPhotographerId;
  }

  // copyWith 메서드 추가 (수정 시 사용)
  Portfolio copyWith({
    String? id,
    String? title,
    String? description,
    String? thumbnailUrl,
    List<String>? imageUrls,
    List<String>? categories,
    int? likes,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? photographerId,
    String? photographerName,
    String? photographerUserId,
  }) {
    return Portfolio(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      imageUrls: imageUrls ?? this.imageUrls,
      categories: categories ?? this.categories,
      likes: likes ?? this.likes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      photographerProfileId: photographerId ?? photographerProfileId,
      photographerName: photographerName ?? this.photographerName,
      photographerUserId: photographerUserId ?? this.photographerUserId,
    );
  }
}
