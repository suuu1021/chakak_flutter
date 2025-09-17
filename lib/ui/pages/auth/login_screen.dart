import 'package:chakak_flutter/_core/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../_core/utils/validator_util.dart';
import '../../../data/dtos/auth_dto.dart';
import '../../../provider/auth/session_provider.dart'; // ✅ SessionProvider import
import '../../../provider/auth_provider.dart';
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
  String email = "test@test.com";
  String password = "123456";
  // ==================== 시연용 미리 입력된 계정 끝 ====================

  // 기존 코드 (주석 보관): String email = ""; String password = "";
  String emailError = "";
  String passwordError = "";
  // ✅ 1. [수정] 로그인 버튼 클릭 시 실행되는 함수
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
      // authProvider의 login 함수를 호출합니다.
      await ref.read(authProvider.notifier).login(
            LoginRequest(email: email, password: password),
          );

      print(
          "[LoginScreen] authProvider.login() 호출 성공. 화면 이동은 Session 상태 변경에 따라 자동으로 처리됩니다.");
      // 화면 이동은 아래 build 메소드의 ref.listen에서 처리하므로 여기서 직접 호출할 필요가 없습니다.
    } catch (e) {
      // ✅ 2. [수정] 에러 발생 시 로그를 남기고, 사용자에게 스낵바로 피드백을 줍니다.
      print("[LoginScreen] !!!!! 로그인 과정에서 에러 발생 !!!!!: $e");
      if (mounted) {
        // 위젯이 여전히 화면에 있는지 확인
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
    // ✅ 3. [수정] AuthProvider의 '진행 상태'와 SessionProvider의 '로그인 여부'를 모두 감시합니다.
    final authState = ref.watch(authProvider);

    // ✅ 4. [신설] ref.listen을 사용하여 로그인 상태 변화를 감지하고, 화면을 '단 한 번만' 이동시킵니다.
    // build 메소드 안에서 화면을 이동시키는 것보다 훨씬 안전하고 권장되는 방식입니다.
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

              // ✅ 5. [수정] isProgress 상태에 따라 버튼의 텍스트와 동작을 제어합니다.
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
                child: const Text("아직 회원이 아니신가요? 회원가입"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
