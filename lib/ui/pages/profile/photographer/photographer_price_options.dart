import 'package:flutter/material.dart';
import '../../../../_core/constants/app_colors.dart';
import '../../../../_core/constants/app_sizes.dart';

// 가격 옵션 데이터 모델
class PriceOption {
  final String name;
  final String price;
  final String duration;
  final String photos;
  final String editing;
  final List<String> features;

  const PriceOption({
    required this.name,
    required this.price,
    required this.duration,
    required this.photos,
    required this.editing,
    required this.features,
  });
}

class PhotographerPriceOptions extends StatefulWidget {
  const PhotographerPriceOptions({super.key});

  @override
  State<PhotographerPriceOptions> createState() =>
      _PhotographerPriceOptionsState();
}

class _PhotographerPriceOptionsState extends State<PhotographerPriceOptions> {
  int _selectedOption = 0;

  static const List<PriceOption> _priceOptions = [
    PriceOption(
      name: '에센셜',
      price: '₩100,000',
      duration: '1시간',
      photos: '20장',
      editing: '기본 보정',
      features: ['스튜디오 촬영', '기본 의상 제공', '48시간 내 전달'],
    ),
    PriceOption(
      name: '프리미엄',
      price: '₩200,000',
      duration: '2시간',
      photos: '50장',
      editing: '고급 보정',
      features: ['실외 + 스튜디오', '의상 컨설팅', '소품 제공', '24시간 내 전달'],
    ),
    PriceOption(
      name: '시그니처',
      price: '₩350,000',
      duration: '3시간',
      photos: '100장',
      editing: '프리미엄 보정',
      features: ['장소 제한 없음', '프리미엄 의상', '전문 메이크업', '당일 전달', '인화본 제공'],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildRoundedTabs(),
        const SizedBox(height: AppSizes.spacing8),
        _buildSelectedOptionDetails(),
      ],
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
          const SizedBox(height: AppSizes.spacing8),
          _buildBookingButton(option.name),
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
          option.price,
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
        _buildInfoRow(Icons.photo_camera, '사진 제공', option.photos),
        const SizedBox(height: AppSizes.spacing4),
        _buildInfoRow(Icons.edit, '보정 수준', option.editing),
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
        SizedBox(height: AppSizes.spacing4),
        Divider(color: AppColors.divider),
        SizedBox(height: AppSizes.spacing4),
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
        const SizedBox(height: AppSizes.spacing6),
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
          Text(
            feature,
            style:
                const TextStyle(fontSize: 15, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingButton(String packageName) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _handleBooking(packageName),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          padding: const EdgeInsets.symmetric(vertical: 8),
          shape: const RoundedRectangleBorder(
            borderRadius:
                BorderRadius.all(Radius.circular(AppSizes.radiusMedium)),
          ),
        ),
        child: Text(
          '$packageName 패키지 예약하기',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _handleBooking(String packageName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$packageName 패키지가 선택되었습니다')),
    );
  }
}
