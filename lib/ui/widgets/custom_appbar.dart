// Custom AppBar
import 'package:flutter/material.dart';

import '../../_core/constants/app_strings.dart';

class CustomAppbar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppbar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 0,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            AppStrings.appNameUpper,
            style: TextStyle(fontSize: 24, fontFamily: AppStrings.fontFamily1),
          ),
          Row(
            children: [
              IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => print("검색 클릭")),
              IconButton(
                  icon: const Icon(Icons.notifications),
                  onPressed: () {
                    Navigator.pushNamed(context, '/notification'); // ✅ 알림 화면 이동
                  },
              ),
              IconButton(
                  icon: const Icon(Icons.calendar_month),
                  onPressed: () => print("일정 클릭")),
              IconButton(
                icon: const Icon(Icons.support_agent),
                onPressed: () {
                  Navigator.pushNamed(context, '/help-center');
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
