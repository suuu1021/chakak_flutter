import 'package:flutter/material.dart';
import '../../../../../../_core/constants/app_sizes.dart';
import '../../../../../../data/models/photo_service/photo_service.dart';

class OtherServicesSection extends StatelessWidget {
  final PhotoService service;
  final List<PhotoService>? otherServices;
  final Function(PhotoService)? onServiceTap;

  const OtherServicesSection({
    super.key,
    required this.service,
    this.otherServices,
    this.onServiceTap,
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
          _buildContent(),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return const Text(
      '이 작가의 다른 서비스',
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildContent() {
    if (otherServices == null || otherServices!.isEmpty) {
      return _buildPlaceholder();
    }

    return _buildServicesList();
  }

  Widget _buildPlaceholder() {
    return const Text(
      '다른 서비스들이 여기에 표시됩니다.',
      style: TextStyle(
        fontSize: 14,
        color: Colors.grey,
      ),
    );
  }

  Widget _buildServicesList() {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: otherServices!.length,
        itemBuilder: (context, index) {
          final otherService = otherServices![index];
          return Container(
            width: 200,
            margin: EdgeInsets.only(
              right: index < otherServices!.length - 1 ? AppSizes.spacing12 : 0,
            ),
            child: _buildServiceCard(otherService),
          );
        },
      ),
    );
  }

  Widget _buildServiceCard(PhotoService otherService) {
    return GestureDetector(
      onTap: () => _onServiceTap(otherService),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildServiceImage(otherService),
            _buildServiceInfo(otherService),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceImage(PhotoService otherService) {
    return Container(
      height: 60,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.grey,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
      ),
      child: otherService.imageUrl.startsWith('http')
          ? ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
              child: Image.network(
                otherService.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildImagePlaceholder();
                },
              ),
            )
          : _buildImagePlaceholder(),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: const Center(
        child: Icon(
          Icons.camera_alt,
          size: 20,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildServiceInfo(PhotoService otherService) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.spacing8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              otherService.title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSizes.spacing4),
            Text(
              otherService.priceRange,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onServiceTap(PhotoService otherService) {
    if (onServiceTap != null) {
      onServiceTap!(otherService);
    } else {
      print('다른 서비스 탭 - serviceId: ${otherService.id}');
    }
  }
}
