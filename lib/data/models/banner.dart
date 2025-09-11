import '../dtos/banner_dto.dart';

class BannerItem {
  final int id;
  final String title;
  final String? subtitle;
  final String imageUrl;
  final String? linkUrl;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? expiresAt;

  BannerItem({
    required this.id,
    required this.title,
    this.subtitle,
    required this.imageUrl,
    this.linkUrl,
    this.isActive = true,
    required this.createdAt,
    this.expiresAt,
  });

  factory BannerItem.fromDto(BannerDto dto) {
    return BannerItem(
      id: dto.id,
      title: dto.title,
      subtitle: dto.subtitle,
      imageUrl: dto.imageUrl,
      linkUrl: dto.linkUrl,
      isActive: dto.isActive,
      createdAt: DateTime.parse(dto.createdAt),
      expiresAt: dto.expiresAt != null ? DateTime.parse(dto.expiresAt!) : null,
    );
  }

  BannerDto toDto() {
    return BannerDto(
      id: id,
      title: title,
      subtitle: subtitle,
      imageUrl: imageUrl,
      linkUrl: linkUrl,
      isActive: isActive,
      createdAt: createdAt.toIso8601String(),
      expiresAt: expiresAt?.toIso8601String(),
    );
  }

  BannerItem copyWith({
    int? id,
    String? title,
    String? subtitle,
    String? imageUrl,
    String? linkUrl,
    bool? isActive,
    DateTime? createdAt,
    DateTime? expiresAt,
  }) {
    return BannerItem(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      imageUrl: imageUrl ?? this.imageUrl,
      linkUrl: linkUrl ?? this.linkUrl,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }
}
