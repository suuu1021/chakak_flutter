import 'package:chakak_flutter/_core/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../_core/constants/app_text_styles.dart';
import '../../../provider/chat/chat_list_provider.dart';
import '../../../data/dtos/chat_room_list_item_dto.dart';
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
        ),
      ),
    );
  }

  String _formatTime(String? dateTimeString) {
    if (dateTimeString == null) return '';

    try {
      final dateTime = DateTime.parse(dateTimeString);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inDays == 0) {
        // 오늘
        return DateFormat('HH:mm').format(dateTime);
      } else if (difference.inDays == 1) {
        // 어제
        return '어제';
      } else if (difference.inDays < 7) {
        // 일주일 이내
        final weekdays = ['월', '화', '수', '목', '금', '토', '일'];
        return weekdays[dateTime.weekday - 1];
      } else {
        // 일주일 이상
        return DateFormat('M월 d일').format(dateTime);
      }
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatListState = ref.watch(chatListProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(AppStrings.chat, style: AppTextStyles.h4),
      ),
      body: _buildBody(chatListState),
    );
  }

  Widget _buildBody(ChatListState chatListState) {
    if (chatListState.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (chatListState.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text('오류가 발생했습니다',
                style: TextStyle(fontSize: 18, color: Colors.grey[700])),
            const SizedBox(height: 8),
            Text(chatListState.errorMessage!,
                style: TextStyle(fontSize: 14, color: Colors.grey[600])),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () =>
                  ref.read(chatListProvider.notifier).loadChatRooms(),
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }

    if (chatListState.chatRooms.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text('아직 대화가 없습니다',
                style: TextStyle(fontSize: 16, color: Colors.grey[600])),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(chatListProvider.notifier).refresh(),
      child: ListView.separated(
        itemCount: chatListState.chatRooms.length,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          color: Colors.grey[300],
          indent: 72,
        ),
        itemBuilder: (context, index) {
          final chatRoom = chatListState.chatRooms[index];
          return _buildChatListItem(chatRoom);
        },
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
            // 프로필 이미지 (온라인 상태 제거)
            CircleAvatar(
              radius: 28,
              backgroundColor: Colors.grey[300],
              child: Icon(Icons.person, color: Colors.grey[600], size: 32),
            ),
            const SizedBox(width: 12),
            // 채팅 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 이름과 시간 (스타일링 제거)
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
                  // 마지막 메시지와 읽지 않은 개수
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
                      // 읽지 않은 메시지 개수만 표시 (백엔드 필드)
                      if (chatRoom.unreadMessageCount > 0)
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
