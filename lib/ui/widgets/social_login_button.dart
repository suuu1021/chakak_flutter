import 'package:flutter/material.dart';

enum SocialLoginType { kakao, naver }

class SocialLoginButton extends StatelessWidget {
  final SocialLoginType type;
  final VoidCallback onPressed;

  const SocialLoginButton({
    super.key,
    required this.type,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    // 플랫폼별 아이콘 이미지
    String assetIcon;

    switch (type) {
      case SocialLoginType.kakao:
        assetIcon = "assets/images/kakao.png";
        break;
      case SocialLoginType.naver:
        assetIcon = "assets/images/naver.png";
        break;
    }

    return SizedBox(
      width: double.infinity,
      height: 56, // 버튼 높이 조금 키움
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white, // 배경 흰색
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16), // 모서리 둥글게
          ),
          elevation: 0,
        ),
        onPressed: onPressed,
        child: Image.asset(
          assetIcon,
          width: double.infinity, //
          height: 300,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
