import 'package:flutter/material.dart';
import '../../widgets/custom_auth_text_form_field.dart';
import '../../widgets/custom_logo.dart';
import '../../widgets/custom_auth_button_widgets.dart'; // ✅ 여기서 버튼 가져옴
import '../../../_core/utils/validator_util.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String email = "";
  String emailError = "";
  String password = "";
  String passwordError = "";

  void _login() {
    if (email.isEmpty || validateEmail(email).isNotEmpty) {
      setState(() => emailError = "올바른 이메일을 입력하세요");
      return;
    }
    if (password.isEmpty || password.length < 6) {
      setState(() => passwordError = "비밀번호를 6자 이상 입력하세요");
      return;
    }

    // TODO: 실제 로그인 API 연동
    debugPrint("로그인 시도: $email / $password");

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("로그인 성공 (더미)")),
    );

    // 로그인 성공 → 홈으로 이동
    // Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // ✅ 키보드 열릴 때 화면 자동 조정
      appBar: AppBar(
        title: const Text("로그인"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const CustomLogo("CHAKAK"),
              const SizedBox(height: 24),

              // 이메일 입력
              CustomAuthTextFormField(
                title: "이메일",
                errorText: emailError,
                onChanged: (v) => setState(() {
                  email = v;
                  emailError = "";
                }),
              ),
              const SizedBox(height: 16),

              // 비밀번호 입력
              CustomAuthTextFormField(
                title: "비밀번호",
                obscureText: true,
                errorText: passwordError,
                onChanged: (v) => setState(() {
                  password = v;
                  passwordError = "";
                }),
              ),
              const SizedBox(height: 32),

              // 로그인 버튼 (✅ 공통 위젯 사용)
              CustomAuthButtonWidgets.button(
                context,
                "로그인",
                onPressed: _login,
              ),
              const SizedBox(height: 16),

              // 회원가입 이동
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SignupScreen()),
                  );
                },
                child: const Text("아직 회원이 아니신가요? 회원가입"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
