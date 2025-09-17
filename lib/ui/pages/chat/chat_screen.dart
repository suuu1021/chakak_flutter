import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/dtos/chat_message_dto.dart';
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

  late final List<ChatMessageDto> _dummyMessages;

  final _myUserId = 999;
  final _myUserType = 'INDIVIDUAL';

  @override
  void initState() {
    super.initState();
    _dummyMessages = _generateDummyMessages(widget.chatRoomId);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  List<ChatMessageDto> _generateDummyMessages(int chatRoomId) {
    final now = DateTime.now();
    final opponentId = chatRoomId;
    const opponentUserType = 'COMPANY';

    switch (chatRoomId) {
      case 1:
        return [
          ChatMessageDto(
            chatRoomId: chatRoomId,
            senderId: _myUserId,
            senderType: _myUserType,
            messageType: 'TALK',
            message: '안녕하세요, 돌잔치 스냅 예약 문의드립니다.',
            createdAt: now.subtract(const Duration(days: 1, hours: 2)).toIso8601String(),
          ),
          ChatMessageDto(
            chatRoomId: chatRoomId,
            senderId: opponentId,
            senderType: opponentUserType,
            messageType: 'TALK',
            message: '안녕하세요, 고객님! 문의 환영합니다. 언제쯤 행사 예정이신가요?',
            createdAt: now.subtract(const Duration(days: 1, hours: 1, minutes: 58)).toIso8601String(),
          ),
          ChatMessageDto(
            chatRoomId: chatRoomId,
            senderId: _myUserId,
            senderType: _myUserType,
            messageType: 'TALK',
            message: '다음 달 15일 토요일 점심입니다. 예약 가능할까요?',
            createdAt: now.subtract(const Duration(hours: 5)).toIso8601String(),
          ),
          ChatMessageDto(
            chatRoomId: chatRoomId,
            senderId: opponentId,
            senderType: opponentUserType,
            messageType: 'TALK',
            message: '네, 확인해보니 그날은 다행히 예약 가능합니다. 원하시는 상품이 있으실까요? 홈페이지에서 보신 패키지명을 알려주세요. 😊',
            createdAt: now.subtract(const Duration(hours: 4, minutes: 55)).toIso8601String(),
          ),
          ChatMessageDto(
            chatRoomId: chatRoomId,
            senderId: _myUserId,
            senderType: _myUserType,
            messageType: 'TALK',
            message: '프리미엄 B 패키지로 하고 싶어요!',
            createdAt: now.subtract(const Duration(minutes: 30)).toIso8601String(),
          ),
          ChatMessageDto(
            chatRoomId: chatRoomId,
            senderId: opponentId,
            senderType: opponentUserType,
            messageType: 'TALK',
            message: '알겠습니다. 프리미엄 B 패키지로 예약 진행 도와드리겠습니다. 계약서 작성을 위해 성함과 연락처를 알려주시겠어요?',
            createdAt: now.subtract(const Duration(minutes: 5)).toIso8601String(),
          ),
        ];
      case 2:
        return [
          ChatMessageDto(
            chatRoomId: chatRoomId,
            senderId: opponentId,
            senderType: opponentUserType,
            messageType: 'TALK',
            message: '요청하신 로고 시안 보내드립니다. 확인 후 피드백 부탁드려요.',
            createdAt: now.subtract(const Duration(days: 1, hours: 5)).toIso8601String(),
          ),
          ChatMessageDto(
            chatRoomId: chatRoomId,
            senderId: _myUserId,
            senderType: _myUserType,
            messageType: 'TALK',
            message: '네, 확인했습니다. 시안 보내드릴게요.',
            createdAt: now.subtract(const Duration(days: 1, hours: 2)).toIso8601String(),
          ),
        ];
      case 3:
        return [
          ChatMessageDto(
            chatRoomId: chatRoomId,
            senderId: opponentId,
            senderType: opponentUserType,
            messageType: 'TALK',
            message: '안녕하세요, 어제 공유드린 기획안 보셨을까요? 주요 기능 관련해서 논의할 부분이 있습니다.',
            createdAt: now.subtract(const Duration(days: 3, hours: 8)).toIso8601String(),
          ),
          ChatMessageDto(
            chatRoomId: chatRoomId,
            senderId: _myUserId,
            senderType: _myUserType,
            messageType: 'TALK',
            message: '아직 검토 중입니다. 오늘 오후 중으로 회신 드릴게요!',
            createdAt: now.subtract(const Duration(days: 3, hours: 4)).toIso8601String(),
          ),
          ChatMessageDto(
            chatRoomId: chatRoomId,
            senderId: opponentId,
            senderType: opponentUserType,
            messageType: 'TALK',
            message: '회의록 확인 부탁드립니다. 금일 중으로 피드백 주세요.',
            createdAt: now.subtract(const Duration(days: 3)).toIso8601String(),
          ),
        ];
      default:
        return [
          ChatMessageDto(
            chatRoomId: chatRoomId,
            senderId: opponentId,
            senderType: opponentUserType,
            messageType: 'TALK',
            message: '안녕하세요, 문의드립니다.',
            createdAt: now.subtract(const Duration(days: 10)).toIso8601String(),
          ),
        ];
    }
  }

  void _handleSubmitted(String text) {
    if (text.trim().isEmpty) return;

    _textController.clear();
    final newMessage = ChatMessageDto(
      chatRoomId: widget.chatRoomId,
      senderId: _myUserId,
      senderType: _myUserType,
      messageType: 'TALK',
      message: text,
      createdAt: DateTime.now().toIso8601String(),
    );

    setState(() {
      _dummyMessages.add(newMessage);
    });

    Future.delayed(const Duration(milliseconds: 50), () => _scrollToBottom());
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
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final opponentName = widget.opponentNickname;

    return Scaffold(
      appBar: AppBar(
        title: Text(opponentName),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16.0),
              itemCount: _dummyMessages.length,
              itemBuilder: (context, index) {
                final message = _dummyMessages[index];
                final isMe = message.senderId == _myUserId;

                final timestamp = DateTime.tryParse(message.createdAt ?? '') ?? DateTime.now();

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
        ],
      ),
    );
  }
}
