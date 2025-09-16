import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../_core/constants/app_colors.dart';
import '../../../../../_core/constants/app_sizes.dart';

class PhotographerProfileForm extends StatefulWidget {
  final Map<String, dynamic> formData;
  final Map<String, String> errors;
  final Function(String, String) onDataChanged;

  const PhotographerProfileForm({
    super.key,
    required this.formData,
    required this.errors,
    required this.onDataChanged,
  });

  @override
  State<PhotographerProfileForm> createState() =>
      _PhotographerProfileFormState();
}

class _PhotographerProfileFormState extends State<PhotographerProfileForm> {
  late TextEditingController _businessNameController;
  late TextEditingController _introductionController;
  late TextEditingController _locationController;
  late TextEditingController _experienceYearsController;

  final List<Map<String, String>> _statusOptions = [
    {'value': 'ACTIVE', 'label': '활성'},
    {'value': 'INACTIVE', 'label': '비활성'},
    {'value': 'PENDING', 'label': '승인 대기'},
  ];

  @override
  void initState() {
    super.initState();
    _businessNameController =
        TextEditingController(text: widget.formData['businessName'] ?? '');
    _introductionController =
        TextEditingController(text: widget.formData['introduction'] ?? '');
    _locationController =
        TextEditingController(text: widget.formData['location'] ?? '');
    _experienceYearsController =
        TextEditingController(text: widget.formData['experienceYears'] ?? '');
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _introductionController.dispose();
    _locationController.dispose();
    _experienceYearsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '포토그래퍼 정보',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSizes.spacing16),
        _buildBusinessNameField(),
        const SizedBox(height: AppSizes.spacing16),
        _buildIntroductionField(),
        const SizedBox(height: AppSizes.spacing8),
        _buildIntroductionCharacterCount(),
        const SizedBox(height: AppSizes.spacing16),
        _buildLocationField(),
        const SizedBox(height: AppSizes.spacing16),
        _buildExperienceYearsField(),
        const SizedBox(height: AppSizes.spacing16),
        _buildStatusField(),
      ],
    );
  }

  Widget _buildBusinessNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '상호명',
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
          controller: _businessNameController,
          onChanged: (value) => widget.onDataChanged('businessName', value),
          decoration: _buildInputDecoration(
            hintText: '상호명을 입력하세요',
            errorText: widget.errors['businessName'],
          ),
          maxLength: 50,
          buildCounter: _buildCharacterCounter,
        ),
      ],
    );
  }

  Widget _buildIntroductionField() {
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
          controller: _introductionController,
          onChanged: (value) => widget.onDataChanged('introduction', value),
          decoration: _buildInputDecoration(
            hintText: '포토그래퍼로서의 소개를 작성해 주세요',
            errorText: widget.errors['introduction'],
          ),
          maxLines: 4,
          maxLength: 500,
          textInputAction: TextInputAction.newline,
          buildCounter: (context,
              {required currentLength, required isFocused, maxLength}) {
            return null; // 소개글은 별도 카운터로 표시
          },
        ),
      ],
    );
  }

  Widget _buildIntroductionCharacterCount() {
    final introductionLength = _introductionController.text.length;
    final maxLength = 500;

    return Container(
      alignment: Alignment.centerRight,
      child: Text(
        '$introductionLength/$maxLength',
        style: TextStyle(
          fontSize: 12,
          color: introductionLength > maxLength * 0.8
              ? AppColors.error
              : AppColors.textTertiary,
        ),
      ),
    );
  }

  Widget _buildLocationField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '활동 지역',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSizes.spacing8),
        TextFormField(
          controller: _locationController,
          onChanged: (value) => widget.onDataChanged('location', value),
          decoration: _buildInputDecoration(
            hintText: '주요 활동 지역을 입력하세요 (예: 서울, 경기)',
            errorText: widget.errors['location'],
          ),
          maxLength: 100,
          buildCounter: _buildCharacterCounter,
        ),
      ],
    );
  }

  Widget _buildExperienceYearsField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '경력 연수',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSizes.spacing8),
        TextFormField(
          controller: _experienceYearsController,
          onChanged: (value) => widget.onDataChanged('experienceYears', value),
          decoration: _buildInputDecoration(
            hintText: '경력 연수를 입력하세요',
            errorText: widget.errors['experienceYears'],
            suffixText: '년',
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(2),
          ],
          maxLength: 2,
          buildCounter: (context,
              {required currentLength, required isFocused, maxLength}) {
            return const SizedBox.shrink(); // 숫자 필드는 카운터 숨김
          },
        ),
      ],
    );
  }

  Widget _buildStatusField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '상태',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSizes.spacing8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: widget.formData['status'] ?? 'ACTIVE',
              onChanged: (String? newValue) {
                if (newValue != null) {
                  widget.onDataChanged('status', newValue);
                }
              },
              items: _statusOptions.map<DropdownMenuItem<String>>((option) {
                return DropdownMenuItem<String>(
                  value: option['value'],
                  child: Row(
                    children: [
                      _buildStatusIcon(option['value']!),
                      const SizedBox(width: 8),
                      Text(
                        option['label']!,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              icon: Icon(
                Icons.keyboard_arrow_down,
                color: AppColors.gray600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusIcon(String status) {
    IconData icon;
    Color color;

    switch (status) {
      case 'ACTIVE':
        icon = Icons.check_circle;
        color = AppColors.success;
        break;
      case 'INACTIVE':
        icon = Icons.cancel;
        color = AppColors.error;
        break;
      case 'PENDING':
        icon = Icons.schedule;
        color = AppColors.warning;
        break;
      default:
        icon = Icons.help;
        color = AppColors.gray500;
    }

    return Icon(icon, color: color, size: 20);
  }

  InputDecoration _buildInputDecoration({
    required String hintText,
    String? errorText,
    String? suffixText,
  }) {
    return InputDecoration(
      hintText: hintText,
      suffixText: suffixText,
      errorText: errorText?.isEmpty == false ? errorText : null,
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
    );
  }

  Widget? _buildCharacterCounter(
    BuildContext context, {
    required int currentLength,
    required bool isFocused,
    int? maxLength,
  }) {
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
  }
}
