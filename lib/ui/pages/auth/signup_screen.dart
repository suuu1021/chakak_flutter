import 'package:flutter/material.dart';
import '../../widgets/custom_button_widgets.dart';
import '../../widgets/custom_auth_text_form_field.dart';
import '../../widgets/custom_logo.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  String email = "";
  String emailError = "";
  String code = "";
  String codeError = "";
  String password = "";
  String passwordError = "";
  String confirmPassword = "";
  String confirmPasswordError = "";
  String userType = "user"; // 기본값: 개인 회원

  bool isLoading = false; // 로딩 상태

  Future<void> _signup() async {
    setState(() {
      emailError = "";
      codeError = "";
      passwordError = "";
      confirmPasswordError = "";
    });

    // 간단한 검증
    if (email.isEmpty || !email.contains("@")) {
      setState(() => emailError = "올바른 이메일을 입력하세요");
      return;
    }
    if (code.isEmpty) {
      setState(() => codeError = "인증코드를 입력하세요");
      return;
    }
    if (password.length < 6) {
      setState(() => passwordError = "비밀번호는 6자 이상이어야 합니다");
      return;
    }
    if (password != confirmPassword) {
      setState(() => confirmPasswordError = "비밀번호가 일치하지 않습니다");
      return;
    }

    // Mock 네트워크 호출
    setState(() => isLoading = true);
    await Future.delayed(const Duration(seconds: 2)); // 서버 기다리는 척
    setState(() => isLoading = false);

    print("✅ 회원가입 성공!");
    print("이메일: $email");
    print("코드: $code");
    print("비밀번호: $password");
    print("회원 유형: $userType");

    if (mounted) {
      Navigator.pop(context); // 로그인 화면으로 이동
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("회원가입"),
        centerTitle: true,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CustomLogo("chakak"),
            const SizedBox(height: 16),

            // 이메일 입력
            CustomAuthTextFormField(
              title: "이메일",
              errorText: emailError,
              onChanged: (value) {
                setState(() => email = value);
              },
            ),
            const SizedBox(height: 16),

            // 인증코드 입력
            CustomAuthTextFormField(
              title: "인증코드",
              errorText: codeError,
              onChanged: (value) {
                setState(() => code = value);
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
            const SizedBox(height: 16),

            // 비밀번호 확인
            CustomAuthTextFormField(
              title: "비밀번호 확인",
              errorText: confirmPasswordError,
              obscureText: true,
              onChanged: (value) {
                setState(() => confirmPassword = value);
              },
            ),
            const SizedBox(height: 24),

            // 회원 유형 선택
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Radio<String>(
                  value: "user",
                  groupValue: userType,
                  onChanged: (value) {
                    setState(() => userType = value!);
                  },
                ),
                const Text("개인 회원"),
                const SizedBox(width: 20),
                Radio<String>(
                  value: "photographer",
                  groupValue: userType,
                  onChanged: (value) {
                    setState(() => userType = value!);
                  },
                ),
                const Text("포토그래퍼 회원"),
              ],
            ),
            const SizedBox(height: 24),

            // 회원가입 버튼
            isLoading
                ? const CircularProgressIndicator()
                : CustomButtonWidgets.button(
              context,
              "회원가입",
              onPressed: _signup,
            ),

            const SizedBox(height: 12),

            // 로그인으로 돌아가기 버튼
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("로그인으로 돌아가기"),
            ),
          ],
        ),
      ),
    );
  }
}
