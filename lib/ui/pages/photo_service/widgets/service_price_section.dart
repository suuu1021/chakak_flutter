import 'package:flutter/material.dart';
import '../../../../../_core/constants/app_colors.dart';
import '../../../../../_core/constants/app_sizes.dart';
import '../../../../data/models/photo_service/photo_service.dart';
import '../../../../data/models/photo_service/price_option.dart';

class ServicePriceSection extends StatefulWidget {
  final PhotoService service;

  const ServicePriceSection({
    super.key,
    required this.service,
  });

  @override
  State<ServicePriceSection> createState() => _ServicePriceSectionState();
}

class _ServicePriceSectionState extends State<ServicePriceSection> {
  int _selectedOption = 0;

  // 서비스의 가격 옵션들 사용
  List<PriceOption> get _priceOptions => widget.service.availableOptions;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSizes.spacing16),
      padding: const EdgeInsets.all(AppSizes.spacing16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '가격 옵션',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSizes.spacing16),
          _buildRoundedTabs(),
          const SizedBox(height: AppSizes.spacing16),
          _buildSelectedOptionDetails(),
        ],
      ),
    );
  }

  Widget _buildRoundedTabs() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: const BoxDecoration(
        color: AppColors.gray100,
        borderRadius: BorderRadius.all(Radius.circular(25)),
      ),
      child: Row(
        children: List.generate(_priceOptions.length, (index) {
          return Expanded(child: _buildTabButton(index));
        }),
      ),
    );
  }

  Widget _buildTabButton(int index) {
    final isSelected = index == _selectedOption;
    return GestureDetector(
      onTap: () => setState(() => _selectedOption = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.transparent,
          borderRadius: const BorderRadius.all(Radius.circular(20)),
          boxShadow: isSelected ? [_buildTabShadow()] : null,
        ),
        child: Text(
          _priceOptions[index].name,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? AppColors.textOnPrimary : AppColors.gray500,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  BoxShadow _buildTabShadow() {
    return const BoxShadow(
      color: AppColors.shadowLight,
      blurRadius: 8,
      offset: Offset(0, 2),
    );
  }

  Widget _buildSelectedOptionDetails() {
    final option = _priceOptions[_selectedOption];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.spacing20),
      decoration: _buildCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPriceHeader(option),
          const SizedBox(height: AppSizes.spacing12),
          _buildBasicInfo(option),
          _buildDivider(),
          _buildFeaturesList(option.features),
        ],
      ),
    );
  }

  BoxDecoration _buildCardDecoration() {
    return const BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.all(Radius.circular(AppSizes.radiusLarge)),
      boxShadow: [
        BoxShadow(
          color: AppColors.shadow,
          blurRadius: 10,
          offset: Offset(0, 4),
        ),
      ],
    );
  }

  Widget _buildPriceHeader(PriceOption option) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          option.name,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          option.formattedPrice,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildBasicInfo(PriceOption option) {
    return Column(
      children: [
        _buildInfoRow(Icons.access_time, '촬영 시간', option.duration),
        const SizedBox(height: AppSizes.spacing4),
        _buildInfoRow(Icons.photo_camera, '사진 제공', option.photoCount),
        const SizedBox(height: AppSizes.spacing4),
        _buildInfoRow(Icons.edit, '보정 수준', option.editingLevel),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: AppSizes.spacing8),
        Text(
          '$label: ',
          style: const TextStyle(fontSize: 15, color: AppColors.textSecondary),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return const Column(
      children: [
        SizedBox(height: AppSizes.spacing8),
        Divider(color: AppColors.divider),
        SizedBox(height: AppSizes.spacing8),
      ],
    );
  }

  Widget _buildFeaturesList(List<String> features) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '포함 서비스',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSizes.spacing8),
        ...features.map((feature) => _buildFeatureItem(feature)),
      ],
    );
  }

  Widget _buildFeatureItem(String feature) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.spacing4),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: AppColors.primary, size: 20),
          const SizedBox(width: AppSizes.spacing8),
          Expanded(
            child: Text(
              feature,
              style:
                  const TextStyle(fontSize: 15, color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
