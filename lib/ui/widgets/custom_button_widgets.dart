import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../pages/home/home_screen.dart';

class CustomButtonWidgets {
  static SizedBox button(BuildContext context, String title,
      {Function? onPressed, Color? backgroundColor, Color? textColor}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          print("$title");
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: backgroundColor ?? Colors.black,
          foregroundColor: Colors.white,
        ),
        child: Text(
          "$title",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
