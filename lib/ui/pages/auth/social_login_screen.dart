import 'package:flutter/material.dart';
import '../../../_core/constants/app_strings.dart';
import '../../widgets/custom_logo.dart';
import 'profile_setup_screen.dart';

class SocialLoginScreen extends StatelessWidget {
  const SocialLoginScreen({super.key});

  void _mockSocialLogin(BuildContext context, String provider) async {
    //소셜 로그인 Mock 동작 (나중에 API 연동 시 교체)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("$provider 로그인 시도 중...")),
    );

    await Future.delayed(const Duration(seconds: 2)); // 네트워크 대기 흉내

    // 소셜 로그인 성공 시 → 프로필 설정 화면으로 이동
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const ProfileSetupScreen(userType: "social"),
      ),
    );
  }

  Widget _buildSocialButton({
    required BuildContext context,
    required String text,
    required String provider,
    required String assetPath,
    required Color backgroundColor,
    required Color textColor,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _mockSocialLogin(context, provider),
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
  Widget build(BuildContext context) {
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
              context: context,
              text: "카카오로 로그인",
              provider: "카카오",
              assetPath: "assets/images/kakaotalk-seeklogo.png",
              backgroundColor: const Color(0xFFFEE500),
              textColor: Colors.black,
            ),
            const SizedBox(height: 16),

            // 네이버 로그인 버튼
            _buildSocialButton(
              context: context,
              text: "네이버로 로그인",
              provider: "네이버",
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
