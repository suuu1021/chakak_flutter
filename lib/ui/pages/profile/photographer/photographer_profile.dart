import 'package:flutter/material.dart';

class PhotographerProfile extends StatefulWidget {
  const PhotographerProfile({super.key});

  @override
  State<PhotographerProfile> createState() => _PhotographerProfileState();
}

class _PhotographerProfileState extends State<PhotographerProfile> {
  int _currentIndex = 0;

  // 탭별 화면
  final List<Widget> _pages = [];

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
