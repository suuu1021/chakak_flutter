class BannerDto {
  final int id;
  final String title;
  final String? subtitle;
  final String imageUrl;
  final String? linkUrl;
  final bool isActive;
  final String createdAt;
  final String? expiresAt;

  BannerDto({
    required this.id,
    required this.title,
    this.subtitle,
    required this.imageUrl,
    this.linkUrl,
    this.isActive = true,
    required this.createdAt,
    this.expiresAt,
  });

  factory BannerDto.fromJson(Map<String, dynamic> json) {
    return BannerDto(
      id: json['id'],
      title: json['title'],
      subtitle: json['subtitle'],
      imageUrl: json['image_url'],
      linkUrl: json['link_url'],
      isActive: json['is_active'] ?? true,
      createdAt: json['created_at'],
      expiresAt: json['expires_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'image_url': imageUrl,
      'link_url': linkUrl,
      'is_active': isActive,
      'created_at': createdAt,
      'expires_at': expiresAt,
    };
  }
}
