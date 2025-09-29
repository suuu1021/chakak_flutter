import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../provider/photographer_profile/photographer_profile_notifier.dart';
import 'my_review_screen.dart';
import 'photographer_review_screen.dart';
import '../../../_core/constants/user_type.dart';

class ReviewManagerScreen extends ConsumerWidget {
  final UserType userType;

  const ReviewManagerScreen({super.key, required this.userType});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (userType == UserType.photographer) {
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
