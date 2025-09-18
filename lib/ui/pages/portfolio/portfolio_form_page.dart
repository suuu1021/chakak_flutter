import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../_core/constants/app_colors.dart';
import '../../../../_core/constants/app_sizes.dart';
import '../../../data/models/portfolio.dart';
import '../../../provider/global/portfolio/portfolio_notifier.dart';
import 'widgets/form_category_selector.dart';
import 'widgets/form_image_selector.dart';
import 'widgets/form_text_fields.dart';

class PortfolioFormPage extends ConsumerStatefulWidget {
  final Portfolio? portfolio;

  const PortfolioFormPage({super.key, this.portfolio});

  @override
  ConsumerState<PortfolioFormPage> createState() => _PortfolioFormPageState();
}

class _PortfolioFormPageState extends ConsumerState<PortfolioFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  List<String> _selectedCategories = [];
  List<File> _selectedImages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  void _loadExistingData() {
    if (widget.portfolio != null) {
      final portfolio = widget.portfolio!;
      _titleController.text = portfolio.title;
      _descriptionController.text = portfolio.description;
      _selectedCategories = List.from(portfolio.categories);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.portfolio != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? '포트폴리오 수정' : '포트폴리오 등록'),
        backgroundColor: AppColors.primaryLight,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSizes.spacing16),
                child: Column(
                  children: [
                    FormTextFields(
                      titleController: _titleController,
                      descriptionController: _descriptionController,
                    ),
                    const SizedBox(height: AppSizes.spacing16),
                    FormCategorySelector(
                      selectedCategories: _selectedCategories,
                      onChanged: (categories) =>
                          setState(() => _selectedCategories = categories),
                    ),
                    const SizedBox(height: AppSizes.spacing16),
                    FormImageSelector(
                      selectedImages: _selectedImages,
                      onChanged: (images) =>
                          setState(() => _selectedImages = images),
                    ),
                  ],
                ),
              ),
            ),
            _buildSaveButton(isEdit),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton(bool isEdit) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.spacing16),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          onPressed: _isLoading ? null : _savePortfolio,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.white,
          ),
          child: _isLoading
              ? const CircularProgressIndicator(color: AppColors.white)
              : Text(isEdit ? '수정 완료' : '등록하기'),
        ),
      ),
    );
  }

  Future<void> _savePortfolio() async {
    if (!_formKey.currentState!.validate() || _selectedCategories.isEmpty) {
      _showValidationError();
      return;
    }

    setState(() => _isLoading = true);

    try {
      final List<String> imageUrls = _selectedImages.isNotEmpty
          ? _selectedImages.asMap().entries.map((entry) {
              return 'https://images.pexels.com/photos/1450353/pexels-photo-1450353.jpeg';
            }).toList()
          : [
              'https://images.pexels.com/photos/10490905/pexels-photo-10490905.jpeg'
            ]; // 기본 이미지
      final portfolio = Portfolio.create(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        imageUrls: imageUrls,
        categories: _selectedCategories,
        photographerId: '1', // 임시 ID (서버에서 실제 로그인 사용자로 대체됨)
      );

      final success = widget.portfolio != null
          ? await ref
              .read(portfolioProvider.notifier)
              .updatePortfolio(widget.portfolio!.id, portfolio)
          : await ref
              .read(portfolioProvider.notifier)
              .createPortfolio(portfolio);

      if (success && mounted) {
        debugPrint(
            '포트폴리오 ${widget.portfolio != null ? '수정' : '등록'} 성공: ${_titleController.text}');
        Navigator.of(context).pop(true);
      } else if (mounted) {
        _showErrorDialog('${widget.portfolio != null ? '수정' : '등록'}에 실패했습니다.');
      }
    } catch (e) {
      if (mounted) {
        debugPrint('포트폴리오 저장 오류: $e');
        _showErrorDialog('오류가 발생했습니다: ${e.toString()}');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showValidationError() {
    String message = '';
    if (_selectedCategories.isEmpty) {
      message = '카테고리를 선택해주세요.';
    }

    if (message.isNotEmpty) {
      _showErrorDialog(message);
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('알림'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
