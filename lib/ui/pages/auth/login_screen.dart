import 'package:chakak_flutter/_core/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../_core/constants/app_colors.dart';
import '../../../_core/utils/validator_util.dart';
import '../../../data/dtos/auth_dto.dart';
import '../../../provider/auth/session_provider.dart';
import '../../../provider/auth/auth_provider.dart';
import '../../widgets/custom_auth_button_widgets.dart';
import '../../widgets/custom_auth_text_form_field.dart';
import '../../widgets/custom_logo.dart';
import 'signup_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  // ==================== 시연용 미리 입력된 계정 (영상 촬영 후 삭제) ====================
  String email = "user1@example.com";
  String password = "123456";
  // ==================== 시연용 미리 입력된 계정 끝 ====================

  // 기존 코드 (주석 보관): String email = ""; String password = "";
  String emailError = "";
  String passwordError = "";

  void _login() async {
    // 유효성 검사
    if (email.isEmpty || validateEmail(email).isNotEmpty) {
      setState(() => emailError = "올바른 이메일을 입력하세요");
      return;
    }
    if (password.isEmpty || password.length < 6) {
      setState(() => passwordError = "비밀번호를 6자 이상 입력하세요");
      return;
    }

    print("[LoginScreen] 로그인 버튼 클릭. authProvider.login() 호출 시도.");

    try {
      await ref.read(authProvider.notifier).login(
            LoginRequest(email: email, password: password),
          );

      print(
          "[LoginScreen] authProvider.login() 호출 성공. 화면 이동은 Session 상태 변경에 따라 자동으로 처리됩니다.");
    } catch (e) {
      print("[LoginScreen] !!!!! 로그인 과정에서 에러 발생 !!!!!: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("로그인에 실패했습니다. 아이디 또는 비밀번호를 확인해주세요."),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    ref.listen(sessionProvider, (previous, next) {
      if (next.isLogin) {
        print(
            "[LoginScreen] SessionProvider의 isLogin 상태가 true로 변경됨을 감지! 홈 화면으로 이동합니다.");
        Navigator.pushReplacementNamed(context, '/home');
      }
    });

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text("로그인"),
        centerTitle: true,
        backgroundColor: AppColors.primaryLight,
        foregroundColor: Colors.black,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const SizedBox(height: 80),
              const CustomLogo(AppStrings.appNameUpper),
              const SizedBox(height: 24),
              CustomAuthTextFormField(
                title: "이메일",
                initialValue: email, // 시연용 초기값
                errorText: emailError,
                onChanged: (v) => setState(() {
                  email = v;
                  emailError = "";
                }),
              ),
              const SizedBox(height: 16),
              CustomAuthTextFormField(
                title: "비밀번호",
                initialValue: password, // 시연용 초기값
                obscureText: true,
                errorText: passwordError,
                onChanged: (v) => setState(() {
                  password = v;
                  passwordError = "";
                }),
              ),
              const SizedBox(height: 32),
              CustomAuthButtonWidgets.button(
                context,
                authState.isProgress ? "로그인 중..." : "로그인",
                onPressed:
                    authState.isProgress ? null : _login, // 로그인 중일 때는 버튼 비활성화
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SignupScreen()),
                  );
                },
                child: const Text(
                  "아직 회원이 아니신가요? 회원가입",
                  style: TextStyle(color: AppColors.primaryDark),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
