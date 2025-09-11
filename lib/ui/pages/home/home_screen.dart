import 'package:chakak_flutter/ui/pages/home/home_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/custom_bottom_navigation_bar.dart';
import '../profile/photographer/photographer_profile_page.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const List<Widget> _pages = [
    HomeContent(),
    Center(child: Text("검색 화면", style: TextStyle(fontSize: 24))),
    Center(child: Text("예약 화면", style: TextStyle(fontSize: 24))),
    PhotographerProfilePage(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int currentIndex = ref.watch(bottomNavIndexProvider);
    return Scaffold(
      appBar: CustomAppbar(),
      body: _pages[currentIndex],
      bottomNavigationBar: const CustomBottomNavigationBar(),
    );
  }
}
