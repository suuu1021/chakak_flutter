import 'package:flutter/material.dart';
import '../../../../../_core/constants/app_colors.dart';
import '../../../../../_core/constants/app_sizes.dart';

class FormTextFields extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController descriptionController;

  const FormTextFields({
    super.key,
    required this.titleController,
    required this.descriptionController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTitleField(),
        const SizedBox(height: AppSizes.spacing16),
        _buildDescriptionField(),
      ],
    );
  }

  Widget _buildTitleField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '제목',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSizes.spacing8),
        TextFormField(
          controller: titleController,
          decoration: const InputDecoration(
            hintText: '포트폴리오 제목을 입력하세요',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return '제목을 입력해주세요';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '설명',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSizes.spacing8),
        TextFormField(
          controller: descriptionController,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: '포트폴리오에 대한 설명을 입력하세요',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return '설명을 입력해주세요';
            }
            return null;
          },
        ),
      ],
    );
  }
}
