import 'package:chakak_flutter/_core/constants/app_strings.dart';
import 'package:chakak_flutter/provider/chat/chat_list_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../_core/constants/app_colors.dart';
import '../../../_core/constants/app_text_styles.dart';
import '../../../data/dtos/chat_room_list_item_dto.dart';
import '../../../provider/chat/chat_room_provider.dart';
import 'chat_screen.dart';

class ChatListScreen extends ConsumerStatefulWidget {
  const ChatListScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends ConsumerState<ChatListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(chatListProvider.notifier).loadChatRooms();
    });
  }

  void _navigateToChat(ChatRoomListItemDto chatRoom) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          chatRoomId: chatRoom.chatRoomId,
          opponentNickname: chatRoom.opponentNickname,
        ),
      ),
    ).then((_) {
      ref.read(chatListProvider.notifier).refresh();
    });
  }

  Future<void> _onRefresh() async {
    await ref.read(chatListProvider.notifier).refresh();
  }

  String _formatTime(String? dateTimeString) {
    if (dateTimeString == null) return '';

    try {
      final dateTime = DateTime.parse(dateTimeString);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inDays == 0) {
        return DateFormat('HH:mm').format(dateTime);
      } else if (difference.inDays == 1) {
        return '어제';
      } else if (difference.inDays < 7) {
        final weekdays = ['월', '화', '수', '목', '금', '토', '일'];
        return weekdays[dateTime.weekday - 1];
      } else {
        return DateFormat('M월 d일').format(dateTime);
      }
    } catch (e) {
      return '';
    }
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
    final chatListState = ref.watch(chatListProvider);
    final chatRooms = chatListState.chatRooms;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: Stack(
          children: [
            ListView.separated(
              itemCount: chatRooms.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                color: Colors.grey[300],
                indent: 72,
              ),
              itemBuilder: (context, index) {
                final chatRoom = chatRooms[index];
                return _buildChatListItem(chatRoom);
              },
            ),
            if (chatListState.isLoading && chatRooms.isEmpty)
              const Center(child: CircularProgressIndicator()),
            if (chatListState.errorMessage != null && chatRooms.isEmpty)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(chatListState.errorMessage!),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _onRefresh,
                      child: const Text('다시 시도'),
                    ),
                  ],
                ),
              ),
            if (!chatListState.isLoading && chatRooms.isEmpty)
              const Center(
                child: Text('채팅 내역이 없습니다.\n작가에게 먼저 말을 걸어보세요!'),
              ),
          ],
        ),
      ),
      // 임시 채팅 시작 버튼 (활성화)
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(), // 완전한 원형

        backgroundColor: AppColors.primaryLight,
        onPressed: () => _startTempChat(context, ref),
        child: const Icon(
          Icons.add_comment,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildChatListItem(ChatRoomListItemDto chatRoom) {
    return InkWell(
      onTap: () => _navigateToChat(chatRoom),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: Colors.grey[300],
              child: Icon(Icons.person, color: Colors.grey[600], size: 32),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          chatRoom.opponentNickname,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        _formatTime(chatRoom.lastMessageCreatedAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          chatRoom.lastMessage ?? '메시지가 없습니다',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                      if ((chatRoom.unreadMessageCount ?? 0) > 0)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue[600],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          constraints: const BoxConstraints(minWidth: 20),
                          child: Text(
                            chatRoom.unreadMessageCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
