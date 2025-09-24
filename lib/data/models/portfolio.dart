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
  // 서버 응답을 위한 factory (JSON 파싱용) - 서버 구조에 맞게 수정
  factory Portfolio.fromJson(Map<String, dynamic> json) {
    print('=== Portfolio.fromJson 디버깅 ===');
    print('입력 JSON 키들: ${json.keys.toList()}');

    // 이미지 URL 처리: images 배열에서 imageUrl 추출
    final List<String> imageUrls = [];

    // 서버 응답의 images 배열 처리
    if (json['images'] != null && json['images'] is List) {
      final imagesList = json['images'] as List;
      print('images 배열 길이: ${imagesList.length}');

      for (var image in imagesList) {
        if (image is Map<String, dynamic> && image['imageUrl'] != null) {
          final imageUrl = image['imageUrl'].toString();
          if (imageUrl.isNotEmpty) {
            imageUrls.add(imageUrl);
            print('이미지 URL 추가: $imageUrl');
          }
        }
      }
    }

    // 썸네일 중복 체크 부분 수정
    if (json['thumbnailUrl'] != null &&
        json['thumbnailUrl'].toString().isNotEmpty) {
      final thumbnailUrl = json['thumbnailUrl'].toString();
      print('썸네일 URL 체크: $thumbnailUrl');
      print('기존 이미지 URLs: $imageUrls');
      print('중복 여부: ${imageUrls.contains(thumbnailUrl)}');

      if (!imageUrls.contains(thumbnailUrl)) {
        // imageUrls.insert(0, thumbnailUrl);
        print('썸네일 URL 추가됨');
      } else {
        print('썸네일 URL 이미 존재하여 추가하지 않음');
      }
    }
    print('최종 imageUrls 개수: ${imageUrls.length}');

    // 안전한 필드 추출
    final portfolioId = json['portfolioId']?.toString() ?? '';
    final title = json['title']?.toString() ?? '';
    final description = json['description']?.toString() ?? '';
    final thumbnailUrl = json['thumbnailUrl']?.toString() ?? '';
    final photographerId = json['photographerId']?.toString() ?? '';
    final photographerName = json['photographerName']?.toString();
    final photographerUserId = json['photographerUserId']?.toString() ?? '';
    final likes = json['likeCount'] ?? json['likes'] ?? 0;

    print('파싱된 데이터:');
    print('- portfolioId: $portfolioId');
    print('- title: $title');
    print('- photographerId: $photographerId');
    print('- photographerUserId: $photographerUserId');
    print('- likes: $likes');

    // 날짜 처리 (안전하게)
    DateTime createdAt;
    DateTime? updatedAt;

    try {
      createdAt = json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now();
    } catch (e) {
      print('createdAt 파싱 실패: ${json['createdAt']}, 기본값 사용');
      createdAt = DateTime.now();
    }

    try {
      updatedAt = json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'].toString())
          : null;
    } catch (e) {
      print('updatedAt 파싱 실패: ${json['updatedAt']}, null 사용');
      updatedAt = null;
    }

    // 카테고리 처리 (현재 서버 응답에 없으므로 빈 배열)
    final List<String> categories = [];

    // portfolioMaps가 있다면 처리 (향후 확장 대비)
    if (json['portfolioMaps'] != null && json['portfolioMaps'] is List) {
      final mapsList = json['portfolioMaps'] as List;
      for (var map in mapsList) {
        if (map is Map<String, dynamic> &&
            map['category'] != null &&
            map['category']['name'] != null) {
          categories.add(map['category']['name'].toString());
        }
      }
    }

    print('카테고리 개수: ${categories.length}');
    print('=== Portfolio.fromJson 완료 ===');

    return Portfolio(
      id: portfolioId,
      title: title,
      description: description,
      thumbnailUrl: thumbnailUrl,
      imageUrls: imageUrls,
      categories: categories,
      likes: likes,
      createdAt: createdAt,
      updatedAt: updatedAt,
      photographerProfileId: photographerId,
      photographerName: photographerName,
      photographerUserId: photographerUserId,
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
