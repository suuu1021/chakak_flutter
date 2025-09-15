import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../_core/constants/app_colors.dart';
import '../../../../_core/constants/app_sizes.dart';
import '../../../data/models/portfolio.dart';
import 'widgets/form_category_selector.dart';
import 'widgets/form_image_selector.dart';
import 'widgets/form_text_fields.dart';

class PortfolioFormPage extends StatefulWidget {
  final Portfolio? portfolio;

  const PortfolioFormPage({super.key, this.portfolio});

  @override
  State<PortfolioFormPage> createState() => _PortfolioFormPageState();
}

class _PortfolioFormPageState extends State<PortfolioFormPage> {
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
    if (!_formKey.currentState!.validate() ||
        _selectedCategories.isEmpty ||
        (_selectedImages.isEmpty && widget.portfolio == null)) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      await Future.delayed(const Duration(seconds: 1)); // 임시
      debugPrint('저장 완료: ${_titleController.text}');
      if (mounted) Navigator.of(context).pop(true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
