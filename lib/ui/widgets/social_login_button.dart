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
      height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
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
