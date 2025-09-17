// import 'package:chakak_flutter/ui/pages/profile/user/widgets/profile_menu_list.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// import '../../../../../_core/constants/app_sizes.dart';
// import '../../../../provider/auth/session_provider.dart';
// import '../../../../provider/global/photographer_profile/photographer_profile_notifier.dart';
// import '../../../../provider/global/user_profile/user_profile_provider.dart';
// import 'widgets/profile_header.dart';

// class MyProfilePage extends ConsumerStatefulWidget {
//   const MyProfilePage({super.key});

//   @override
//   ConsumerState<MyProfilePage> createState() => _MyProfilePageState();
// }

// class _MyProfilePageState extends ConsumerState<MyProfilePage> {
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final session = ref.read(sessionProvider);
//       print('[DEBUG] 세션 정보:');
//       print('[DEBUG] isLogin: ${session.isLogin}');
//       print('[DEBUG] userTypeCode: ${session.userTypeCode}');

//       if (session.isLogin) {
//         if (session.userTypeCode == 'photographer') {
//           print('[DEBUG] 포토그래퍼로 인식됨');
//           ref.read(photographerProfileProvider.notifier).loadMyProfile();
//         } else {
//           print('[DEBUG] 일반 사용자로 인식됨');
//           ref.read(userProfileProvider.notifier).loadMyProfile();
//         }
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final session = ref.watch(sessionProvider);

//     return Scaffold(
//       body: RefreshIndicator(
//         onRefresh: () {
//           if (session.isLogin) {
//             if (session.userTypeCode == 'photographer') {
//               return ref
//                   .read(photographerProfileProvider.notifier)
//                   .loadMyProfile();
//             } else {
//               return ref.read(userProfileProvider.notifier).refresh();
//             }
//           } else {
//             return Future.value();
//           }
//         },
//         child: SingleChildScrollView(
//           physics: const AlwaysScrollableScrollPhysics(),
//           padding: const EdgeInsets.all(AppSizes.spacing16),
//           child: Column(
//             children: [
//               ProfileHeader(session: session),
//               const SizedBox(height: AppSizes.spacing24),
//               ProfileMenuList(session: session),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:chakak_flutter/ui/pages/profile/user/widgets/profile_menu_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../_core/constants/app_sizes.dart';
import '../../../../_core/constants/app_colors.dart';
import '../../../../provider/auth/session_provider.dart';
import '../../../../provider/global/photographer_profile/photographer_profile_notifier.dart';
import '../../../../provider/global/user_profile/user_profile_provider.dart';
import 'widgets/profile_header.dart';

class MyProfilePage extends ConsumerStatefulWidget {
  const MyProfilePage({super.key});

  @override
  ConsumerState<MyProfilePage> createState() => _MyProfilePageState();
}

class _MyProfilePageState extends ConsumerState<MyProfilePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      /* ============= 원래 코드 (주석 처리) =============
      final session = ref.read(sessionProvider);
      print('[DEBUG] 세션 정보:');
      print('[DEBUG] isLogin: ${session.isLogin}');
      print('[DEBUG] userTypeCode: ${session.userTypeCode}');

      if (session.isLogin) {
        if (session.userTypeCode == 'photographer') {
          print('[DEBUG] 포토그래퍼로 인식됨');
          ref.read(photographerProfileProvider.notifier).loadMyProfile();
        } else {
          print('[DEBUG] 일반 사용자로 인식됨');
          ref.read(userProfileProvider.notifier).loadMyProfile();
        }
      }
      */
      // ============= 더미 처리 =============
      print('[DEBUG] 더미 모드 - API 호출 생략');
    });
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () {
          /* ============= 원래 코드 (주석 처리) =============
          if (session.isLogin) {
            if (session.userTypeCode == 'photographer') {
              return ref
                  .read(photographerProfileProvider.notifier)
                  .loadMyProfile();
            } else {
              return ref.read(userProfileProvider.notifier).refresh();
            }
          } else {
            return Future.value();
          }
          */
          // ============= 더미 새로고침 =============
          return Future.delayed(const Duration(milliseconds: 500));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppSizes.spacing16),
          child: Column(
            children: [
              // ============= 더미 ProfileHeader =============
              _buildDummyProfileHeader(),
              const SizedBox(height: AppSizes.spacing24),
              ProfileMenuList(session: session),
            ],
          ),
        ),
      ),
    );
  }

  // ============= 더미 프로필 헤더 =============
  Widget _buildDummyProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.spacing16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 프로필 이미지
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(40),
              border: Border.all(
                  color: AppColors.border, width: 2), // 일반 유저는 회색 테두리
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(38),
              child: Image.network(
                'https://images.pexels.com/photos/574071/pexels-photo-574071.jpeg?w=300&h=300&fit=crop',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.person, // 일반 유저는 person 아이콘
                      size: 40,
                      color: AppColors.gray500);
                },
              ),
            ),
          ),
          const SizedBox(width: AppSizes.spacing16),
          // 사용자 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // PRO 배지 제거, 이름만 표시
                const Text(
                  '위찰칵',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSizes.spacing4),
                const Text(
                  'test@test.com',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSizes.spacing4),

                const SizedBox(height: AppSizes.spacing8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.1), // 파란색 배경
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    '일반 회원', // 배지 텍스트 변경
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.secondary, // 파란색 텍스트
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 편집 버튼
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('프로필 편집 화면으로 이동')),
              );
            },
            icon: const Icon(Icons.edit),
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }
}
