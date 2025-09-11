import 'package:flutter/material.dart';



/// 확인받을때 쓰는 다이얼로그
/// ex---> "정말 삭제 하시겠습니까 ?"
/// 확인버튼 = true
class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String content;
  final VoidCallback onConfirm;
  final String confirmText;
  final String cancelText;

  const ConfirmationDialog({
    Key? key,
    required this.title,
    required this.content,
    required this.onConfirm,
    this.confirmText = '확인',
    this.cancelText = '취소',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: <Widget>[
        TextButton(
          child: Text(cancelText),
          onPressed: () {
            Navigator.of(context).pop(false);
          },
        ),
        TextButton(
          child: Text(confirmText),
          onPressed: () {
            onConfirm();
            Navigator.of(context).pop(true); //
          },
        ),
      ],
    );
  }
}

// Helper function to show the dialog
Future<bool?> showConfirmationDialog({
  required BuildContext context,
  required String title,
  required String content,
  String confirmText = '확인',
  String cancelText = '취소',
}) {
  return showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return ConfirmationDialog(
        title: title,
        content: content,
        confirmText: confirmText,
        cancelText: cancelText,
        onConfirm: () {

        },
      );
    },
  );
}
