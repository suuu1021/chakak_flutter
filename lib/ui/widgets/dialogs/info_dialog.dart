import 'package:flutter/material.dart';
///정보를 전달 하는 다이얼 로그
///ex---> "회원 가입이 완료 되었습니다"
///
class InfoDialog extends StatelessWidget {
  final String title;
  final String content;
  final String buttonText;

  const InfoDialog({
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

//
Future<void> showInfoDialog({
  required BuildContext context,
  required String title,
  required String content,
  String buttonText = '확인',
}) {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return InfoDialog(
        title: title,
        content: content,
        buttonText: buttonText,
      );
    },
  );
}
