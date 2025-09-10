import 'package:flutter/material.dart';
import 'package:chakak_flutter/ui/pages/home/homescreen.dart';
import 'package:chakak_flutter/ui/pages/auth/signup_screen.dart';
import '../../widgets/custom_button_widgets.dart';
import '../../widgets/custom_auth_text_form_field.dart';
import '../../widgets/custom_logo.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String email = "";
  String password = "";
  String emailError = "";
  String passwordError = "";

  void _login() {
    setState(() {
      emailError = "";
      passwordError = "";

      if (email.isEmpty || !email.contains("@")) {
        emailError = "올바른 이메일을 입력하세요";
      }
      if (password.length < 6) {
        passwordError = "비밀번호는 6자 이상이어야 합니다";
      }
    });

    if (emailError.isEmpty && passwordError.isEmpty) {
      print("입력된 이메일: $email");
      print("입력된 비밀번호: $password");

      // TODO: 나중에 백엔드 API 연동
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("로그인"),
        centerTitle: true,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 커스텀 로고
            const CustomLogo("chakak"),
            const SizedBox(height: 32),

            // 이메일 입력
            CustomAuthTextFormField(
              title: "이메일",
              errorText: emailError,
              onChanged: (value) {
                setState(() => email = value);
              },
            ),
            const SizedBox(height: 16),

            // 비밀번호 입력
            CustomAuthTextFormField(
              title: "비밀번호",
              errorText: passwordError,
              obscureText: true,
              onChanged: (value) {
                setState(() => password = value);
              },
            ),
            const SizedBox(height: 24),

            // 로그인 버튼
            CustomButtonWidgets.button(
              context,
              "로그인",
              onPressed: _login,
            ),

            const SizedBox(height: 12),

            // 회원가입 이동 버튼
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SignupScreen()),
                );
              },
              child: const Text("회원가입 하기"),
            ),
          ],
        ),
      ),
    );
  }
}
