import 'package:flutter/material.dart';
import '../../../../../../_core/constants/app_sizes.dart';
import '../../../../../../data/models/photo_service/photo_service.dart';

class ServiceDescriptionSection extends StatelessWidget {
  final PhotoService service;

  const ServiceDescriptionSection({
    super.key,
    required this.service,
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
          _buildDescription(),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return const Text(
      '서비스 설명',
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildDescription() {
    final description = service.description.isNotEmpty
        ? service.description
        : '${service.title}에 대한 상세한 설명입니다. 전문적인 촬영 기술과 경험을 바탕으로 고객님의 소중한 순간을 아름답게 담아드리겠습니다.';

    return Text(
      description,
      style: const TextStyle(
        fontSize: 14,
        height: 1.6,
        color: Colors.black87,
      ),
    );
  }
}
