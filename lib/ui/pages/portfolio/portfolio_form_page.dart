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
  /*
   * 수정된 부분: 타입 변경
   * 기존: List<File> _selectedImages = [];
   * 이유: FormImageSelector가 File과 String을 모두 처리하므로 Object 타입으로 변경
   */
  List<Object> _selectedImages = [];
  int? _thumbnailIndex; // 대표 이미지 인덱스
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
      /*
       * 수정된 부분: 기존 이미지 URL 로딩
       * 이유: 수정 모드에서 기존 이미지를 보여주고 관리하기 위함
       */
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
      final List<String> imageUrls = _selectedImages.map((image) {
        if (image is File) {
          // File인 경우 경로(path)를 사용
          return image.path;
        } else if (image is String) {
          // String인 경우 URL을 그대로 사용
          return image;
        }
        return '';
      }).toList();

      final String thumbnailUrl = _thumbnailIndex != null
          ? (_selectedImages[_thumbnailIndex!] is File
              ? (_selectedImages[_thumbnailIndex!] as File).path
              : _selectedImages[_thumbnailIndex!] as String)
          : imageUrls.first;

      final portfolio = Portfolio.create(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        imageUrls: imageUrls,
        categories: _selectedCategories,
        photographerId: '1', // 임시 ID
      ).copyWith(
        thumbnailUrl: thumbnailUrl,
      );

      debugPrint('=== 포트폴리오 저장 데이터 ===');
      debugPrint('제목: ${portfolio.title}');
      debugPrint('이미지 수: ${portfolio.imageUrls.length}');
      debugPrint('썸네일: ${portfolio.thumbnailUrl}');
      debugPrint('대표 이미지 인덱스: $_thumbnailIndex');

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
