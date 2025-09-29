import 'package:flutter/material.dart';

import '../../../../_core/constants/app_colors.dart';

class CustomSearchField extends StatefulWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String hintText;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final VoidCallback? onSearchPressed;
  final bool showSearchButton;
  final EdgeInsets? margin;
  final EdgeInsets? contentPadding;

  const CustomSearchField({
    super.key,
    this.controller,
    this.focusNode,
    this.hintText = '검색어를 입력하세요',
    this.onChanged,
    this.onSubmitted,
    this.onSearchPressed,
    this.showSearchButton = true,
    this.margin,
    this.contentPadding,
  });

  @override
  State<CustomSearchField> createState() => _CustomSearchFieldState();
}

class _CustomSearchFieldState extends State<CustomSearchField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _focusNode = widget.focusNode ?? FocusNode();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _handleSearchSubmit() {
    final text = _controller.text;
    if (widget.onSubmitted != null) {
      widget.onSubmitted!(text);
    }
    if (widget.onSearchPressed != null) {
      widget.onSearchPressed!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: widget.margin ?? const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              enableInteractiveSelection: true,
              onChanged: widget.onChanged,
              onSubmitted:
                  widget.onSubmitted ?? (value) => _handleSearchSubmit(),
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: TextStyle(color: Colors.grey[600]),
                prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                border: InputBorder.none,
                contentPadding: widget.contentPadding ??
                    const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
              ),
            ),
          ),

          // 검색 버튼 (옵션)
          if (widget.showSearchButton)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: ElevatedButton(
                onPressed: _handleSearchSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  '검색',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
