import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../_core/constants/app_colors.dart';
import '../../../../_core/constants/app_sizes.dart';
import '../../../../_core/utils/error_handler.dart';
import '../../../data/models/photo_service/photo_service.dart';
import '../../../data/models/photo_service/price_option.dart';
import '../../../data/models/photo_service_category.dart';
import '../../../provider/global/photoService/photo_service_provider.dart';

class PhotoServiceFormPage extends ConsumerStatefulWidget {
  final PhotoService? service; // null이면 생성, 있으면 수정
  final int photographerId;

  const PhotoServiceFormPage({
    super.key,
    this.service,
    required this.photographerId,
  });

  @override
  ConsumerState<PhotoServiceFormPage> createState() =>
      _PhotoServiceFormPageState();
}

class _PhotoServiceFormPageState extends ConsumerState<PhotoServiceFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  List<PriceOption> _priceOptions = [];
  List<String> _selectedCategoryIds = [];
  List<PhotoServiceCategory> _availableCategories = [];
  List<File> _selectedImages = [];
  String _existingImageData = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _addInitialPriceOption();

    if (widget.service != null) {
      _loadExistingData();
    }
  }

  void _loadExistingData() {
    final service = widget.service!;
    _titleController.text = service.title;
    _descriptionController.text = service.description;
    _existingImageData = service.imageUrl ?? '';
    _priceOptions = List.from(service.priceOptions ?? []);

    _selectedCategoryIds = [];
  }

  Future<void> _loadCategories() async {
    try {
      final categories =
          await ref.read(photoServiceProvider.notifier).loadCategories();
      setState(() {
        _availableCategories = categories.map((categoryData) {
          return PhotoServiceCategory(
            id: (categoryData['categoryId'] ?? 0).toString(),
            name: categoryData['categoryName'] ?? '',
            categoryImageData: categoryData['categoryImageData'] ?? '',
          );
        }).toList();

        if (widget.service != null) {
          _mapCategoryNamesToIds();
        }
      });
    } catch (error) {
      ErrorHandler.handleError(
        context,
        error,
        customMessage: '카테고리 로딩 중 오류가 발생했습니다',
      );
    }
  }

  void _mapCategoryNamesToIds() {
    if (widget.service != null && widget.service!.categories.isNotEmpty) {
      setState(() {
        _selectedCategoryIds.clear();

        for (String categoryName in widget.service!.categories) {
          final matchingCategory = _availableCategories.firstWhere(
            (category) => category.name == categoryName,
            orElse: () =>
                PhotoServiceCategory(id: '', name: '', categoryImageData: ''),
          );

          if (matchingCategory.id.isNotEmpty &&
              !_selectedCategoryIds.contains(matchingCategory.id)) {
            _selectedCategoryIds.add(matchingCategory.id);
          }
        }
      });
    }
  }

  void _addInitialPriceOption() {
    if (_priceOptions.isEmpty) {
      _priceOptions.add(PriceOption(
        name: '기본 패키지',
        price: 100000,
        duration: '60분',
        photoCount: '1명',
        editingLevel: '기본 보정',
        features: ['기본 장비'],
      ));
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryLight,
        title: Text(widget.service == null ? '포토 서비스 등록' : '포토 서비스 수정'),
        actions: [
          if (widget.service != null)
            IconButton(
              onPressed: _showDeleteConfirmDialog,
              icon: const Icon(Icons.delete, color: Colors.red),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.spacing16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImageSection(),
              const SizedBox(height: AppSizes.spacing24),
              _buildTitleField(),
              const SizedBox(height: AppSizes.spacing16),
              _buildDescriptionField(),
              const SizedBox(height: AppSizes.spacing16),
              _buildPriceOptionsSection(),
              const SizedBox(height: AppSizes.spacing16),
              _buildCategorySection(),
              const SizedBox(height: AppSizes.spacing32),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '서비스 이미지',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppSizes.spacing8),
        SizedBox(
          height: 120,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              if (_existingImageData.isNotEmpty)
                ..._existingImageData
                    .split(',')
                    .where((data) => data.isNotEmpty)
                    .map((imageData) {
                  return _buildExistingImageItem(imageData);
                }),
              ..._selectedImages.map((file) => _buildNewImageItem(file)),
              _buildAddImageButton(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExistingImageItem(String imageData) {
    bool isUrl = imageData.startsWith('http');

    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: isUrl
                ? Image.network(
                    imageData,
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Icon(Icons.error_outline,
                            color: Colors.red, size: 50),
                      );
                    },
                  )
                : Image.memory(
                    base64Decode(imageData),
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                  ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () => _removeExistingImage(imageData),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewImageItem(File imageFile) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(imageFile,
                width: 120, height: 120, fit: BoxFit.cover),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () => _removeNewImage(imageFile),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                    color: Colors.red, shape: BoxShape.circle),
                child: const Icon(Icons.close, color: Colors.white, size: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddImageButton() {
    return GestureDetector(
      onTap: _pickImages,
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.gray300, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate, color: AppColors.gray500, size: 32),
            SizedBox(height: 4),
            Text('이미지 추가',
                style: TextStyle(color: AppColors.gray500, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleField() {
    return TextFormField(
      controller: _titleController,
      decoration: const InputDecoration(
        labelText: '서비스 제목',
        hintText: '서비스 제목을 입력하세요',
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return '서비스 제목을 입력하세요';
        }
        return null;
      },
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      decoration: const InputDecoration(
        labelText: '서비스 설명',
        hintText: '서비스에 대한 상세한 설명을 입력하세요',
        border: OutlineInputBorder(),
      ),
      maxLines: 4,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return '서비스 설명을 입력하세요';
        }
        return null;
      },
    );
  }

  Widget _buildPriceOptionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('가격 패키지',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            IconButton(
              onPressed: _addPriceOption,
              icon: const Icon(Icons.add, color: AppColors.primary),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.spacing8),
        ..._priceOptions.asMap().entries.map((entry) {
          final index = entry.key;
          final priceOption = entry.value;
          return _buildPriceOptionItem(index, priceOption);
        }).toList(),
      ],
    );
  }

  Widget _buildPriceOptionItem(int index, PriceOption priceOption) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('패키지 ${index + 1}',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                if (_priceOptions.length > 1)
                  IconButton(
                    onPressed: () => _removePriceOption(index),
                    icon: const Icon(Icons.delete, color: Colors.red),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: priceOption.name,
              decoration: const InputDecoration(
                  labelText: '패키지명', border: OutlineInputBorder()),
              onChanged: (value) =>
                  _updatePriceOption(index, priceOption.copyWith(name: value)),
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: priceOption.price.toString(),
              decoration: const InputDecoration(
                  labelText: '가격',
                  suffixText: '원',
                  border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                final price = int.tryParse(value) ?? 0;
                _updatePriceOption(index, priceOption.copyWith(price: price));
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: priceOption.photoCount.replaceAll('명', ''),
                    decoration: const InputDecoration(
                        labelText: '참여 인원',
                        suffixText: '명',
                        border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                    onChanged: (value) => _updatePriceOption(
                        index, priceOption.copyWith(photoCount: '${value}명')),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    initialValue: priceOption.duration.replaceAll('분', ''),
                    decoration: const InputDecoration(
                        labelText: '촬영 시간',
                        suffixText: '분',
                        border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                    onChanged: (value) => _updatePriceOption(
                        index, priceOption.copyWith(duration: '${value}분')),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: priceOption.editingLevel,
              decoration: const InputDecoration(
                  labelText: '편집 수준', border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem(value: '기본 보정', child: Text('기본 보정')),
                DropdownMenuItem(value: '메이크업 포함', child: Text('메이크업 포함')),
                DropdownMenuItem(value: '고급 보정', child: Text('고급 보정')),
              ],
              onChanged: (value) {
                if (value != null) {
                  _updatePriceOption(
                      index, priceOption.copyWith(editingLevel: value));
                }
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: priceOption.features.join(', '),
              decoration: const InputDecoration(
                labelText: '포함 사항',
                hintText: '포함된 서비스나 장비를 입력하세요 (쉼표로 구분)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
              onChanged: (value) {
                final features = value
                    .split(',')
                    .map((e) => e.trim())
                    .where((e) => e.isNotEmpty)
                    .toList();
                _updatePriceOption(
                    index, priceOption.copyWith(features: features));
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('카테고리 선택',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: AppSizes.spacing8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _availableCategories.map((category) {
            final isSelected = _selectedCategoryIds.contains(category.id);
            return FilterChip(
              label: Text(category.name),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedCategoryIds.add(category.id);
                  } else {
                    _selectedCategoryIds.remove(category.id);
                  }
                });
              },
              backgroundColor: Colors.white,
              selectedColor: AppColors.primaryLight,
              checkmarkColor: AppColors.primary,
            );
          }).toList(),
        ),
        if (_selectedCategoryIds.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text('최소 하나의 카테고리를 선택하세요',
                style: TextStyle(color: Colors.red, fontSize: 12)),
          ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveService,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(
                widget.service == null ? '서비스 등록' : '수정 완료',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  void _addPriceOption() {
    setState(() {
      _priceOptions.add(PriceOption(
        name: '패키지 ${_priceOptions.length + 1}',
        price: 100000,
        duration: '60분',
        photoCount: '1명',
        editingLevel: '기본 보정',
        features: ['기본 장비'],
      ));
    });
  }

  void _removePriceOption(int index) {
    if (_priceOptions.length > 1) {
      setState(() {
        _priceOptions.removeAt(index);
      });
    }
  }

  void _updatePriceOption(int index, PriceOption updatedOption) {
    setState(() {
      _priceOptions[index] = updatedOption;
    });
  }

  Future<void> _pickImages() async {
    try {
      final ImagePicker picker = ImagePicker();
      final List<XFile> images = await picker.pickMultiImage();
      setState(() {
        _selectedImages.addAll(images.map((xfile) => File(xfile.path)));
      });
    } catch (error) {
      ErrorHandler.handleError(context, error,
          customMessage: '이미지 선택 중 오류가 발생했습니다');
    }
  }

  void _removeExistingImage(String imageData) {
    setState(() {
      final imageList = _existingImageData.split(',');
      imageList.remove(imageData);
      _existingImageData = imageList.where((data) => data.isNotEmpty).join(',');
    });
  }

  void _removeNewImage(File imageFile) {
    setState(() {
      _selectedImages.remove(imageFile);
    });
  }

  Future<void> _saveService() async {
    print('=== _saveService 시작 ===');
    print('수정 모드: ${widget.service != null}');

    if (!_formKey.currentState!.validate() || _selectedCategoryIds.isEmpty) {
      print('유효성 검사 실패');

      _showValidationError();
      return;
    }

    if (_existingImageData.isEmpty && _selectedImages.isEmpty) {
      print('이미지 없음');

      _showErrorDialog('최소 하나의 이미지를 추가하세요');
      return;
    }
    print('서비스 저장 시작...');

    setState(() => _isLoading = true);

    try {
      final List<String> newImageDataList = [];
      for (var imageFile in _selectedImages) {
        final bytes = await imageFile.readAsBytes();
        newImageDataList.add(base64Encode(bytes));
      }

      String combinedImageData = '';
      if (_existingImageData.isNotEmpty) {
        combinedImageData = _existingImageData;
      }
      if (newImageDataList.isNotEmpty) {
        if (combinedImageData.isNotEmpty) {
          combinedImageData += ',';
        }
        combinedImageData += newImageDataList.join(',');
      }

      final serviceData = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'photographerId': widget.photographerId,
        'priceInfoList': _priceOptions.map((p) => p.toJson()).toList(),
        'categoryIdList': _selectedCategoryIds,
        'imageData': combinedImageData,
      };

      print('serviceData: $serviceData');

      if (widget.service == null) {
        print('새 서비스 생성 중...');

        await ref
            .read(photoServiceProvider.notifier)
            .createService(serviceData);
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('서비스가 성공적으로 등록되었습니다')));
      } else {
        print('기존 서비스 수정 중... ID: ${widget.service!.id}');

        await ref
            .read(photoServiceProvider.notifier)
            .updateService(widget.service!.id, serviceData);
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('서비스가 성공적으로 수정되었습니다')));
        print('서비스 수정 완료');
      }
      print('Navigator.pop 호출.');

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (error) {
      print('서비스 저장 실패: $error');

      ErrorHandler.handleError(
        context,
        error,
        customMessage: widget.service == null
            ? '서비스 등록 중 오류가 발생했습니다'
            : '서비스 수정 중 오류가 발생했습니다',
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showValidationError() {
    String message = '';
    if (_selectedCategoryIds.isEmpty) {
      message = '카테고리를 선택해주세요.';
    } else if (_priceOptions.isEmpty) {
      message = '최소 하나의 가격 패키지를 추가해주세요.';
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

  void _showDeleteConfirmDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('서비스 삭제'),
        content: const Text('이 서비스를 삭제하시겠습니까?\n삭제된 서비스는 복구할 수 없습니다.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: const Text('취소')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteService();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteService() async {
    if (widget.service == null) return;
    setState(() => _isLoading = true);
    try {
      await ref
          .read(photoServiceProvider.notifier)
          .deleteService(widget.service!.id);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('서비스가 성공적으로 삭제되었습니다')));
      Navigator.pop(context);
    } catch (error) {
      ErrorHandler.handleError(context, error,
          customMessage: '서비스 삭제 중 오류가 발생했습니다');
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
