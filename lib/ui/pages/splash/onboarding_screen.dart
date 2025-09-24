import 'package:chakak_flutter/ui/widgets/custom_logo.dart';
import 'package:flutter/material.dart';

import '../../../_core/constants/app_colors.dart';
import '../../../_core/constants/app_strings.dart';
import '../../../_core/constants/app_images.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 배경 이미지
          // SizedBox.expand(
          //   child: Image.asset(
          //     AppImages.onboarding2,
          //     fit: BoxFit.cover,
          //   ),
          // ),

          // 반투명 오버레이
          Container(
            color: Colors.white.withOpacity(0.6),
          ),

          // 중앙 로고 + 메시지
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                CustomLogo(AppStrings.appNameUpper),
                SizedBox(height: 16),
                Text(
                  AppStrings.onboardingMessage,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    shadows: [
                      Shadow(
                        offset: Offset(0, 1),
                        blurRadius: 3,
                        color: Colors.white,
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          // 하단 시작하기 버튼
          Positioned(
            left: 24,
            right: 24,
            bottom: 40,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: double.infinity, // 버튼 가로 전체
                  child: ElevatedButton(
                    onPressed: () {
                      // 👉 로그인 선택 화면으로 이동
                      Navigator.pushReplacementNamed(context, '/login-choice');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "시작하기",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () {
                    // 👉 바로 회원가입 화면으로 이동 (선택 사항)
                    Navigator.pushNamed(context, '/signup');
                  },
                  child: const Text(
                    "계정이 없으신가요? 회원가입",
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.black,
                      decoration: TextDecoration.underline,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
