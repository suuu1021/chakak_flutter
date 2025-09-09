import 'dart:async';
import 'package:flutter/material.dart';

import '../../widgets/custom_logo.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // 2초 뒤 로그인 화면으로 이동
    Timer(const Duration(seconds: 2), () {
      Navigator.pushReplacementNamed(context, '/onboarding');
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomLogo("CHAKAK"),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
