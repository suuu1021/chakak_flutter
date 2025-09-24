// lib/ui/pages/review/review_manager_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // 추가
import 'my_review_screen.dart';
import 'photographer_review_screen.dart';
import '../../../_core/constants/user_type.dart';
import '../../../provider/global/photographer_profile/photographer_profile_notifier.dart'; // 추가

// StatelessWidget에서 ConsumerWidget으로 변경
class ReviewManagerScreen extends ConsumerWidget {
  final UserType userType;

  const ReviewManagerScreen({super.key, required this.userType});

  @override
  Widget build(BuildContext context, WidgetRef ref) { // WidgetRef ref 추가
    if (userType == UserType.photographer) {
      // 포토그래퍼 프로필 상태를 watch
      final profileState = ref.watch(photographerProfileProvider);

      if (profileState.isLoading) {
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      }

      if (profileState.errorMessage != null) {
        return Scaffold(
          appBar: AppBar(title: const Text("오류")),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "프로필 정보를 불러오는 중 오류가 발생했습니다: ${profileState.errorMessage}",
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      }

      if (profileState.profile == null || profileState.profile!.id.isEmpty) {
        return Scaffold(
          appBar: AppBar(title: const Text("오류")),
          body: const Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "사진작가 프로필 정보를 찾을 수 없습니다. 프로필을 먼저 등록하거나 다시 로그인해주세요.",
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      }

      final photographerIdInt = int.tryParse(profileState.profile!.id);
      if (photographerIdInt == null) {
        return Scaffold(
          appBar: AppBar(title: const Text("오류")),
          body: const Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "사진작가 ID 형식이 올바르지 않습니다.",
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      }
      // photographerId를 전달
      return PhotographerReviewScreen(photographerId: photographerIdInt);
    } else {
      return const MyReviewScreen();
    }
  }
}
