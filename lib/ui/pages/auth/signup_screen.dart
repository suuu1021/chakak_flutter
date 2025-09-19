import 'dart:convert';

import 'package:chakak_flutter/_core/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../../_core/utils/validator_util.dart';
import '../../../data/dtos/auth_dto.dart';
import '../../../provider/auth/signup_provider.dart';
import '../../widgets/custom_auth_text_form_field.dart';
import '../../widgets/custom_logo.dart';
import 'profile_setup_screen.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  String email = "";
  String emailError = "";
  String code = "";
  String codeError = "";
  String password = "";
  String passwordError = "";
  String confirmPassword = "";
  String confirmPasswordError = "";
  String userType = "user"; // 기본값을 "user"로 설정
  String userTypeError = "";

  bool _isSendingVerificationEmail = false;
  bool _isVerifyingCode = false;
  bool _isVerificationEmailSent = false;
  bool _isCodeVerified = false;

  final _formKey = GlobalKey<FormState>(); // 폼 키 추가

  void _clearSubmitRelatedErrors() {
    setState(() {
      passwordError = "";
      confirmPasswordError = "";
      userTypeError = "";
    });
  }

  void _resetSignupFormFields() {
    setState(() {
      _formKey.currentState?.reset();
      email = "";
      code = "";
      password = "";
      confirmPassword = "";
      userType = "user";
      _isVerificationEmailSent = false;
      _isCodeVerified = false;
      _isSendingVerificationEmail = false;
      _isVerifyingCode = false;
      emailError = "";
      codeError = "";
      _clearSubmitRelatedErrors();
    });
  }

  String _getApiUserTypeCode(String uiUserType) {
    if (uiUserType.toLowerCase() == "photographer") {
      return "photographer";
    }
    return "user";
  }

  // "인증요청" 버튼 로직: 이메일 발송 API 호출
  Future<void> _sendVerificationEmail() async {
    if (_isSendingVerificationEmail || _isVerifyingCode) return;

    // API 명세에 따라, 인증 코드 발송 후 버튼을 비활성화하고
    // 중복 요청을 막는 로직이 여기에 추가되어야 합니다.
    // (예: 타이머를 사용하여 일정 시간 동안 '재전송' 버튼 비활성화)
    // 현재는 이 부분은 수정하지 않고 _verifyCode만 수정합니다.

    if (_isVerificationEmailSent || _isCodeVerified) {
      setState(() {
        _isVerificationEmailSent = false;
        _isCodeVerified = false;
        code = "";
        codeError = "";
      });
    }

    final trimmedEmail = email.trim();
    final emailValidationResult = validateEmail(trimmedEmail);

    if (trimmedEmail.isEmpty) {
      setState(() => emailError = "이메일을 입력해주세요.");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("이메일을 입력하세요")),
      );
      return;
    }
    if (emailValidationResult.isNotEmpty) {
      setState(() => emailError = "올바른 이메일 값을 입력하세요.");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("올바른 이메일 값을 입력하세요")),
      );
      return;
    }
    setState(() => emailError = "");

    setState(() => _isSendingVerificationEmail = true);

    try {
      final response = await http.post(
        Uri.parse("http://10.0.2.2:8080/api/email/send"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": trimmedEmail}),
      );

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // 성공 시 서버 메시지 사용
        String message = responseBody['message'] ?? "인증 코드가 이메일로 전송되었습니다.";
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
        setState(() => _isVerificationEmailSent = true);
      } else {
        String errorMessage = responseBody['message'] ?? '알 수 없는 오류가 발생했습니다.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("메일 발송 실패: $errorMessage")),
        );
        setState(() => _isVerificationEmailSent = false);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("네트워크 오류 또는 응답 처리 오류: $e")),
      );
      setState(() => _isVerificationEmailSent = false);
    } finally {
      setState(() => _isSendingVerificationEmail = false);
    }
  }

  // "코드 확인" 버튼 로직: 코드 검증 API 호출 (서버 실제 응답에 임시 대응)
  Future<void> _verifyCode() async {
    print("[DEBUG] _verifyCode: Function called.");

    if (_isSendingVerificationEmail || _isVerifyingCode) {
      print(
          "[DEBUG] _verifyCode: Already sending email or verifying code. Returning.");
      return;
    }

    if (!_isVerificationEmailSent) {
      print("[DEBUG] _verifyCode: Verification email not sent yet.");
      setState(() => codeError = "먼저 이메일 인증을 요청해주세요.");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("먼저 이메일 인증을 요청해주세요.")),
      );
      return;
    }

    final trimmedEmail = email.trim();
    final trimmedCode = code.trim();

    print("[DEBUG] _verifyCode: Trimmed Email for API call: '$trimmedEmail'");
    print("[DEBUG] _verifyCode: Trimmed Code for API call: '$trimmedCode'");

    if (trimmedEmail.isEmpty || trimmedCode.isEmpty) {
      print("[DEBUG] _verifyCode: Trimmed email or code is empty.");
      setState(() => codeError = "이메일과 인증코드를 입력하세요");
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("이메일과 인증코드를 입력하세요")));
      return;
    }
    setState(() => codeError = "");

    setState(() => _isVerifyingCode = true);
    print(
        "[DEBUG] _verifyCode: _isVerifyingCode set to true. Making API call...");

    try {
      final response = await http.post(
        Uri.parse("http://10.0.2.2:8080/api/email/verify"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": trimmedEmail, "code": trimmedCode}),
      );

      print(
          "[DEBUG] _verifyCode: API Response Status Code: ${response.statusCode}");
      print("[DEBUG] _verifyCode: Raw response body: ${response.body}");

      final responseBody = jsonDecode(response.body);
      print("[DEBUG] _verifyCode: Parsed responseBody: $responseBody");

      if (response.statusCode == 200) {
        // 서버 실제 응답 필드('body')에 맞춰 성공 여부 판단 (임시 수정)
        bool isSuccess = responseBody['body'] == true;
        print(
            "[DEBUG] _verifyCode: Calculated isSuccess: $isSuccess (based on responseBody['body'] == true)");

        // 서버 실제 응답 필드('msg')에 맞춰 메시지 파싱 (임시 수정)
        String displayMessage =
            responseBody['msg'] ?? (isSuccess ? "이메일 인증 성공!" : "알 수 없는 응답입니다.");

        if (isSuccess) {
          print(
              "[DEBUG] _verifyCode: Verification SUCCESS. Display message: '$displayMessage'");
          setState(() => _isCodeVerified = true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(displayMessage)),
          );
        } else {
          // statusCode 200이지만 body가 true가 아닌 경우
          print(
              "[DEBUG] _verifyCode: Verification FAILED (status 200 but body is not true). Display message: '$displayMessage'");
          setState(() => _isCodeVerified = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(displayMessage)),
          );
        }
      } else if (response.statusCode == 400) {
        // 서버 실제 응답 필드('msg')에 맞춰 메시지 파싱 (임시 수정)
        String errorMessage = responseBody['msg'] ?? "인증에 실패했습니다. (서버 메시지 없음)";
        print(
            "[DEBUG] _verifyCode: Received HTTP 400. Error message from server: '$errorMessage'");
        setState(() => _isCodeVerified = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      } else {
        // 기타 HTTP 오류 코드 처리 (일관성을 위해 'msg'로 임시 수정)
        String errorMessage = responseBody['msg'] ??
            "서버 오류 (${response.statusCode}). 응답을 확인해주세요.";
        print(
            "[DEBUG] _verifyCode: Received HTTP ${response.statusCode}. Error message: '$errorMessage'");
        setState(() => _isCodeVerified = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } catch (e) {
      print("[DEBUG] _verifyCode: Exception caught: $e");
      setState(() => _isCodeVerified = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("네트워크 오류 또는 응답 처리 오류: $e")),
      );
    } finally {
      setState(() => _isVerifyingCode = false);
      print(
          "[DEBUG] _verifyCode: _isVerifyingCode set to false. Function finished.");
    }
  }

  bool _validateSignupFormForNextButton() {
    bool isValid = true;
    String tempPasswordError = "";
    String tempConfirmPasswordError = "";
    String tempUserTypeError = "";

    if (password.isEmpty) {
      tempPasswordError = "비밀번호를 입력해주세요.";
      isValid = false;
    } else if (password.length < 6 || password.length > 20) {
      tempPasswordError = "비밀번호는 6자 이상 20자 이하로 입력해주세요.";
      isValid = false;
    }

    if (confirmPassword.isEmpty) {
      tempConfirmPasswordError = "비밀번호 확인을 입력해주세요.";
      isValid = false;
    } else if (password != confirmPassword) {
      tempConfirmPasswordError = "비밀번호가 일치하지 않습니다.";
      isValid = false;
    }

    if (userType.isEmpty) {
      tempUserTypeError = "회원 유형을 선택해주세요.";
      isValid = false;
    }

    setState(() {
      passwordError = tempPasswordError;
      confirmPasswordError = tempConfirmPasswordError;
      userTypeError = tempUserTypeError;
    });

    return isValid;
  }

  void _submitSignupViaProvider() {
    _clearSubmitRelatedErrors();

    // 최종 API 명세에 따라, 이메일 인증이 완료되어야 회원가입 진행
    if (!_isCodeVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("이메일 인증코드를 확인해주세요.")),
      );
      return;
    }

    if (_validateSignupFormForNextButton()) {
      String apiUserTypeCode = _getApiUserTypeCode(userType);
      final request = RegisterRequest(
        email: email.trim(),
        password: password,
        userTypeCode: apiUserTypeCode,
      );
      // 회원가입 API 호출 (signupProvider 사용)
      ref.read(signupProvider.notifier).registerUser(request);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<SignupState>(signupProvider, (previous, next) {
      if (next.status == SignupStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage ?? "회원가입 처리 중 오류 발생")),
        );
      } else if (next.status == SignupStatus.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("회원가입 요청 성공! 프로필을 설정해주세요.")),
        );
        _resetSignupFormFields();
        // 최종 API 명세: 회원가입 성공 후 로그인 페이지로 안내 (또는 프로필 설정)
        // 현재는 ProfileSetupScreen으로 이동하는데, 서버 응답에 따라 분기 필요할 수 있음
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (_) =>
                  ProfileSetupScreen(userType: userType.toLowerCase())),
        );
      }
    });

    final signupProviderState = ref.watch(signupProvider);
    final isSignupSubmitLoading =
        signupProviderState.status == SignupStatus.loading;
    final bool isAnyAuthOperationInProgress =
        _isSendingVerificationEmail || _isVerifyingCode;

    return Scaffold(
      appBar: AppBar(
        title: const Text("회원가입"),
        centerTitle: true,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const CustomLogo(AppStrings.appNameUpper),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: CustomAuthTextFormField(
                        title: "이메일",
                        initialValue: email,
                        errorText: emailError,
                        onChanged: (v) {
                          setState(() {
                            email = v;
                            if (_isVerificationEmailSent)
                              _isVerificationEmailSent = false;
                            if (_isCodeVerified) _isCodeVerified = false;
                            if (emailError.isNotEmpty &&
                                validateEmail(v.trim()).isEmpty) {
                              emailError = "";
                            }
                          });
                        }),
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(top: 24.0),
                    child: ElevatedButton(
                      onPressed: isAnyAuthOperationInProgress
                          ? null
                          : _sendVerificationEmail,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 16),
                        disabledBackgroundColor: Colors.black.withOpacity(0.7),
                        disabledForegroundColor: Colors.white.withOpacity(0.7),
                      ),
                      child: _isSendingVerificationEmail
                          ? const Text("전송중...",
                              style: TextStyle(color: Colors.white))
                          : _isVerificationEmailSent
                              ? const Text("재전송",
                                  style: TextStyle(color: Colors.white))
                              : const Text("인증요청",
                                  style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: CustomAuthTextFormField(
                        title: "인증코드",
                        initialValue: code,
                        errorText: codeError,
                        onChanged: (v) {
                          setState(() {
                            code = v;
                            if (codeError.isNotEmpty && v.isNotEmpty)
                              codeError = "";
                          });
                        }),
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(top: 24.0),
                    child: ElevatedButton(
                      onPressed: isAnyAuthOperationInProgress || _isCodeVerified
                          ? null
                          : _verifyCode,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 16),
                        disabledBackgroundColor: Colors.black.withOpacity(0.7),
                        disabledForegroundColor: Colors.white.withOpacity(0.7),
                      ),
                      child: _isVerifyingCode
                          ? const Text("확인중...",
                              style: TextStyle(color: Colors.white))
                          : _isCodeVerified
                              ? const Text("인증완료",
                                  style: TextStyle(color: Colors.white))
                              : const Text("코드 확인",
                                  style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              CustomAuthTextFormField(
                  title: "비밀번호",
                  obscureText: true,
                  initialValue: password,
                  errorText: passwordError,
                  onChanged: (v) {
                    setState(() {
                      password = v;
                      if (passwordError.isNotEmpty) passwordError = "";
                    });
                  }),
              const SizedBox(height: 16),
              CustomAuthTextFormField(
                  title: "비밀번호 확인",
                  obscureText: true,
                  initialValue: confirmPassword,
                  errorText: confirmPasswordError,
                  onChanged: (v) {
                    setState(() {
                      confirmPassword = v;
                      if (confirmPasswordError.isNotEmpty)
                        confirmPasswordError = "";
                    });
                  }),
              const SizedBox(height: 24),
              if (userTypeError.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(userTypeError,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontSize: 12)),
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Radio<String>(
                    value: "user",
                    groupValue: userType,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          userType = value;
                          if (userTypeError.isNotEmpty) userTypeError = "";
                        });
                      }
                    },
                  ),
                  const Text("개인 회원"),
                  const SizedBox(width: 20),
                  Radio<String>(
                    value: "photographer",
                    groupValue: userType,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          userType = value;
                          if (userTypeError.isNotEmpty) userTypeError = "";
                        });
                      }
                    },
                  ),
                  const Text("포토그래퍼 회원"),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: isAnyAuthOperationInProgress || isSignupSubmitLoading
                    ? null
                    : _submitSignupViaProvider,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  minimumSize: const Size(double.infinity, 50),
                  disabledBackgroundColor: Colors.black.withOpacity(0.7),
                  disabledForegroundColor: Colors.white.withOpacity(0.7),
                ),
                child: isSignupSubmitLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("다음",
                        style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: isAnyAuthOperationInProgress || isSignupSubmitLoading
                    ? null
                    : () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  disabledForegroundColor: Colors.grey.withOpacity(0.7),
                ),
                child: const Text("로그인으로 돌아가기"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
