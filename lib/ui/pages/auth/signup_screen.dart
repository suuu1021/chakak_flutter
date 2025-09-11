import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../widgets/custom_auth_text_form_field.dart';
import '../../widgets/custom_logo.dart';
import '../../widgets/custom_auth_button_widgets.dart';
import '../../../_core/utils/validator_util.dart';
import 'profile_setup_screen.dart';

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
  String userType = ""; // 개인회원 / 포토그래퍼 구분

  bool isLoading = false;

  /// ✅ 이메일 인증 요청
  Future<void> _sendVerificationCode() async {
    if (isLoading) return;

    if (email.isEmpty || validateEmail(email).isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("올바른 이메일을 입력하세요")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse("http://10.0.2.2:8080/api/users/signup"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "password": password.isEmpty ? "temp1234!" : password,
          "userTypeCode": userType.isEmpty ? "user" : userType,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("인증 메일이 발송되었습니다.")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("요청 실패: ${response.statusCode} / ${response.body}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("에러 발생: $e")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  /// ✅ 이메일 인증 코드 확인
  Future<void> _verifyCode() async {
    if (isLoading) return;

    if (email.isEmpty || code.isEmpty) {
      setState(() => codeError = "이메일과 인증코드를 입력하세요");
      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse("http://10.0.2.2:8080/api/email/verify"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "code": code,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("이메일 인증 성공!")),
        );

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ProfileSetupScreen(userType: userType),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("인증 실패: ${response.body}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("에러 발생: $e")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  /// ✅ 회원 유형만 선택 후 프로필 설정으로 이동
  void _goToProfileSetup() {
    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty || userType.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("모든 정보를 입력하세요.")),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProfileSetupScreen(userType: userType),
      ),
    );
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
          children: [
            const CustomLogo("chakak"),
            const SizedBox(height: 16),

            // 이메일 입력 + 인증요청 버튼
            Row(
              children: [
                Expanded(
                  child: CustomAuthTextFormField(
                    title: "이메일",
                    errorText: emailError,
                    onChanged: (v) => setState(() => email = v),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _sendVerificationCode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 16,
                    ),
                  ),
                  child: const Text(
                    "인증요청",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 인증코드 입력 + 확인 버튼
            Row(
              children: [
                Expanded(
                  child: CustomAuthTextFormField(
                    title: "인증코드",
                    errorText: codeError,
                    onChanged: (v) => setState(() => code = v),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _verifyCode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 16,
                    ),
                  ),
                  child: const Text(
                    "코드 확인",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 비밀번호 입력
            CustomAuthTextFormField(
              title: "비밀번호",
              obscureText: true,
              errorText: passwordError,
              onChanged: (v) => setState(() => password = v),
            ),
            const SizedBox(height: 16),

            // 비밀번호 확인
            CustomAuthTextFormField(
              title: "비밀번호 확인",
              obscureText: true,
              errorText: confirmPasswordError,
              onChanged: (v) => setState(() => confirmPassword = v),
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

            // 👉 회원 유형 선택 밑에 '다음 단계로' 버튼
            ElevatedButton(
              onPressed: _goToProfileSetup,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              child: const Text(
                "다음",
                style: TextStyle(color: Colors.white),
              ),
            ),

            const SizedBox(height: 24),

            // 로그인으로 돌아가기
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("로그인으로 돌아가기"),
            ),
          ],
        ),
      ),
    );
  }
}
