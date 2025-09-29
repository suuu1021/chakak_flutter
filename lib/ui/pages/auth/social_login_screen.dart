import 'package:chakak_flutter/data/dtos/auth_dto.dart';
import 'package:chakak_flutter/provider/auth/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../_core/constants/app_strings.dart';
import '../../widgets/custom_logo.dart';
import 'profile_setup_screen.dart';

class SocialLoginScreen extends ConsumerWidget {
  const SocialLoginScreen({super.key});

  void _kakaoLogin(BuildContext context, WidgetRef ref) {
    ref.read(authProvider.notifier).kakaoLogin(
          SocialLoginRequest(code: "mock_code", typeCode: "KAKAO"),
        );
  }

  Widget _buildSocialButton({
    required String text,
    required VoidCallback onPressed,
    required String assetPath,
    required Color backgroundColor,
    required Color textColor,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: Image.asset(
          assetPath,
          height: 24,
          width: 24,
        ),
        label: Text(
          text,
          style: TextStyle(
            fontSize: 16,
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    if (authState.social != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const ProfileSetupScreen(userType: "social"),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("소셜 로그인"),
        centerTitle: true,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CustomLogo(AppStrings.appNameUpper),
            const SizedBox(height: 40),

            // 카카오 로그인 버튼
            _buildSocialButton(
              text: "카카오로 로그인",
              onPressed: () => _kakaoLogin(context, ref),
              assetPath: "assets/images/kakaotalk-seeklogo.png",
              backgroundColor: const Color(0xFFFEE500),
              textColor: Colors.black,
            ),
            const SizedBox(height: 16),

            // 네이버 로그인 버튼
            _buildSocialButton(
              text: "네이버로 로그인",
              onPressed: () => _kakaoLogin(context, ref),
              assetPath: "assets/images/naver.png",
              backgroundColor: const Color(0xFF03C75A),
              textColor: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
