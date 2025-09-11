import 'package:flutter/material.dart';



///오류 발생 알릴때 사용
///ex ---> "네트워크 연결 실패 했습니다"
class ErrorDialog extends StatelessWidget {
  final String title;
  final String content;
  final String buttonText;

  const ErrorDialog({
    Key? key,
    required this.title,
    required this.content,
    this.buttonText = '확인',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: <Widget>[
        TextButton(
          child: Text(buttonText),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}

// Helper function to show the error dialog
Future<void> showErrorDialog({
  required BuildContext context,
  required String title,
  required String content,
  String buttonText = '확인',
}) {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return ErrorDialog(
        title: title,
        content: content,
        buttonText: buttonText,
      );
    },
  );
}
