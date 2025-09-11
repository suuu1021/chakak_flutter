class Portfolio {
  final String id;
  final String title;
  final String description;
  final String category;
  final List<String> imageUrls;
  final int likes;
  final DateTime createdAt;

  const Portfolio({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.imageUrls,
    required this.likes,
    required this.createdAt,
  });

  // Normal portfolio constructor (Named)
  factory Portfolio.create({
    required String title,
    required String description,
    required String category,
    required List<String> imageUrls,
  }) {
    return Portfolio(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title.trim(),
      description: description.trim(),
      category: category,
      imageUrls: imageUrls,
      likes: 0,
      createdAt: DateTime.now(),
    );
  }

  // Time formatting > Util?
  String get formattedDate {
    return '${createdAt.year}.${createdAt.month.toString().padLeft(2, '0')}.${createdAt.day.toString().padLeft(2, '0')}';
  }

  // 첫 번째 이미지 URL (카드에서 사용)
  String get firstImageUrl => imageUrls.isNotEmpty ? imageUrls.first : '';

  // 총 이미지 개수
  int get imageCount => imageUrls.length;

  // Popular portfolio bool
  bool get isPopular {
    return likes >= 100;
  }

  // My portfolio bool (UI checking)
  bool isMyPortfolio(String currentUserId) {
    return id.contains(currentUserId);
  }

  // 샘플 포트폴리오 데이터 목록
  static final List<Portfolio> samplePortfolios = [
    Portfolio(
      id: '1',
      title: '골든 아워 커플 촬영',
      description: '한강에서 진행한 커플 촬영입니다. 자연스러운 포즈와 따뜻한 조명으로 로맨틱한 분위기를 연출했습니다.',
      category: '커플',
      imageUrls: _generateImageUrls(1),
      likes: 127,
      createdAt: DateTime(2024, 3, 15),
    ),
    Portfolio(
      id: '2',
      title: '프로필 촬영 - 비즈니스',
      description: '깔끔하고 전문적인 비즈니스 프로필 촬영입니다. 조명과 구도를 통해 신뢰감 있는 이미지를 표현했습니다.',
      category: '프로필',
      imageUrls: _generateImageUrls(2),
      likes: 89,
      createdAt: DateTime(2024, 3, 10),
    ),
    Portfolio(
      id: '3',
      title: '웨딩 스냅 촬영',
      description: '행복한 순간을 담은 웨딩 촬영입니다. 감동적인 순간들을 자연스럽게 포착했습니다.',
      category: '웨딩',
      imageUrls: _generateImageUrls(3),
      likes: 203,
      createdAt: DateTime(2024, 3, 5),
    ),
    Portfolio(
      id: '4',
      title: '가족 야외 촬영',
      description: '공원에서 진행한 가족 촬영입니다. 아이들의 밝은 모습과 가족의 따뜻한 정을 담았습니다.',
      category: '가족',
      imageUrls: _generateImageUrls(4),
      likes: 156,
      createdAt: DateTime(2024, 2, 28),
    ),
    Portfolio(
      id: '5',
      title: '개인 아티스틱 촬영',
      description: '창의적인 컨셉으로 진행한 개인 촬영입니다. 독특한 조명과 구도로 예술적인 감각을 표현했습니다.',
      category: '아티스틱',
      imageUrls: _generateImageUrls(5),
      likes: 94,
      createdAt: DateTime(2024, 2, 20),
    ),
    Portfolio(
      id: '6',
      title: '브랜딩 제품 촬영',
      description: '제품의 특성을 살린 브랜딩 촬영입니다. 깔끔한 배경과 조명으로 제품의 매력을 부각시켰습니다.',
      category: '제품',
      imageUrls: _generateImageUrls(6),
      likes: 78,
      createdAt: DateTime(2024, 2, 15),
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
