
import 'package:chakak_flutter/provider/auth/session_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../provider/chat/chat_provider.dart';

import '../../widgets/chat_bubble.dart';
import '../../widgets/chat_text_field.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final int chatRoomId;

  const ChatScreen({super.key, required this.chatRoomId});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final session = ref.read(sessionProvider);

      if (session.isLogin && session.jwtToken != null && session.userId != null) {
        print(
            '채팅방 입장. 유저 ID: ${session.userId}, 유저 타입 코드: ${session.userTypeCode ?? "null (기본값 사용 예정)"}');
        ref
            .read(chatMessagesProvider(widget.chatRoomId).notifier)
            .connectAndListen(
              jwtToken: session.jwtToken!,
              userId: session.userId!,
              userType: session.userTypeCode ?? '',
            );
        _scrollToBottom();
      } else {
        print('채팅방 입장 실패: 필수 로그인 정보 부족 (JWT 또는 ID 누락)');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('로그인 정보가 없어 채팅 서버에 연결할 수 없습니다.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 50), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    ref.read(chatMessagesProvider(widget.chatRoomId).notifier).disconnect();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _textController.text;
    if (text.isNotEmpty) {
      ref
          .read(chatMessagesProvider(widget.chatRoomId).notifier)
          .sendMessage(messageContent: text);
      _textController.clear();
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);
    final currentUserId = session.userId;

    final chatState = ref.watch(chatMessagesProvider(widget.chatRoomId));

    ref.listen(chatMessagesProvider(widget.chatRoomId), (previous, next) {
      if (previous != null && next.messages.length > previous.messages.length) {
        _scrollToBottom();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('채팅방'),
        centerTitle: true,
      ),
      body: chatState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(8.0),
              itemCount: chatState.messages.length,
              itemBuilder: (context, index) {
                final message = chatState.messages[index];
                final bool isMe = message.senderId == currentUserId;
                
                DateTime timestamp;
                if (message.createdAt != null && message.createdAt!.isNotEmpty) {
                  timestamp = DateTime.parse(message.createdAt!);
                } else {
                  timestamp = DateTime.now(); // createdAt이 null이거나 비어있으면 현재 시간으로 대체
                }

                return ChatBubble(
                  message: message.message ?? "메시지 없음",
                  isMe: isMe,
                  timestamp: timestamp,
                );
              },
            ),
      bottomNavigationBar: ChatTextField(
        controller: _textController,
        onSend: _sendMessage,
      ),
    );
  }
}
