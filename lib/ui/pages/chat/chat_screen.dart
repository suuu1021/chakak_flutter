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
    // [추가] 화면이 빌드된 직후, 채팅 서버에 연결하고 초기 메시지를 가져옵니다.
    // TODO: 아래 jwtToken, userId, userType은 실제 로그인 유저의 정보로 반드시 교체해야 합니다.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(chatMessagesProvider(widget.chatRoomId).notifier)
          .connectAndListen(
            jwtToken: "YOUR_DUMMY_JWT", // <- 실제 유저의 JWT 토큰으로 교체하세요.
            userId: 1, // <- 실제 유저의 ID로 교체하세요.
            userType: "USER", // <- 실제 유저의 타입으로 교체하세요.
          );
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    // [수정] 화면이 사라질 때 disconnect를 명시적으로 호출합니다.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(chatMessagesProvider(widget.chatRoomId).notifier).disconnect();
    });
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _textController.text;
    if (text.isNotEmpty) {
      // [수정] provider의 올바른 메소드를 호출합니다.
      ref
          .read(chatMessagesProvider(widget.chatRoomId).notifier)
          .sendMessage(messageContent: text);
      _textController.clear();
      Future.delayed(const Duration(milliseconds: 50), () => _scrollToBottom());
    }
  }

  @override
  Widget build(BuildContext context) {
    // [수정] 올바른 provider를 watch 합니다.
    final chatState = ref.watch(chatMessagesProvider(widget.chatRoomId));

    // [수정] 메시지 목록이 변경될 때 스크롤을 아래로 내립니다.
    ref.listen(chatMessagesProvider(widget.chatRoomId), (previous, next) {
      if (previous != null && next.messages.length > previous.messages.length) {
        Future.delayed(
            const Duration(milliseconds: 50), () => _scrollToBottom());
      }
    });

    return Scaffold(
      appBar: AppBar(
        // [수정] chatRoom의 이름은 상태에 없으므로, 일단 고정 텍스트를 사용합니다.
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
                // [수정] isMe 로직을 실제 유저 ID와 비교해야 합니다. (현재는 임시로 1로 설정)
                final bool isMe = message.senderId == 1;
                return ChatBubble(
                  // [수정] ChatMessageDto의 필드에 맞게 전달합니다.
                  message: message.message ?? "메시지 없음",
                  isMe: isMe,
                  // [수정] String 타입의 날짜를 DateTime으로 변환하여 전달합니다.
                  timestamp: DateTime.parse(message.createdAt!),
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
