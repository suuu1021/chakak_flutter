import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../_core/constants/app_strings.dart';

final bottomNavIndexProvider = StateProvider<int>((ref) => 0);

class CustomBottomNavigationBar extends ConsumerWidget {
  const CustomBottomNavigationBar({super.key});

  static const List<BottomNavigationBarItem> _navItems = [
    BottomNavigationBarItem(
      icon: Icon(Icons.home),
      label: AppStrings.home,
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.search),
      label: AppStrings.search,
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.chat_bubble_outline_rounded),
      label: AppStrings.community,
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.person),
      label: AppStrings.profile,
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(bottomNavIndexProvider);

    return BottomNavigationBar(
      items: _navItems,
      currentIndex: currentIndex,
      onTap: (index) {
        ref.read(bottomNavIndexProvider.notifier).state = index;
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.grey[600],
      showSelectedLabels: true,
      showUnselectedLabels: false,
    );
  }
}
