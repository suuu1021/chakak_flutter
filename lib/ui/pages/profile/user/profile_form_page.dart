import 'package:chakak_flutter/data/dtos/user_profile_dto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../_core/constants/app_colors.dart';
import '../../../../../_core/constants/app_sizes.dart';
import '../../../../_core/constants/size.dart';
import '../../../../data/models/user_profile.dart';
import '../../../../provider/global/user_profile/user_profile_provider.dart';

class ProfileFormPage extends ConsumerStatefulWidget {
  final UserProfile userProfile;

  const ProfileFormPage({Key? key, required this.userProfile}) : super(key: key);

  @override
  ConsumerState<ProfileFormPage> createState() => _ProfileFormPageState();
}

class _ProfileFormPageState extends ConsumerState<ProfileFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nicknameController;
  late final TextEditingController _introduceController;

  @override
  void initState() {
    super.initState();
    _nicknameController = TextEditingController(text: widget.userProfile.displayName);
    _introduceController = TextEditingController(text: widget.userProfile.introduce ?? '');
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _introduceController.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();

    if (_formKey.currentState!.validate()) {
      final requestDto = UserProfileUpdateRequestDto(
        nickName: _nicknameController.text,
        introduce: _introduceController.text,
        // imageData는 이번 버전에서 수정하지 않으므로 null 또는 기존 값 전달
      );

      ref.read(userProfileProvider.notifier).updateProfile(requestDto).then((success) {
        if (mounted) {
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('프로필이 성공적으로 수정되었습니다.')),
            );
            Navigator.pop(context, true); // 성공 시 true 반환
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(ref.read(userProfileProvider).errorMessage ?? '프로필 수정에 실패했습니다.')),
            );
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('프로필 수정'),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSizes.spacing16),
          children: [
            _buildNicknameField(),
            const SizedBox(height: AppSizes.spacing24),
            _buildIntroduceField(),
            const SizedBox(height: AppSizes.spacing32),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildNicknameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('닉네임', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: smallGap),
        TextFormField(
          controller: _nicknameController,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '닉네임을 입력해주세요.';
            }
            if (value.length < 2 || value.length > 20) {
              return '닉네임은 2자 이상 20자 이하로 입력해주세요.';
            }
            return null;
          },
          decoration: InputDecoration(
            hintText: "2자 이상 20자 이하",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  Widget _buildIntroduceField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('자기소개', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: smallGap),
        TextFormField(
          controller: _introduceController,
          maxLines: 5,
          maxLength: 100,
          decoration: InputDecoration(
            hintText: '자신을 소개해주세요',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            counterText: '',
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    final isUpdating = ref.watch(userProfileProvider).isUpdating;

    return ElevatedButton(
      onPressed: isUpdating ? null : _submit,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        minimumSize: const Size(double.infinity, 50),
      ),
      child: isUpdating
          ? const CircularProgressIndicator(color: Colors.white)
          : const Text('저장', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }
}
