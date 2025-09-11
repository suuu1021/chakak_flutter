import 'package:flutter/material.dart';
import '../../../../../_core/constants/app_colors.dart';
import '../../../../../_core/constants/app_sizes.dart';

class FormCategorySelector extends StatelessWidget {
  final List<String> selectedCategories;
  final Function(List<String>) onChanged;

  const FormCategorySelector({
    super.key,
    required this.selectedCategories,
    required this.onChanged,
  });

  static const List<String> _availableCategories = [
    '커플',
    '웨딩',
    '가족',
    '프로필',
    '아티스틱',
    '제품',
    '브랜딩',
    '야외',
    '실내'
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '카테고리',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSizes.spacing8),
        Wrap(
          spacing: AppSizes.spacing8,
          runSpacing: AppSizes.spacing4,
          children: _availableCategories.map((category) {
            final isSelected = selectedCategories.contains(category);
            return FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                final newCategories = List<String>.from(selectedCategories);
                if (selected) {
                  newCategories.add(category);
                } else {
                  newCategories.remove(category);
                }
                onChanged(newCategories);
              },
              backgroundColor: AppColors.gray100,
              selectedColor: AppColors.primary,
              labelStyle: TextStyle(
                color: isSelected ? AppColors.white : AppColors.textPrimary,
              ),
            );
          }).toList(),
        ),
        if (selectedCategories.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: AppSizes.spacing4),
            child: Text(
              '최소 하나의 카테고리를 선택해주세요',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.error,
              ),
            ),
          ),
      ],
    );
  }
}
