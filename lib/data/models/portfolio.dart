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
  final String photographerId; // 서버의 photographerProfile.id

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
    required this.photographerId,
  });

  // Normal portfolio constructor (Named)
  factory Portfolio.create({
    required String title,
    required String description,
    required List<String> imageUrls,
    required List<String> categories,
    required String photographerId,
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
      photographerId: photographerId,
    );
  }

  // 서버 응답을 위한 factory (JSON 파싱용)
  factory Portfolio.fromJson(Map<String, dynamic> json) {
    return Portfolio(
      id: json['portfolioId'].toString(),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      thumbnailUrl: json['thumbnailUrl'] ?? '',
      imageUrls: (json['portfolioImages'] as List<dynamic>?)
              ?.map((img) => img['imageUrl'] as String)
              .toList() ??
          [],
      categories: (json['portfolioMaps'] as List<dynamic>?)
              ?.map((map) => map['category']['name'] as String)
              .toList() ??
          [],
      likes: json['likes'] ?? 0,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      photographerId: json['photographerProfile']['id'].toString(),
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
      'photographerId': photographerId,
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
    return photographerId == currentPhotographerId;
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
      photographerId: photographerId ?? this.photographerId,
    );
  }

  // 샘플 포트폴리오 데이터 목록
  static final List<Portfolio> samplePortfolios = [
    Portfolio(
      id: '1',
      title: '골든 아워 커플 촬영',
      description: '한강에서 진행한 커플 촬영입니다. 자연스러운 포즈와 따뜻한 조명으로 로맨틱한 분위기를 연출했습니다.',
      thumbnailUrl: 'https://picsum.photos/id/10/200/150',
      imageUrls: _generateImageUrls(1),
      categories: ['커플', '야외'],
      likes: 127,
      createdAt: DateTime(2024, 3, 15),
      photographerId: 'test-user-123',
    ),
    Portfolio(
      id: '2',
      title: '프로필 촬영 - 비즈니스',
      description: '깔끔하고 전문적인 비즈니스 프로필 촬영입니다. 조명과 구도를 통해 신뢰감 있는 이미지를 표현했습니다.',
      thumbnailUrl: 'https://picsum.photos/id/20/200/150',
      imageUrls: _generateImageUrls(2),
      categories: ['프로필', '비즈니스'],
      likes: 89,
      createdAt: DateTime(2024, 3, 10),
      photographerId: 'other-user-456',
    ),
    Portfolio(
      id: '3',
      title: '웨딩 스냅 촬영',
      description: '행복한 순간을 담은 웨딩 촬영입니다. 감동적인 순간들을 자연스럽게 포착했습니다.',
      thumbnailUrl: 'https://picsum.photos/id/30/200/150',
      imageUrls: _generateImageUrls(3),
      categories: ['웨딩', '실내'],
      likes: 203,
      createdAt: DateTime(2024, 3, 5),
      photographerId: 'test-user-123',
    ),
    Portfolio(
      id: '4',
      title: '가족 야외 촬영',
      description: '공원에서 진행한 가족 촬영입니다. 아이들의 밝은 모습과 가족의 따뜻한 정을 담았습니다.',
      thumbnailUrl: 'https://picsum.photos/id/40/200/150',
      imageUrls: _generateImageUrls(4),
      categories: ['가족', '야외'],
      likes: 156,
      createdAt: DateTime(2024, 2, 28),
      photographerId: 'other-user-456',
    ),
    Portfolio(
      id: '5',
      title: '개인 아티스틱 촬영',
      description: '창의적인 컨셉으로 진행한 개인 촬영입니다. 독특한 조명과 구도로 예술적인 감각을 표현했습니다.',
      thumbnailUrl: 'https://picsum.photos/id/50/200/150',
      imageUrls: _generateImageUrls(5),
      categories: ['아티스틱', '실내'],
      likes: 94,
      createdAt: DateTime(2024, 2, 20),
      photographerId: 'test-user-123',
    ),
    Portfolio(
      id: '6',
      title: '브랜딩 제품 촬영',
      description: '제품의 특성을 살린 브랜딩 촬영입니다. 깔끔한 배경과 조명으로 제품의 매력을 부각시켰습니다.',
      thumbnailUrl: 'https://picsum.photos/id/60/200/150',
      imageUrls: _generateImageUrls(6),
      categories: ['제품', '브랜딩'],
      likes: 78,
      createdAt: DateTime(2024, 2, 15),
      photographerId: 'other-user-456',
    ),
  ];

  // 포트폴리오별 3개 이미지 URL 생성
  static List<String> _generateImageUrls(int portfolioId) {
    final baseId = portfolioId * 10;
    return [
      'https://picsum.photos/id/${baseId}/200/150',
      'https://picsum.photos/id/${baseId + 1}/200/150',
      'https://picsum.photos/id/${baseId + 2}/200/150',
    ];
  }
}
