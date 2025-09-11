
import 'package:flutter/material.dart';

import '../../widgets/logo.dart';
import '../../widgets/social_login_button.dart';

class SocialLoginScreen extends StatelessWidget {
  const SocialLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 로고
              const LogoWidget(),
              const SizedBox(height: 12),

              // 설명 텍스트
              const Text(
                "찰칵과 함께 나만의 추억을 남겨보세요!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 40),

              SocialLoginButton(
                type: SocialLoginType.kakao,
                onPressed: () {
                },
              ),
              const SizedBox(height: 16),


              SocialLoginButton(
                type: SocialLoginType.naver,
                onPressed: () {
                  print("네이버 로그인 클릭");
                },
              ),
              const SizedBox(height: 24),

              // 하단 링크
              Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      print("이메일로 로그인 / 회원가입 클릭");
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    child: const Text(
                      "이메일로 로그인 · 이메일로 회원가입",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () {
                      print("아이디 / 비밀번호 찾기 클릭");
                    },
                    child: const Text(
                      "아이디 / 비밀번호 찾기",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}