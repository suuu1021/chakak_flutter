import 'package:flutter/material.dart';

class CustomAuthButtonWidgets {
  static SizedBox button(
      BuildContext context,
      String title, {
        VoidCallback? onPressed,
        Color? backgroundColor,
        Color? textColor,
      }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed, // ✅ 외부에서 전달된 함수 실행
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: backgroundColor ?? Colors.black,
          foregroundColor: textColor ?? Colors.white,
        ),
        child: Text(
          title,
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
