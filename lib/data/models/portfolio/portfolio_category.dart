class PortfolioCategory {
  final int categoryId;
  final String categoryName;
  final int? parentId;
  final String? parentName;
  final int sortOrder;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const PortfolioCategory({
    required this.categoryId,
    required this.categoryName,
    this.parentId,
    this.parentName,
    required this.sortOrder,
    required this.isActive,
    required this.createdAt,
    this.updatedAt,
  });

  // 서버 응답을 위한 factory (JSON 파싱용)
  factory PortfolioCategory.fromJson(Map<String, dynamic> json) {
    return PortfolioCategory(
      categoryId: json['portfolioCategoryId'] ?? json['categoryId'],
      categoryName: json['categoryName'] ?? '',
      parentId: json['parentId'],
      parentName: json['parentName'],
      sortOrder: json['sortOrder'] ?? 0,
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  // 서버 전송을 위한 JSON 변환
  Map<String, dynamic> toJson() {
    return {
      'categoryName': categoryName,
      'parentId': parentId,
      'sortOrder': sortOrder,
      'isActive': isActive,
    };
  }

  // copyWith 메서드
  PortfolioCategory copyWith({
    int? categoryId,
    String? categoryName,
    int? parentId,
    String? parentName,
    int? sortOrder,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PortfolioCategory(
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      parentId: parentId ?? this.parentId,
      parentName: parentName ?? this.parentName,
      sortOrder: sortOrder ?? this.sortOrder,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // 루트 카테고리인지 확인
  bool get isRoot => parentId == null;

  // 활성 카테고리인지 확인
  bool get isActiveCategory => isActive;

  @override
  String toString() {
    return 'PortfolioCategory(id: $categoryId, name: $categoryName, parentId: $parentId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PortfolioCategory && other.categoryId == categoryId;
  }

  @override
  int get hashCode => categoryId.hashCode;
}
