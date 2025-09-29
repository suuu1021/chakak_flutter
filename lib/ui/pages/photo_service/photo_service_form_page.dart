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
import '../../../data/models/photographer/photo_service_category.dart';
import '../../../provider/photoService/photo_service_provider.dart';

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

  List<Object> _selectedImages = [];
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

    if (service.imageUrl != null && service.imageUrl!.isNotEmpty) {
      _selectedImages = [service.imageUrl!];
    }

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
              ..._selectedImages.asMap().entries.map((entry) {
                final index = entry.key;
                final image = entry.value;

                if (image is File) {
                  return _buildNewImageItem(image, index);
                } else if (image is String) {
                  return _buildExistingImageItem(image, index);
                }
                return const SizedBox.shrink();
              }),
              _buildAddImageButton(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExistingImageItem(String imageData, int index) {
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
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 120,
                        height: 120,
                        color: Colors.grey[200],
                        child: const Center(
                          child: Icon(Icons.broken_image,
                              color: Colors.grey, size: 40),
                        ),
                      );
                    },
                  )
                : _buildBase64Image(imageData),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () => _removeImage(index),
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

  Widget _buildBase64Image(String imageData) {
    try {
      String base64String = imageData;
      if (imageData.startsWith('data:image')) {
        base64String = imageData.split(',').last;
      }

      final bytes = base64Decode(base64String);
      return Image.memory(
        bytes,
        width: 120,
        height: 120,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 120,
            height: 120,
            color: Colors.grey[200],
            child: const Center(
              child: Icon(Icons.broken_image, color: Colors.grey, size: 40),
            ),
          );
        },
      );
    } catch (e) {
      return Container(
        width: 120,
        height: 120,
        color: Colors.grey[200],
        child: const Center(
          child: Icon(Icons.broken_image, color: Colors.grey, size: 40),
        ),
      );
    }
  }

  Widget _buildNewImageItem(File imageFile, int index) {
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
              onTap: () => _removeImage(index),
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

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _saveService() async {
    if (!_formKey.currentState!.validate() || _selectedCategoryIds.isEmpty) {
      _showValidationError();
      return;
    }

    if (_selectedImages.isEmpty) {
      _showErrorDialog('최소 하나의 이미지를 추가하세요');
      return;
    }

    setState(() => _isLoading = true);

    try {
      String? imageDataToSend;

      // 새 이미지가 있으면 압축하여 Base64 인코딩
      if (_selectedImages.any((image) => image is File)) {
        final newFiles = _selectedImages.whereType<File>().toList();
        final imageFile = newFiles.first;

        // 이미지 크기 줄이기
        final bytes = await imageFile.readAsBytes();

        // 크기가 크면 품질 낮춰서 다시 인코딩
        if (bytes.length > 500000) {
          // 500KB 이상이면
          print('이미지가 커서 압축 필요: ${bytes.length} bytes');

          // Flutter의 image 패키지를 사용한 압축 (별도 구현 필요)
          // 또는 단순히 품질을 낮춰서 다시 선택하도록 안내
          _showErrorDialog('이미지 크기가 너무 큽니다. 더 작은 이미지를 선택해주세요.');
          return;
        }

        imageDataToSend = base64Encode(bytes);
      } else if (_selectedImages.any((image) => image is String)) {
        // 기존 이미지 URL 사용
        imageDataToSend = _selectedImages.whereType<String>().first;
      }

      final serviceData = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'photographerId': widget.photographerId,
        'priceInfoList': _priceOptions.map((p) => p.toJson()).toList(),
        'categoryIdList': _selectedCategoryIds,
        'imageData': imageDataToSend,
      };

      print('=== 전송 전 최종 확인 ===');
      print(
          '이미지 데이터 타입: ${imageDataToSend?.startsWith('http') == true ? 'URL' : 'Base64'}');
      print('이미지 데이터 길이: ${imageDataToSend?.length ?? 0}');

      if (widget.service == null) {
        await ref
            .read(photoServiceProvider.notifier)
            .createService(serviceData);
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('서비스가 성공적으로 등록되었습니다')));
      } else {
        await ref
            .read(photoServiceProvider.notifier)
            .updateService(widget.service!.id, serviceData);
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('서비스가 성공적으로 수정되었습니다')));
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (error) {
      if (mounted) {
        ErrorHandler.handleError(
          context,
          error,
          customMessage: widget.service == null
              ? '서비스 등록 중 오류가 발생했습니다'
              : '서비스 수정 중 오류가 발생했습니다',
        );
      }
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
