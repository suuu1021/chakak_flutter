class Portfolio {
  final String id;
  final String title;
  final String description;
  final String thumbnailUrl;
  final List<String> imageUrls;
  final List<String> categories;
  final int likes;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String photographerProfileId;
  final String? photographerName;
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
      thumbnailUrl: imageUrls.isNotEmpty ? imageUrls.first : '',
      imageUrls: imageUrls,
      categories: categories,
      likes: 0,
      createdAt: DateTime.now(),
      photographerProfileId: photographerId,
      photographerName: photographerName,
      photographerUserId: '0',
    );
  }

  factory Portfolio.fromJson(Map<String, dynamic> json) {
    print('=== Portfolio.fromJson 디버깅 ===');
    print('입력 JSON 키들: ${json.keys.toList()}');
    final List<String> imageUrls = [];
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

    if (json['thumbnailUrl'] != null &&
        json['thumbnailUrl'].toString().isNotEmpty) {
      final thumbnailUrl = json['thumbnailUrl'].toString();
      print('썸네일 URL 체크: $thumbnailUrl');
      print('기존 이미지 URLs: $imageUrls');
      print('중복 여부: ${imageUrls.contains(thumbnailUrl)}');

      if (!imageUrls.contains(thumbnailUrl)) {
        imageUrls.insert(0, thumbnailUrl);
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

    // 날짜 처리
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

    // 카테고리 처리
    final List<String> categories = [];

    // portfolioMaps가 있다면 처리
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

  String get formattedDate {
    return '${createdAt.year}.${createdAt.month.toString().padLeft(2, '0')}.${createdAt.day.toString().padLeft(2, '0')}';
  }

  String get firstImageUrl => thumbnailUrl.isNotEmpty
      ? thumbnailUrl
      : (imageUrls.isNotEmpty ? imageUrls.first : '');

  int get imageCount => imageUrls.length;

  String get category => categories.isNotEmpty ? categories.first : '기타';

  bool get isPopular {
    return likes >= 100;
  }

  bool isMyPortfolio(String currentPhotographerId) {
    return photographerProfileId == currentPhotographerId;
  }

  // copyWith 메서드 추가
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
