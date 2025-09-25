import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../_core/constants/app_sizes.dart';
import '../../../../data/models/portfolio.dart';
import '../../../../provider/global/portfolio/portfolio_notifier.dart';
import '../../portfolio/portfolio_detail_page.dart';

class ServiceGallerySection extends ConsumerStatefulWidget {
  final int photographerId;
  final int defaultImageCount;

  const ServiceGallerySection({
    super.key,
    required this.photographerId,
    this.defaultImageCount = 5,
  });

  @override
  ConsumerState<ServiceGallerySection> createState() =>
      _ServiceGallerySectionState();
}

class _ServiceGallerySectionState extends ConsumerState<ServiceGallerySection> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(portfolioProvider.notifier)
          .loadPortfoliosByPhotographer(widget.photographerId.toString());
    });
  }

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
    final portfolioState = ref.watch(portfolioProvider);

    if (portfolioState.isLoading) {
      return SizedBox(
        height: 120,
        child: _buildLoadingIndicator(),
      );
    }

    if (portfolioState.errorMessage != null) {
      return SizedBox(
        height: 120,
        child: _buildErrorWidget(),
      );
    }
    final portfolioImages = portfolioState.portfolios
        .expand((portfolio) => portfolio.imageUrls)
        .toList();

    if (portfolioImages.isEmpty) {
      return SizedBox(
        height: 120,
        child: Center(
          child: Text(
            '포트폴리오 이미지가 없습니다',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

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

  Widget _buildErrorWidget() {
    return const Center(
      child: Text(
        '포트폴리오를 불러올 수 없습니다',
        style: TextStyle(color: Colors.grey),
      ),
    );
  }

  void _onImageTap(String imageUrl, int index) {
    try {
      final portfolioState = ref.read(portfolioProvider);
      Portfolio? targetPortfolio;
      for (final portfolio in portfolioState.portfolios) {
        if (portfolio.photographerProfileId ==
                widget.photographerId.toString() &&
            portfolio.imageUrls.contains(imageUrl)) {
          targetPortfolio = portfolio;
          break;
        }
      }

      if (targetPortfolio != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                PortfolioDetailPage(portfolioId: targetPortfolio!.id),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('포트폴리오 정보를 찾을 수 없습니다'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('포트폴리오를 열 수 없습니다'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}
