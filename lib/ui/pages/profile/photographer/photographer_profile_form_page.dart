import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../_core/constants/app_colors.dart';
import '../../../../_core/constants/app_sizes.dart';
import '../../../../data/models/photographer_profile.dart';
import '../../../../provider/global/photographer_profile/photographer_profile_notifier.dart';
import 'widgets/profile_image_widget.dart';
import 'widgets/profile_form_fields.dart';
import 'widgets/profile_save_button.dart';

class PhotographerProfileFormPage extends ConsumerStatefulWidget {
  const PhotographerProfileFormPage({super.key});

  @override
  ConsumerState<PhotographerProfileFormPage> createState() =>
      _PhotographerProfileFormPageState();
}

class _PhotographerProfileFormPageState
    extends ConsumerState<PhotographerProfileFormPage> {
  final _formKey = GlobalKey<FormState>();

  // 컨트롤러들
  final _businessNameController = TextEditingController();
  final _introductionController = TextEditingController();
  final _locationController = TextEditingController();
  final _experienceYearsController = TextEditingController();

  String _selectedStatus = '활성';
  String? _profileImageUrl;

  @override
  void initState() {
    super.initState();
    // 내 프로필 조회
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(photographerProfileProvider.notifier).loadMyProfile();
    });
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _introductionController.dispose();
    _locationController.dispose();
    _experienceYearsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Provider 상태 감지
    ref.listen(photographerProfileProvider, (previous, next) {
      // 에러 처리
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: AppColors.error,
          ),
        );
        // 에러 메시지 초기화
        ref.read(photographerProfileProvider.notifier).clearError();
      }

      // 프로필 로드 완료 시 폼 초기화
      if (previous?.profile != next.profile && next.profile != null) {
        _initializeFormWithProfile(next.profile!);
      }
    });

    final isLoading = ref.watch(isProfileLoadingProvider);

    return Scaffold(
      appBar: _buildAppBar(),
      body: isLoading ? _buildLoadingBody() : _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final hasProfile = ref.watch(hasProfileProvider);

    return AppBar(
      title: Text(
        hasProfile ? '프로필 수정' : '프로필 등록',
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      actions: [
        TextButton(
          onPressed: _handleSave,
          child: Text(
            '저장',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingBody() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.spacing16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProfileImageWidget(
              profileImageUrl: _profileImageUrl,
              onImageChanged: (imagePath) {
                setState(() {
                  _profileImageUrl = imagePath;
                });
              },
            ),
            const SizedBox(height: AppSizes.spacing24),
            ProfileFormFields(
              businessNameController: _businessNameController,
              introductionController: _introductionController,
              locationController: _locationController,
              experienceYearsController: _experienceYearsController,
              selectedStatus: _selectedStatus,
              onStatusChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedStatus = value;
                  });
                }
              },
            ),
            const SizedBox(height: AppSizes.spacing32),
            ProfileSaveButton(
              isLoading: ref.watch(isProfileLoadingProvider),
              hasProfile: ref.watch(hasProfileProvider),
              onPressed: _handleSave,
            ),
          ],
        ),
      ),
    );
  }

  void _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final success =
        await ref.read(photographerProfileProvider.notifier).saveProfile(
              businessName: _businessNameController.text,
              introduction: _introductionController.text,
              location: _locationController.text,
              experienceYears: _experienceYearsController.text.isNotEmpty
                  ? int.tryParse(_experienceYearsController.text)
                  : null,
              displayStatus: _selectedStatus,
              profileImageUrl: _profileImageUrl,
            );

    if (success && mounted) {
      final hasProfile = ref.read(hasProfileProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            hasProfile ? '프로필이 수정되었습니다.' : '프로필이 등록되었습니다.',
          ),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context, true); // 성공 결과와 함께 이전 화면으로
    }
  }

  /// 프로필 데이터로 폼 초기화
  void _initializeFormWithProfile(PhotographerProfile profile) {
    _businessNameController.text = profile.businessName;
    _introductionController.text = profile.introduction ?? '';
    _locationController.text = profile.location;
    _experienceYearsController.text = profile.experienceYears?.toString() ?? '';

    setState(() {
      _selectedStatus = _getDisplayStatus(profile.status);
      _profileImageUrl = profile.profileImageUrl;
    });
  }

  /// API 상태 → 화면 상태 변환
  String _getDisplayStatus(String apiStatus) {
    switch (apiStatus) {
      case 'active':
        return '활성';
      case 'inactive':
        return '비활성';
      default:
        return '활성';
    }
  }
}
