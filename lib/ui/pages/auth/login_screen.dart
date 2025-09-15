import 'package:chakak_flutter/_core/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/dtos/auth_dto.dart';
import '../../../provider/auth_provider.dart';
import '../../widgets/custom_auth_text_form_field.dart';
import '../../widgets/custom_logo.dart';
import '../../widgets/custom_auth_button_widgets.dart'; // ✅ 여기서 버튼 가져옴
import '../../../_core/utils/validator_util.dart';
import 'signup_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
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

    // Riverpod 호출
    ref.read(authProvider.notifier).login(
          LoginRequest(email: email, password: password),
        );

    // 로그인 성공 → 홈으로 이동
    // Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider); // 상태 구독 가능

    // 로그인 성공 시 - > 홈 화면으로 이동
    if (authState.login != null) {
      Navigator.pushReplacementNamed(context, '/home');
    }

    return Scaffold(
      resizeToAvoidBottomInset: true, // ✅ 키보드 열릴 때 화면 자동 조정
      appBar: AppBar(
        title: const Text("로그인"),
        centerTitle: true,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const CustomLogo(AppStrings.appNameUpper),
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

              // 비밀번호 입력////
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
                authState.login == null ? "로그인" : "로그인 중...",
                onPressed: authState.login == null ? _login : null,
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
