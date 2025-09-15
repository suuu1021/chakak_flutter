import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../_core/constants/app_colors.dart';
import '../../../../../_core/constants/app_sizes.dart';

class ProfileImageWidget extends StatefulWidget {
  final String? profileImageUrl;
  final ValueChanged<String?> onImageChanged;

  const ProfileImageWidget({
    super.key,
    this.profileImageUrl,
    required this.onImageChanged,
  });

  @override
  State<ProfileImageWidget> createState() => _ProfileImageWidgetState();
}

class _ProfileImageWidgetState extends State<ProfileImageWidget> {
  final ImagePicker _picker = ImagePicker();
  File? _selectedImageFile;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: _showImagePickerDialog,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.gray200,
                border: Border.all(
                  color: AppColors.gray300,
                  width: 2,
                ),
              ),
              child: _buildImageContent(),
            ),
          ),
          const SizedBox(height: AppSizes.spacing8),
          Text(
            '프로필 사진 변경',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageContent() {
    // 새로 선택한 로컬 이미지가 있으면 우선 표시
    if (_selectedImageFile != null) {
      return ClipOval(
        child: Image.file(
          _selectedImageFile!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildImagePlaceholder();
          },
        ),
      );
    }

    // 기존 네트워크 이미지가 있으면 표시
    if (widget.profileImageUrl != null) {
      return ClipOval(
        child: Image.network(
          widget.profileImageUrl!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildImagePlaceholder();
          },
        ),
      );
    }

    // 둘 다 없으면 플레이스홀더 표시
    return _buildImagePlaceholder();
  }

  Widget _buildImagePlaceholder() {
    return const Icon(
      Icons.camera_alt_outlined,
      size: 40,
      color: AppColors.gray500,
    );
  }

  void _showImagePickerDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppSizes.spacing16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('카메라로 촬영'),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromCamera();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('갤러리에서 선택'),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromGallery();
              },
            ),
            if (_selectedImageFile != null || widget.profileImageUrl != null)
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('사진 삭제'),
                onTap: () {
                  Navigator.pop(context);
                  _removeImage();
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _selectedImageFile = File(image.path);
        });
        // 선택된 이미지 파일 경로를 부모에게 전달
        widget.onImageChanged(image.path);
      }
    } catch (e) {
      _showErrorDialog('카메라 촬영 중 오류가 발생했습니다.');
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _selectedImageFile = File(image.path);
        });
        // 선택된 이미지 파일 경로를 부모에게 전달
        widget.onImageChanged(image.path);
      }
    } catch (e) {
      _showErrorDialog('갤러리에서 이미지 선택 중 오류가 발생했습니다.');
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImageFile = null;
    });
    // 이미지 제거를 부모에게 전달
    widget.onImageChanged(null);
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('오류'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }
}
