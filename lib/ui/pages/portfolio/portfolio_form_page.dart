import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../_core/constants/app_colors.dart';
import '../../../../_core/constants/app_sizes.dart';
import '../../../data/models/portfolio/portfolio.dart';
import '../../../provider/portfolio/portfolio_notifier.dart';
import 'portfolio_detail_page.dart';
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
  List<Object> _selectedImages = [];
  int? _thumbnailIndex;
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
      _selectedImages = List.from(portfolio.imageUrls);
      final thumbnailIndex =
          portfolio.imageUrls.indexOf(portfolio.thumbnailUrl);
      _thumbnailIndex = thumbnailIndex != -1 ? thumbnailIndex : null;
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
                      thumbnailIndex: _thumbnailIndex,
                      onChanged: (images) =>
                          setState(() => _selectedImages = images),
                      onThumbnailChanged: (index) =>
                          setState(() => _thumbnailIndex = index),
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

    if (_selectedImages.isEmpty) {
      _showErrorDialog('최소 1개의 이미지를 선택해주세요.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final isEdit = widget.portfolio != null;

      // 이미지 경로 분리
      final List<String> newImagePaths =
          _selectedImages.whereType<File>().map((f) => f.path).toList();
      final List<String> existingImageUrls =
          _selectedImages.whereType<String>().toList();

      if (isEdit) {
        // 수정 로직
        final success =
            await ref.read(portfolioProvider.notifier).updatePortfolioWithFiles(
                  portfolioId: widget.portfolio!.id,
                  title: _titleController.text.trim(),
                  description: _descriptionController.text.trim(),
                  categories: _selectedCategories,
                  existingImageUrls: existingImageUrls,
                  newImagePaths: newImagePaths,
                );

        if (success && mounted) {
          debugPrint('포트폴리오 수정 성공: ${_titleController.text}');
          Navigator.of(context).pop(true);
        } else if (mounted) {
          final error = ref.read(portfolioProvider).errorMessage;
          _showErrorDialog('수정에 실패했습니다: ${error ?? ""}');
        }
      } else {
        // 생성 로직
        if (newImagePaths.isEmpty) {
          _showErrorDialog('새 포트폴리오에는 최소 1개의 새 이미지가 필요합니다.');
          setState(() => _isLoading = false);
          return;
        }

        final newPortfolio =
            await ref.read(portfolioProvider.notifier).createPortfolioWithFiles(
                  title: _titleController.text.trim(),
                  description: _descriptionController.text.trim(),
                  categories: _selectedCategories,
                  photographerId: 1,
                  imagePaths: newImagePaths,
                );

        if (newPortfolio != null && mounted) {
          debugPrint('포트폴리오 등록 성공: ${newPortfolio.title}');
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) =>
                  PortfolioDetailPage(portfolioId: newPortfolio.id),
            ),
          );
        } else if (mounted) {
          final error = ref.read(portfolioProvider).errorMessage;
          _showErrorDialog('등록에 실패했습니다: ${error ?? ""}');
        }
      }
    } catch (e) {
      if (mounted) {
        debugPrint('포트폴리오 저장 오류: $e');
        _showErrorDialog('오류가 발생했습니다: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
