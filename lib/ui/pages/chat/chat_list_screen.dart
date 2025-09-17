import 'package:chakak_flutter/_core/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../_core/constants/app_text_styles.dart';
import '../../../data/dtos/chat_room_list_item_dto.dart';
import 'chat_screen.dart';

class ChatListScreen extends ConsumerStatefulWidget {
  const ChatListScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends ConsumerState<ChatListScreen> {
  // initState와 서버에서 데이터를 로드하는 로직을 제거했습니다.

  void _navigateToChat(ChatRoomListItemDto chatRoom) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          chatRoomId: chatRoom.chatRoomId,
          opponentNickname: chatRoom.opponentNickname, // 닉네임 전달 추가
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
    // 실제 앱처럼 보이기 위한 더미 데이터를 생성합니다.
    final now = DateTime.now();
    final List<ChatRoomListItemDto> dummyChatRooms = [
      ChatRoomListItemDto(
        chatRoomId: 1,
        opponentNickname: '김작가 스냅',
        lastMessage: '알겠습니다. 프리미엄 B 패키지로 예약 진행 도와드리겠습니다. 계약서 작성을 위해 성함과 연락처를 알려주시겠어요?',
        lastMessageCreatedAt:
            now.subtract(const Duration(minutes: 5)).toIso8601String(),
        unreadMessageCount: 2,
      ),
      ChatRoomListItemDto(
        chatRoomId: 2,
        opponentNickname: '디자이너 김민지',
        lastMessage: '네, 확인했습니다. 시안 보내드릴게요.',
        lastMessageCreatedAt:
            now.subtract(const Duration(days: 1, hours: 2)).toIso8601String(),
        unreadMessageCount: 0,
      ),
      ChatRoomListItemDto(
        chatRoomId: 3,
        opponentNickname: 'PM 이서준',
        lastMessage: '회의록 확인 부탁드립니다. 금일 중으로 피드백 주세요.',
        lastMessageCreatedAt: now.subtract(const Duration(days: 3)).toIso8601String(),
        unreadMessageCount: 1,
      ),
      ChatRoomListItemDto(
        chatRoomId: 4,
        opponentNickname: '디자이너 곽충근',
        lastMessage: '다음 주 스터디 주제는 Riverpod 심화 과정입니다.',
        lastMessageCreatedAt: now.subtract(const Duration(days: 8)).toIso8601String(),
        unreadMessageCount: 0,
      ),
      ChatRoomListItemDto(
        chatRoomId: 5,
        opponentNickname: '고양이 집사',
        lastMessage: '감사합니다! 다음에 또 거래해요 :)',
        lastMessageCreatedAt:
            now.subtract(const Duration(days: 30)).toIso8601String(),
        unreadMessageCount: 0,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(AppStrings.chat, style: AppTextStyles.h4),
      ),
      // 로딩이나 에러 상태 없이, 더미 데이터로 리스트를 바로 표시합니다.
      body: ListView.separated(
        itemCount: dummyChatRooms.length,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          color: Colors.grey[300],
          indent: 72,
        ),
        itemBuilder: (context, index) {
          final chatRoom = dummyChatRooms[index];
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
            // 프로필 이미지
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
                  // 이름과 시간
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
                      // 읽지 않은 메시지 개수
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
