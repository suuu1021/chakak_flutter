import 'package:flutter/material.dart';

import '../../../_core/constants/app_strings.dart';
import '../../widgets/custom_button_widgets.dart';
import '../../widgets/custom_logo.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.login),
        centerTitle: true,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomLogo(AppStrings.appNameUpper),
            const SizedBox(height: 32),

            // 이메일 입력
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: AppStrings.email,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // 비밀번호 입력
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: AppStrings.password,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            // 로그인 버튼
            CustomButtonWidgets.button(context, AppStrings.login),
            const SizedBox(height: 12),
            // 회원가입 이동 텍스트 버튼
            TextButton(
              onPressed: () {
                print("회원가입 화면으로 이동");
                // Navigator.pushNamed(context, '/signup'); <- 나중에 연결
              },
              child: const Text("회원가입 하기"),
            ),
          ],
        ),
      ),
    );
  }
}
