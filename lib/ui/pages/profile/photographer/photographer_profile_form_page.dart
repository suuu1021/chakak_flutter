import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../_core/constants/app_colors.dart';
import '../../../../_core/constants/app_sizes.dart';

import '../../../../data/models/photographer/photographer_profile.dart';
import '../../../../provider/auth/session_provider.dart';

import '../../../../provider/photographer_profile/photographer_profile_notifier.dart';
import 'widgets/profile_form_fields.dart';
import 'widgets/profile_image_widget.dart';
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

  String? _profileImageUrl;
  bool _requestedLoad = false;

  @override
  void initState() {
    super.initState();
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
    ref.listen(photographerProfileProvider, (previous, next) {
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: AppColors.error,
          ),
        );
        ref.read(photographerProfileProvider.notifier).clearError();
      }
      if (previous?.profile != next.profile && next.profile != null) {
        _initializeFormWithProfile(next.profile!);
      }
    });

    final session = ref.watch(sessionProvider);
    if (session.isLogin && !_requestedLoad) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_requestedLoad) {
          _requestedLoad = true;
          ref.read(photographerProfileProvider.notifier).loadMyProfile();
        }
      });
    }

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
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
      backgroundColor: AppColors.primaryLight,
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
    return const Center(child: CircularProgressIndicator());
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

    print('[DEBUG] PhotographerProfileFormPage._handleSave 호출');
    final bool wasEditMode =
        ref.read(photographerProfileProvider.select((s) => s.isEditMode));

    try {
      final success =
          await ref.read(photographerProfileProvider.notifier).saveProfile(
                businessName: _businessNameController.text,
                introduction: _introductionController.text,
                location: _locationController.text,
                experienceYears: _experienceYearsController.text.isNotEmpty
                    ? int.tryParse(_experienceYearsController.text)
                    : null,
                profileImageUrl: _profileImageUrl,
              );

      print('[DEBUG] PhotographerProfileFormPage._handleSave 결과: $success');

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(wasEditMode ? '프로필이 수정되었습니다.' : '프로필이 등록되었습니다.'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context, 'refresh');
      } else if (mounted) {
        final err = ref.read(profileErrorMessageProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(err ?? '프로필 저장에 실패했습니다.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e, st) {
      print('[DEBUG] PhotographerProfileFormPage._handleSave 예외: $e\n$st');
      if (mounted) {
        final err = ref.read(profileErrorMessageProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(err ?? '프로필 저장 중 예외가 발생했습니다.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _initializeFormWithProfile(PhotographerProfile profile) {
    _businessNameController.text = profile.businessName;
    _introductionController.text = profile.introduction ?? '';
    _locationController.text = profile.location;
    _experienceYearsController.text = profile.experienceYears?.toString() ?? '';

    setState(() {
      _profileImageUrl = profile.profileImageUrl;
    });
  }
}
