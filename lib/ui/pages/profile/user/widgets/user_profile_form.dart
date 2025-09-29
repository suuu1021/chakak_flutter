import 'package:flutter/material.dart';

import '../../../../../_core/constants/app_colors.dart';
import '../../../../../_core/constants/app_sizes.dart';

class UserProfileForm extends StatefulWidget {
  final Map<String, dynamic> formData;
  final Map<String, String> errors;
  final Function(String, String) onDataChanged;

  const UserProfileForm({
    super.key,
    required this.formData,
    required this.errors,
    required this.onDataChanged,
  });

  @override
  State<UserProfileForm> createState() => _UserProfileFormState();
}

class _UserProfileFormState extends State<UserProfileForm> {
  late TextEditingController _nickNameController;
  late TextEditingController _introduceController;

  @override
  void initState() {
    super.initState();
    _nickNameController =
        TextEditingController(text: widget.formData['nickName'] ?? '');
    _introduceController =
        TextEditingController(text: widget.formData['introduce'] ?? '');
  }

  @override
  void dispose() {
    _nickNameController.dispose();
    _introduceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '기본 정보',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSizes.spacing16),
        _buildNickNameField(),
        const SizedBox(height: AppSizes.spacing16),
        _buildIntroduceField(),
        const SizedBox(height: AppSizes.spacing8),
        _buildCharacterCount(),
      ],
    );
  }

  Widget _buildNickNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '닉네임',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '*',
              style: TextStyle(
                color: AppColors.error,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.spacing8),
        TextFormField(
          controller: _nickNameController,
          onChanged: (value) => widget.onDataChanged('nickName', value),
          decoration: InputDecoration(
            hintText: '닉네임을 입력하세요',
            errorText: widget.errors['nickName']?.isEmpty == false
                ? widget.errors['nickName']
                : null,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.border,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.error,
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.error,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          maxLength: 20,
          buildCounter: (context,
              {required currentLength, required isFocused, maxLength}) {
            return Container(
              alignment: Alignment.centerRight,
              child: Text(
                '$currentLength/$maxLength',
                style: TextStyle(
                  fontSize: 12,
                  color: currentLength > (maxLength ?? 0) * 0.8
                      ? AppColors.error
                      : AppColors.textTertiary,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildIntroduceField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '소개',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSizes.spacing8),
        TextFormField(
          controller: _introduceController,
          onChanged: (value) => widget.onDataChanged('introduce', value),
          decoration: InputDecoration(
            hintText: '자신을 소개해 주세요',
            errorText: widget.errors['introduce']?.isEmpty == false
                ? widget.errors['introduce']
                : null,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.border,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.error,
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.error,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            alignLabelWithHint: true,
          ),
          maxLines: 3,
          maxLength: 200,
          textInputAction: TextInputAction.newline,
          buildCounter: (context,
              {required currentLength, required isFocused, maxLength}) {
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildCharacterCount() {
    final introduceLength = _introduceController.text.length;
    final maxLength = 200;

    return Container(
      alignment: Alignment.centerRight,
      child: Text(
        '$introduceLength/$maxLength',
        style: TextStyle(
          fontSize: 12,
          color: introduceLength > maxLength * 0.8
              ? AppColors.error
              : AppColors.textTertiary,
        ),
      ),
    );
  }
}
