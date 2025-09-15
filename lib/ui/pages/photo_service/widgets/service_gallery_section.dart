import 'package:flutter/material.dart';
import '../../../../../../_core/constants/app_sizes.dart';
import '../../../../../../data/models/photo_service/photo_service.dart';

class ServiceGallerySection extends StatelessWidget {
  final PhotoService service;
  final int defaultImageCount;

  const ServiceGallerySection({
    super.key,
    required this.service,
    this.defaultImageCount = 5,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitle(),
          const SizedBox(height: AppSizes.spacing12),
          _buildGallery(),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return const Text(
      '포트폴리오',
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildGallery() {
    final portfolioImages = _getDisplayImages();

    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: portfolioImages.length,
        itemBuilder: (context, index) {
          return Container(
            width: 120,
            margin: EdgeInsets.only(
              right: index < portfolioImages.length - 1 ? AppSizes.spacing8 : 0,
            ),
            child: _buildGalleryItem(portfolioImages[index], index),
          );
        },
      ),
    );
  }

  Widget _buildGalleryItem(String imageUrl, int index) {
    return GestureDetector(
      onTap: () => _onImageTap(imageUrl, index),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: _buildImage(imageUrl),
        ),
      ),
    );
  }

  Widget _buildImage(String imageUrl) {
    if (imageUrl.isEmpty || !imageUrl.startsWith('http')) {
      return _buildPlaceholder();
    }

    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return _buildLoadingIndicator();
      },
      errorBuilder: (context, error, stackTrace) {
        return _buildPlaceholder();
      },
    );
  }

  Widget _buildPlaceholder() {
    return const Center(
      child: Icon(
        Icons.image,
        size: 30,
        color: Colors.grey,
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }

  List<String> _getDisplayImages() {
    if (service.portfolioImages.isNotEmpty) {
      return service.portfolioImages;
    }

    // 포트폴리오 이미지가 없으면 빈 플레이스홀더 생성
    return List.generate(defaultImageCount, (index) => '');
  }

  void _onImageTap(String imageUrl, int index) {
    // TODO: 이미지 상세보기 또는 갤러리 뷰어 구현
    print('포트폴리오 이미지 탭: $index, URL: $imageUrl');
  }
}
