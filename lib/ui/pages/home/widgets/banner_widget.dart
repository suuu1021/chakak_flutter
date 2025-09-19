import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../../../data/models/banner.dart';
import '../../../../provider/global/banner/banner_notifier.dart';

class BannerWidget extends ConsumerStatefulWidget {
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
  ConsumerState<BannerWidget> createState() => _BannerWidgetState();
}

class _BannerWidgetState extends ConsumerState<BannerWidget> {
  final CarouselSliderController _carouselSliderController =
      CarouselSliderController();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(bannerProvider.notifier).loadBanners();
    });
  }

  void _onBannerTap(BannerItem banner) {
    ref.read(bannerProvider.notifier).trackBannerClick(banner.id);
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
    final bannerState = ref.watch(bannerProvider);

    return Container(
      margin: widget.margin,
      height: widget.height,
      child: _buildContent(bannerState),
    );
  }

  Widget _buildContent(BannerState state) {
    if (state.isLoading) {
      return _buildLoadingBanner();
    }

    if (state.error != null || state.banners.isEmpty) {
      return _buildErrorBanner();
    }

    return _buildBannerSlider(state.banners);
  }

  Widget _buildLoadingBanner() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

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
            const SizedBox(height: 8),
            Text(
              '배너를 불러올 수 없습니다',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => ref.read(bannerProvider.notifier).loadBanners(),
              child: const Text('다시 시도'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBannerSlider(List<BannerItem> banners) {
    return Stack(
      children: [
        CarouselSlider.builder(
          carouselController: _carouselSliderController,
          itemCount: banners.length,
          itemBuilder: (BuildContext context, int index, int realIndex) {
            final banner = banners[index];
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
        if (widget.showIndicators && banners.length > 1)
          Positioned(
            bottom: 12,
            right: 16,
            child: _buildIndicators(banners.length),
          ),
      ],
    );
  }

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
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          offset: Offset(1, 1),
                          blurRadius: 2,
                          color: Colors.black54,
                        ),
                      ],
                    ),
                  ),
                  if (banner.subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      banner.subtitle!,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                        shadows: const [
                          Shadow(
                            offset: Offset(1, 1),
                            blurRadius: 2,
                            color: Colors.black54,
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

  Widget _buildIndicators(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
          count,
          (index) => Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.symmetric(horizontal: 2),
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
