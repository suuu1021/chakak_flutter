import 'package:flutter/material.dart';

// 재사용 가능한 위젯으로 설계하기 위함.
// 맞춤 기능을 추가 하기 위해 재설계 한다.
class CustomTextFormField extends StatefulWidget {
  final String hint;
  final bool obscureText;
  final TextEditingController controller;
  final String? initValue; // 초기 값 (CustomTextFormField - 글 쓰기, 글 수정)
  final String? Function(String?)? validator; // 유효성 검사

  const CustomTextFormField({
    super.key,
    required this.hint,
    this.obscureText = false,
    required this.controller,
    this.initValue,
    this.validator,
  });

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  @override
  void initState() {
    super.initState();
    if (widget.initValue != null && widget.initValue!.isNotEmpty) {
      widget.controller.text = widget.initValue!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      validator: widget.validator,
      controller: widget.controller,
      obscureText: widget.obscureText,
      decoration: InputDecoration(
        hintText: widget.hint, // hintText는 여기서만 사용
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}
