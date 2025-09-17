
import 'package:chakak_flutter/provider/chat/chat_room_provider.dart';
import 'package:chakak_flutter/ui/pages/chat/chat_list_screen.dart';
import 'package:chakak_flutter/ui/pages/chat/chat_screen.dart';
import 'package:chakak_flutter/ui/pages/home/widgets/banner_widget.dart';
import 'package:chakak_flutter/ui/pages/home/widgets/photo_service_category_widget.dart';
import 'package:chakak_flutter/ui/pages/home/widgets/photographer_card_list.dart';
import 'package:chakak_flutter/ui/pages/home/widgets/service_card_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/banner.dart';
import '../../../data/models/photo_service/photo_service.dart';
import '../../../data/models/photo_service_category.dart';
import '../../../data/models/photographer.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/custom_bottom_navigation_bar.dart';
import '../photo_service/category_service_list_page.dart';
import '../photo_service/photo_service_detail_page.dart';
import '../profile/user/my_profile_page.dart';
import '../profile/photographer/photographer_profile_page.dart';
import '../search/search_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const List<Widget> _pages = [
    HomeContent(),
    SearchScreen(),
    Center(child: Text("커뮤니티 화면", style: TextStyle(fontSize: 24))),
    ChatListScreen(),
    MyProfilePage(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int currentIndex = ref.watch(bottomNavIndexProvider);
    return Scaffold(
      appBar: CustomAppbar(),
      body: IndexedStack(
        index: currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(),
    );
  }
}

class HomeContent extends ConsumerStatefulWidget {
  const HomeContent({super.key});

  @override
  ConsumerState<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends ConsumerState<HomeContent>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  void _onCategoryTap(BuildContext context, PhotoServiceCategory category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryServiceListPage(category: category),
      ),
    );
  }

  void _onBannerTap(BannerItem banner) {
    print('배너 클릭: ${banner.title}');
  }

  void _onServiceTap(BuildContext context, PhotoService service) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PhotoServiceDetailPage(service: service),
      ),
    );
  }

  void _onPhotographerTap(BuildContext context, Photographer photographer) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PhotographerProfilePage(
          photographerId: photographer.id,
        ),
      ),
    );
  }

  Future<void> _onRefresh() async {
    await Future.wait([
      Future.delayed(Duration(milliseconds: 500)),
    ]);
  }

  // 임시 채팅방 시작 함수
  void _startTempChat(BuildContext context, WidgetRef ref) async {
    try {
      // 사진작가 1번과의 채팅방 생성/조회를 요청합니다.
      final chatRoomResponse = await ref.read(createChatRoomProvider(1).future);

      // 성공적으로 chatRoomId를 받아오면 채팅 화면으로 이동합니다.
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatScreen(
            chatRoomId: chatRoomResponse.chatRoomId,
            opponentNickname: '작가 1', // opponentNickname을 직접 지정
          ),
        ),
      );
    } catch (e) {
      // 에러 처리
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('채팅방 입장에 실패했습니다: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 임시 채팅 시작 버튼 (숨김 처리)
            Opacity(
              opacity: 0.0,
              child: ElevatedButton(
                onPressed: () => _startTempChat(context, ref),
                child: const Text('작가 1과 임시 채팅 시작'),
              ),
            ),
            const SizedBox(height: 16),

            // 배너 영역
            BannerWidget(
              height: 180,
              autoSlideInterval: const Duration(seconds: 3),
              showIndicators: true,
              onBannerTap: _onBannerTap,
              margin: const EdgeInsets.all(16),
            ),

            // 카테고리
            PhotoServiceCategoryWidget(
              height: 120,
              onCategorySelected: (category) =>
                  _onCategoryTap(context, category),
            ),

            const SizedBox(height: 10),
            ServiceCardList(
              onServiceTap: (service) => _onServiceTap(context, service),
            ),
            const SizedBox(height: 24),
            PhotographerCardList(
              onPhotographerTap: (photographer) =>
                  _onPhotographerTap(context, photographer),
            ),
          ],
        ),
      ),
    );
  }
}
