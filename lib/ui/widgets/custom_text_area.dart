import 'package:flutter/material.dart';

class CustomTextArea extends StatefulWidget {
  final String? initValue;
  final String hint;
  final TextEditingController controller;
  final String? Function(String?)? validator;

  const CustomTextArea({
    Key? key,
    this.initValue,
    required this.hint,
    required this.controller,
    this.validator,
  }) : super(key: key);

  @override
  State<CustomTextArea> createState() => _CustomTextAreaState();
}

class _CustomTextAreaState extends State<CustomTextArea> {
  @override
  void initState() {
    super.initState();
    if (widget.initValue != null && widget.initValue!.isNotEmpty) {
      widget.controller.text = widget.initValue!;
    }
  }

  @override
  void dispose() {
    widget.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: TextFormField(
        validator: widget.validator,
        controller: widget.controller,
        maxLines: 15,
        decoration: InputDecoration(
          hintText: "Enter ${widget.hint}",
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
      ),
    );
  }
}
