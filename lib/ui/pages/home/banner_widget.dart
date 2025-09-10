import 'package:flutter/material.dart';
import 'dart:async';
import 'package:carousel_slider/carousel_slider.dart';

// 배너 데이터 모델
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

  factory BannerItem.fromJson(Map<String, dynamic> json) {
    return BannerItem(
      id: json['id'],
      title: json['title'],
      subtitle: json['subtitle'],
      imageUrl: json['image_url'],
      linkUrl: json['link_url'],
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'])
          : null,
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
      'created_at': createdAt.toIso8601String(),
      'expires_at': expiresAt?.toIso8601String(),
    };
  }
}

// 배너 API 서비스
class BannerApiService {
  static const String baseUrl = 'https://your-api-server.com/api';

  static Future<List<BannerItem>> getActiveBanners() async {
    await Future.delayed(Duration(milliseconds: 500));

    return [
      BannerItem(
        id: 1,
        title: '스페셜 촬영 이벤트',
        subtitle: '지금 예약하면 50% 할인!',
        imageUrl:
            'https://via.placeholder.com/400x200/FF6B6B/FFFFFF?text=이벤트+배너',
        linkUrl: '/event/special-photo',
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(Duration(days: 30)),
      ),
      BannerItem(
        id: 2,
        title: '웨딩 촬영 패키지',
        subtitle: '평생 간직할 순간을 담아드립니다',
        imageUrl:
            'https://via.placeholder.com/400x200/4ECDC4/FFFFFF?text=웨딩+패키지',
        linkUrl: '/services/wedding',
        createdAt: DateTime.now(),
      ),
      BannerItem(
        id: 3,
        title: '프로필 촬영',
        subtitle: '당신만의 특별한 모습을',
        imageUrl:
            'https://via.placeholder.com/400x200/45B7D1/FFFFFF?text=프로필+촬영',
        linkUrl: '/services/profile',
        createdAt: DateTime.now(),
      ),
    ];
  }

  static Future<void> trackBannerClick(int bannerId) async {
    print('배너 클릭 추적: $bannerId');
  }
}

// 배너 위젯 (carousel_slider 사용)
class BannerWidget extends StatefulWidget {
  final double height;
  final Duration autoSlideInterval;
  final bool showIndicators;
  final Function(BannerItem)? onBannerTap;
  final EdgeInsets margin;

  const BannerWidget({
    Key? key,
    this.height = 180.0,
    this.autoSlideInterval = const Duration(seconds: 3),
    this.showIndicators = true,
    this.onBannerTap,
    this.margin = const EdgeInsets.all(16.0),
  }) : super(key: key);

  @override
  _BannerWidgetState createState() => _BannerWidgetState();
}

class _BannerWidgetState extends State<BannerWidget> {
  final CarouselSliderController _carouselSliderController =
      CarouselSliderController();
  int _currentIndex = 0;
  List<BannerItem> _banners = [];
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadBanners();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // 배너 데이터 로드 (기존 코드와 동일)
  Future<void> _loadBanners() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });

      final banners = await BannerApiService.getActiveBanners();

      setState(() {
        _banners = banners;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
      print('배너 로드 실패: $e');
    }
  }

  // 배너 클릭 처리
  void _onBannerTap(BannerItem banner) {
    BannerApiService.trackBannerClick(banner.id);
    if (widget.onBannerTap != null) {
      widget.onBannerTap!(banner);
    } else {
      if (banner.linkUrl != null) {
        print('배너 링크로 이동: ${banner.linkUrl}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: widget.margin,
      height: widget.height,
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return _buildLoadingBanner();
    }

    if (_hasError || _banners.isEmpty) {
      return _buildErrorBanner();
    }

    return _buildBannerSlider();
  }

  // 로딩 상태 배너
  Widget _buildLoadingBanner() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  // 에러 상태 배너
  Widget _buildErrorBanner() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 40, color: Colors.grey[400]),
            SizedBox(height: 8),
            Text(
              '배너를 불러올 수 없습니다',
              style: TextStyle(color: Colors.grey[600]),
            ),
            SizedBox(height: 8),
            TextButton(
              onPressed: _loadBanners,
              child: Text('다시 시도'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBannerSlider() {
    return Stack(
      children: [
        CarouselSlider.builder(
          carouselController: _carouselSliderController,
          itemCount: _banners.length,
          itemBuilder: (BuildContext context, int index, int realIndex) {
            final banner = _banners[index];
            return _buildBannerItem(banner);
          },
          options: CarouselOptions(
            height: widget.height,
            autoPlay: true,
            autoPlayInterval: widget.autoSlideInterval,
            enlargeCenterPage: false,
            viewportFraction: 1.0,
            onPageChanged: (index, reason) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
        ),

        // 인디케이터
        if (widget.showIndicators && _banners.length > 1)
          Positioned(
            bottom: 12,
            right: 16,
            child: _buildIndicators(),
          ),
      ],
    );
  }

  // 개별 배너 아이템
  Widget _buildBannerItem(BannerItem banner) {
    return GestureDetector(
      onTap: () => _onBannerTap(banner),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey[200],
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                banner.imageUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: Colors.grey[200],
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[200],
                    child: Center(
                      child: Icon(
                        Icons.image_not_supported,
                        color: Colors.grey[400],
                        size: 48,
                      ),
                    ),
                  );
                },
              ),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.3),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 20,
              bottom: 20,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    banner.title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          offset: Offset(1, 1),
                          blurRadius: 2,
                          color: Colors.black.withOpacity(0.5),
                        ),
                      ],
                    ),
                  ),
                  if (banner.subtitle != null) ...[
                    SizedBox(height: 4),
                    Text(
                      banner.subtitle!,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                        shadows: [
                          Shadow(
                            offset: Offset(1, 1),
                            blurRadius: 2,
                            color: Colors.black.withOpacity(0.5),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 인디케이터
  Widget _buildIndicators() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
          _banners.length,
          (index) => Container(
            width: 6,
            height: 6,
            margin: EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _currentIndex == index
                  ? Colors.white
                  : Colors.white.withOpacity(0.4),
            ),
          ),
        ),
      ),
    );
  }
}
