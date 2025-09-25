import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../_core/constants/app_colors.dart';
import '../../widgets/custom_button_widgets.dart';
import '../../widgets/custom_auth_text_form_field.dart';
import '../home/home_screen.dart';

class ProfileSetupScreen extends StatefulWidget {
  final String userType; // "user" | "photographer" | "social"

  const ProfileSetupScreen({super.key, required this.userType});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  String nickname = "";
  String introduction = "";
  String category = "";
  String experience = "";

  String selectedType = ""; // ✅ 소셜 로그인 시 선택된 유형
  bool isLoading = false;

  File? profileImage; // ✅ 프로필 사진 파일

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);

    if (pickedFile != null) {
      setState(() {
        profileImage = File(pickedFile.path);
      });
    }
  }

  /// ✅ 프로필 저장/완료 처리
  Future<void> _completeProfile() async {
    if (nickname.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("닉네임을 입력하세요")),
      );
      return;
    }
    if (widget.userType == "social" && selectedType.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("회원 유형을 선택하세요")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      // 👉 나중에 실제 API 요청 코드 추가
      await Future.delayed(const Duration(seconds: 2));

      // 더미 로그
      debugPrint("✅ 프로필 저장 완료!");
      debugPrint("닉네임: $nickname");
      debugPrint("소개: $introduction");
      if (profileImage != null) {
        debugPrint("프로필 이미지: ${profileImage!.path}");
      }
      if (widget.userType == "photographer" ||
          (widget.userType == "social" && selectedType == "photographer")) {
        debugPrint("카테고리: $category");
        debugPrint("경력: $experience");
      }

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("저장 실패: $e")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveUserType =
        widget.userType == "social" ? selectedType : widget.userType;

    return Scaffold(
      appBar: AppBar(
        title: const Text("프로필 설정"),
        centerTitle: true,
        backgroundColor: AppColors.primaryLight,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // 프로필 이미지
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey[300],
                backgroundImage:
                    profileImage != null ? FileImage(profileImage!) : null,
                child: profileImage == null
                    ? const Icon(Icons.camera_alt,
                        size: 40, color: Colors.black54)
                    : null,
              ),
            ),
            const SizedBox(height: 24),

            // 소셜 로그인 → 회원 유형 선택
            if (widget.userType == "social") ...[
              const Text(
                "회원 유형을 선택하세요",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Radio<String>(
                    value: "user",
                    groupValue: selectedType,
                    onChanged: (v) => setState(() => selectedType = v!),
                  ),
                  const Text("개인 회원"),
                  const SizedBox(width: 20),
                  Radio<String>(
                    value: "photographer",
                    groupValue: selectedType,
                    onChanged: (v) => setState(() => selectedType = v!),
                  ),
                  const Text("포토그래퍼 회원"),
                ],
              ),
              const SizedBox(height: 16),
            ],

            // 닉네임
            CustomAuthTextFormField(
              title: "닉네임",
              onChanged: (v) => setState(() => nickname = v),
            ),
            const SizedBox(height: 16),

            // 소개
            CustomAuthTextFormField(
              title: "소개",
              onChanged: (v) => setState(() => introduction = v),
            ),
            const SizedBox(height: 16),

            // 포토그래퍼 전용 입력
            if (effectiveUserType == "photographer") ...[
              CustomAuthTextFormField(
                title: "촬영 카테고리",
                onChanged: (v) => setState(() => category = v),
              ),
              const SizedBox(height: 16),
              CustomAuthTextFormField(
                title: "경력",
                onChanged: (v) => setState(() => experience = v),
              ),
              const SizedBox(height: 16),
            ],

            const SizedBox(height: 24),

            // 완료 버튼
            isLoading
                ? const CircularProgressIndicator()
                : CustomButtonWidgets.button(
                    context,
                    "저장하고 시작하기",
                    onPressed: _completeProfile,
                    backgroundColor: AppColors.primary,
                  ),
          ],
        ),
      ),
    );
  }
}
