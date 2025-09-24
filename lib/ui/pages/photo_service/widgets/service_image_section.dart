import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../../../../data/models/photo_service/photo_service.dart';
import '../../../../_core/utils/image_utils.dart';

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

    // 여러 이미지가 쉼표로 구분되어 있는 경우 처리
    final imageList = service.imageUrl
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    if (imageList.isEmpty) {
      return _buildPlaceholder();
    }

    // 이미지가 하나만 있는 경우
    if (imageList.length == 1) {
      return _buildSingleImage(imageList[0]);
    }

    // 여러 이미지가 있는 경우 PageView로 스와이프 가능하게
    return PageView.builder(
      itemCount: imageList.length,
      itemBuilder: (context, index) {
        return _buildSingleImage(imageList[index]);
      },
    );
  }

  Widget _buildSingleImage(String imageData) {
    return ImageUtils.buildSafeImage(
      imageData,
      fit: BoxFit.cover,
    );
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
