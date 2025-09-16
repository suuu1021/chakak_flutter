import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../_core/constants/app_colors.dart';
import '../../../../_core/constants/app_sizes.dart';
import '../../../../_core/constants/user_type.dart';
import '../../../../data/models/user_profile.dart';
import '../../../../data/models/photographer_profile.dart';
import '../../../widgets/custom_button_widgets.dart';
import 'widgets/profile_image_picker.dart';
import 'widgets/user_profile_form.dart';
import 'widgets/photographer_profile_form.dart';

class ProfileFormPage extends ConsumerStatefulWidget {
  final UserType userType;
  final dynamic currentProfile;

  const ProfileFormPage({
    super.key,
    required this.userType,
    required this.currentProfile,
  });

  @override
  ConsumerState<ProfileFormPage> createState() => _ProfileFormPageState();
}

class _ProfileFormPageState extends ConsumerState<ProfileFormPage> {
  File? _profileImage;
  String? _profileImageUrl;
  bool _isLoading = false;

  // 폼 데이터 저장용
  Map<String, dynamic> _formData = {};
  Map<String, String> _errors = {};

  @override
  void initState() {
    super.initState();
    _loadCurrentProfile();
  }

  void _loadCurrentProfile() {
    if (widget.currentProfile == null) return;

    if (widget.userType == UserType.user) {
      final profile = widget.currentProfile as UserProfile;
      _formData = {
        'nickName': profile.nickName ?? '',
        'introduce': profile.introduce ?? '',
      };
      _profileImageUrl = profile.imageData;
    } else if (widget.userType == UserType.photographer) {
      final profile = widget.currentProfile as PhotographerProfile;
      _formData = {
        'businessName': profile.businessName ?? '',
        'introduction': profile.introduction ?? '',
        'location': profile.location ?? '',
        'experienceYears': profile.experienceYears?.toString() ?? '',
        'status': profile.status ?? 'ACTIVE',
      };
      _profileImageUrl = profile.profileImageUrl;
    }
  }

  void _onFormDataChanged(String key, String value) {
    setState(() {
      _formData[key] = value;
      _errors.remove(key); // 입력 시 에러 메시지 제거
    });
  }

  void _onImageChanged(File? image) {
    setState(() {
      _profileImage = image;
    });
  }

  bool _validateForm() {
    _errors.clear();

    if (widget.userType == UserType.user) {
      if (_formData['nickName']?.trim().isEmpty ?? true) {
        _errors['nickName'] = '닉네임을 입력해주세요';
      }
      if ((_formData['nickName']?.length ?? 0) > 20) {
        _errors['nickName'] = '닉네임은 20자 이하로 입력해주세요';
      }
    } else {
      if (_formData['businessName']?.trim().isEmpty ?? true) {
        _errors['businessName'] = '상호명을 입력해주세요';
      }
      final years = int.tryParse(_formData['experienceYears'] ?? '');
      if (years != null && (years < 0 || years > 50)) {
        _errors['experienceYears'] = '올바른 경력 연수를 입력해주세요 (0-50년)';
      }
    }

    setState(() {}); // 에러 메시지 표시
    return _errors.isEmpty;
  }

  bool _hasChanges() {
    if (_profileImage != null) return true;

    if (widget.userType == UserType.user) {
      final current = widget.currentProfile as UserProfile?;
      return _formData['nickName'] != (current?.nickName ?? '') ||
          _formData['introduce'] != (current?.introduce ?? '');
    } else {
      final current = widget.currentProfile as PhotographerProfile?;
      return _formData['businessName'] != (current?.businessName ?? '') ||
          _formData['introduction'] != (current?.introduction ?? '') ||
          _formData['location'] != (current?.location ?? '') ||
          _formData['experienceYears'] !=
              (current?.experienceYears?.toString() ?? '') ||
          _formData['status'] != (current?.status ?? 'ACTIVE');
    }
  }

  Future<void> _saveProfile() async {
    if (!_validateForm()) return;

    if (!_hasChanges()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('변경된 내용이 없습니다')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // TODO: 실제 API 호출
      await Future.delayed(const Duration(seconds: 1));

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('프로필이 수정되었습니다')),
      );

      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('저장 실패: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getScreenTitle()),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.spacing16),
        child: Column(
          children: [
            ProfileImagePicker(
              currentImageUrl: _profileImageUrl,
              selectedImage: _profileImage,
              onImageChanged: _onImageChanged,
            ),
            const SizedBox(height: AppSizes.spacing24),
            _buildForm(),
            const SizedBox(height: AppSizes.spacing32),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  String _getScreenTitle() {
    return widget.userType == UserType.photographer ? '포토그래퍼 프로필 편집' : '프로필 편집';
  }

  Widget _buildForm() {
    if (widget.userType == UserType.user) {
      return UserProfileForm(
        formData: _formData,
        errors: _errors,
        onDataChanged: _onFormDataChanged,
      );
    } else {
      return PhotographerProfileForm(
        formData: _formData,
        errors: _errors,
        onDataChanged: _onFormDataChanged,
      );
    }
  }

  Widget _buildSaveButton() {
    return _isLoading
        ? const CircularProgressIndicator()
        : CustomButtonWidgets.button(
            context,
            '저장하기',
            onPressed: _saveProfile,
          );
  }
}
