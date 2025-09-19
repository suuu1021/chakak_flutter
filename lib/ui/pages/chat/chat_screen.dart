import 'package:chakak_flutter/provider/auth/session_provider.dart';
import 'package:chakak_flutter/provider/chat/chat_provider.dart';
import 'package:chakak_flutter/ui/pages/chat/widgets/payment_request_bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../widgets/chat_bubble.dart';
import '../../widgets/chat_text_field.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final int chatRoomId;
  final String opponentNickname;

  const ChatScreen({
    Key? key,
    required this.chatRoomId,
    required this.opponentNickname,
  }) : super(key: key);

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
      _initializeChat();
    });
  }

  void _initializeChat() {
    final session = ref.read(sessionProvider);
    final chatNotifier = ref.read(chatMessagesProvider(widget.chatRoomId).notifier);

    if (session.isLogin && session.jwtToken != null && session.userId != null && session.userTypeCode != null) {
      chatNotifier.connectAndListen(
        jwtToken: session.jwtToken!,
        userId: session.userId!,
        userType: session.userTypeCode!,
      );
    }
  }

  void _handleSubmitted(String text) {
    if (text.trim().isEmpty) return;

    final chatNotifier = ref.read(chatMessagesProvider(widget.chatRoomId).notifier);
    chatNotifier.sendMessage(messageContent: text);

    _textController.clear();
    _scrollToBottomWithDelay();
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

  void _scrollToBottomWithDelay() {
    Future.delayed(const Duration(milliseconds: 100), () => _scrollToBottom());
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final opponentName = widget.opponentNickname;
    final chatState = ref.watch(chatMessagesProvider(widget.chatRoomId));
    final session = ref.watch(sessionProvider);
    final myUserId = session.userId;

    ref.listen(chatMessagesProvider(widget.chatRoomId), (prev, next) {
      if (prev?.messages.length != next.messages.length) {
        _scrollToBottomWithDelay();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(opponentName),
        centerTitle: false,
      ),
      body: Column(
        children: [
          if (chatState.isLoading)
            const LinearProgressIndicator(),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16.0),
              itemCount: chatState.messages.length,
              itemBuilder: (context, index) {
                final message = chatState.messages[index];
                final isMe = message.senderId == myUserId;
                final timestamp = DateTime.tryParse(message.createdAt ?? '') ?? DateTime.now();

                if (message.messageType == 'PAYMENT_REQUEST') {
                  return PaymentRequestBubble(
                    title: message.message,
                    price: message.paymentAmount ?? 0,
                    description: "결제 요청 메시지",
                    isMe: isMe,
                  );
                }

                return ChatBubble(
                  message: message.message,
                  isMe: isMe,
                  timestamp: timestamp,
                );
              },
            ),
          ),
          ChatTextField(
            controller: _textController,
            onSend: () {
              if (_textController.text.trim().isNotEmpty) {
                _handleSubmitted(_textController.text);
              }
            },
          ),
          if (chatState.errorMessage != null)
            Container(
              color: Colors.red,
              width: double.infinity,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                chatState.errorMessage!,
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}
