import 'package:flutter/material.dart';
import '../../../../../../data/models/photo_service/photo_service.dart';

class ServiceImageSection extends StatelessWidget {
  final PhotoService service;
  final double height;

  const ServiceImageSection({
    super.key,
    required this.service,
    this.height = 250.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[200],
      ),
      child: _buildImage(),
    );
  }

  Widget _buildImage() {
    if (service.imageUrl.isEmpty) {
      return _buildPlaceholder();
    }

    if (service.imageUrl.startsWith('http')) {
      return Image.network(
        service.imageUrl,
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

    // 로컬 이미지나 asset 처리
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: const Center(
        child: Icon(
          Icons.camera_alt,
          size: 60,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      color: Colors.grey[200],
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
