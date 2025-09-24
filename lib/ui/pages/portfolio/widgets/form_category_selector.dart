import 'package:chakak_flutter/_core/constants/api_config.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../../../_core/constants/app_colors.dart';
import '../../../../../_core/constants/app_sizes.dart';
import '../../../../service/portfolio_api_service.dart';

class FormCategorySelector extends StatefulWidget {
  final List<String> selectedCategories;
  final Function(List<String>) onChanged;

  const FormCategorySelector({
    super.key,
    required this.selectedCategories,
    required this.onChanged,
  });

  @override
  State<FormCategorySelector> createState() => _FormCategorySelectorState();
}

class _FormCategorySelectorState extends State<FormCategorySelector> {
  late final PortfolioApiService _apiService;
  List<String> _availableCategories = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Dio 인스턴스 생성 및 PortfolioApiService 초기화
    final dio = Dio(BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ));
    _apiService = PortfolioApiService(dio);
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final categoryMapping = await _apiService.fetchCategoryMapping();
      final categories = categoryMapping.keys.toList();

      setState(() {
        _availableCategories = categories;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = '카테고리를 불러오는데 실패했습니다';
        _isLoading = false;
        // 에러 시 기본 카테고리 사용
        _availableCategories = ['웨딩촬영', '인물촬영', '가족사진', '커플촬영'];
      });
      print('카테고리 로딩 실패: $e');
    }
  }

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

        // 로딩 상태
        if (_isLoading)
          const SizedBox(
            height: 40,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          )

        // 에러 상태
        else if (_errorMessage != null)
          Column(
            children: [
              Text(
                _errorMessage!,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.error,
                ),
              ),
              const SizedBox(height: AppSizes.spacing8),
              ElevatedButton(
                onPressed: _loadCategories,
                child: const Text('다시 시도'),
              ),
            ],
          )

        // 카테고리 선택
        else
          Wrap(
            spacing: AppSizes.spacing8,
            runSpacing: AppSizes.spacing4,
            children: _availableCategories.map((category) {
              final isSelected = widget.selectedCategories.contains(category);
              return FilterChip(
                label: Text(category),
                selected: isSelected,
                onSelected: (selected) {
                  final newCategories =
                      List<String>.from(widget.selectedCategories);
                  if (selected) {
                    newCategories.add(category);
                  } else {
                    newCategories.remove(category);
                  }
                  widget.onChanged(newCategories);
                },
                backgroundColor: AppColors.gray100,
                selectedColor: AppColors.primary,
                labelStyle: TextStyle(
                  color: isSelected ? AppColors.white : AppColors.textPrimary,
                ),
              );
            }).toList(),
          ),

        // 선택 안내 메시지
        if (!_isLoading &&
            _errorMessage == null &&
            widget.selectedCategories.isEmpty)
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
