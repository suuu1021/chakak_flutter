import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../_core/constants/app_colors.dart';
import '../../../../../_core/constants/app_sizes.dart';

class ProfileFormFields extends StatelessWidget {
  final TextEditingController businessNameController;
  final TextEditingController introductionController;
  final TextEditingController locationController;
  final TextEditingController experienceYearsController;
  final String selectedStatus;
  final ValueChanged<String?> onStatusChanged;

  static const List<String> statusOptions = ['활성', '비활성'];

  const ProfileFormFields({
    super.key,
    required this.businessNameController,
    required this.introductionController,
    required this.locationController,
    required this.experienceYearsController,
    required this.selectedStatus,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBusinessNameField(),
        const SizedBox(height: AppSizes.spacing8),
        _buildIntroductionField(),
        const SizedBox(height: AppSizes.spacing8),
        _buildLocationField(),
        const SizedBox(height: AppSizes.spacing8),
        _buildExperienceYearsField(),
        const SizedBox(height: AppSizes.spacing8),
        _buildStatusField(),
      ],
    );
  }

  Widget _buildBusinessNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('상호명', isRequired: true),
        const SizedBox(height: AppSizes.spacing8),
        TextFormField(
          controller: businessNameController,
          decoration: _buildInputDecoration('상호명을 입력하세요'),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return '상호명을 입력해주세요';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildIntroductionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('소개글'),
        const SizedBox(height: AppSizes.spacing8),
        TextFormField(
          controller: introductionController,
          decoration: _buildInputDecoration('자신을 소개해주세요'),
          maxLines: 4,
          maxLength: 500,
        ),
      ],
    );
  }

  Widget _buildLocationField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('활동 지역', isRequired: true),
        const SizedBox(height: AppSizes.spacing8),
        TextFormField(
          controller: locationController,
          decoration: _buildInputDecoration('활동 지역을 입력하세요'),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return '활동 지역을 입력해주세요';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildExperienceYearsField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('경력 연수'),
        const SizedBox(height: AppSizes.spacing8),
        TextFormField(
          controller: experienceYearsController,
          decoration: _buildInputDecoration('경력 연수를 입력하세요'),
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(2),
          ],
          validator: (value) {
            if (value != null && value.isNotEmpty) {
              final years = int.tryParse(value);
              if (years == null || years < 0 || years > 50) {
                return '0-50 사이의 숫자를 입력해주세요';
              }
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildStatusField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('상태', isRequired: true),
        const SizedBox(height: AppSizes.spacing8),
        DropdownButtonFormField<String>(
          value: selectedStatus,
          decoration: _buildInputDecoration('상태를 선택하세요'),
          items: statusOptions.map((status) {
            return DropdownMenuItem(
              value: status,
              child: Text(status),
            );
          }).toList(),
          onChanged: onStatusChanged,
        ),
      ],
    );
  }

  Widget _buildFieldLabel(String label, {bool isRequired = false}) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        if (isRequired) ...[
          const SizedBox(width: 4),
          const Text(
            '*',
            style: TextStyle(
              color: AppColors.error,
              fontSize: 16,
            ),
          ),
        ],
      ],
    );
  }

  InputDecoration _buildInputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(
        color: AppColors.gray500,
        fontSize: 14,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.gray300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.gray300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      filled: true,
      fillColor: AppColors.background,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSizes.spacing12,
        vertical: AppSizes.spacing12,
      ),
    );
  }
}
