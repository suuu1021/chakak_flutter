// data/models/price_option.dart

class PriceOption {
  final String name;
  final int price;
  final String duration;
  final String photoCount;
  final String editingLevel;
  final List<String> features;

  const PriceOption({
    required this.name,
    required this.price,
    required this.duration,
    required this.photoCount,
    required this.editingLevel,
    required this.features,
  });

  factory PriceOption.fromJson(Map<String, dynamic> json) {
    return PriceOption(
      name: json['title'] as String, // title → name
      price: json['price'] as int,
      duration: '${json['shootingDuration']}분', // int → String 변환
      photoCount: '${json['participantCount']}명', // int → String 변환
      editingLevel: json['isMakeupService'] == true
          ? '메이크업 포함'
          : '기본 보정', // boolean → String 변환
      features: [
        json['specialEquipment'] as String, // String을 List로 변환
        if (json['outfitChanges'] != null) '의상 변경 ${json['outfitChanges']}회',
      ],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': name,
      'price': price,
      'shootingDuration': int.parse(duration.replaceAll('분', '')),
      'participantCount': int.parse(photoCount.replaceAll('명', '')),
      'isMakeupService': editingLevel.contains('메이크업'),
      'specialEquipment': features.isNotEmpty ? features.first : '',
      'outfitChanges': features.any((f) => f.contains('의상 변경'))
          ? int.parse(features
              .firstWhere((f) => f.contains('의상 변경'))
              .replaceAll(RegExp(r'[^0-9]'), ''))
          : 1,
    };
  }

  PriceOption copyWith({
    String? name,
    int? price,
    String? duration,
    String? photoCount,
    String? editingLevel,
    List<String>? features,
  }) {
    return PriceOption(
      name: name ?? this.name,
      price: price ?? this.price,
      duration: duration ?? this.duration,
      photoCount: photoCount ?? this.photoCount,
      editingLevel: editingLevel ?? this.editingLevel,
      features: features ?? this.features,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PriceOption &&
        other.name == name &&
        other.price == price &&
        other.duration == duration &&
        other.photoCount == photoCount &&
        other.editingLevel == editingLevel &&
        _listEquals(other.features, features);
  }

  @override
  int get hashCode {
    return Object.hash(
      name,
      price,
      duration,
      photoCount,
      editingLevel,
      features,
    );
  }

  @override
  String toString() {
    return 'PriceOption(name: $name, price: $price, duration: $duration, photoCount: $photoCount, editingLevel: $editingLevel, features: $features)';
  }

  // Helper method for list comparison
  bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (int index = 0; index < a.length; index += 1) {
      if (a[index] != b[index]) return false;
    }
    return true;
  }

  // 편의 메서드들
  String get formattedPrice =>
      '₩${price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
  bool get isBasic =>
      name.toLowerCase().contains('basic') ||
      name.toLowerCase().contains('에센셜');
  bool get isPremium =>
      name.toLowerCase().contains('premium') ||
      name.toLowerCase().contains('프리미엄');
  bool get isSignature =>
      name.toLowerCase().contains('signature') ||
      name.toLowerCase().contains('시그니처');
}
