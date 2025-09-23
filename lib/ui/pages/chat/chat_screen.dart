import 'package:chakak_flutter/provider/auth/session_provider.dart';
import 'package:chakak_flutter/provider/chat/chat_provider.dart';
import 'package:chakak_flutter/ui/pages/chat/widgets/image_upload_helper.dart';
import 'package:chakak_flutter/ui/pages/chat/widgets/payment_request_bubble.dart';
import 'package:chakak_flutter/ui/pages/chat/widgets/payment_request_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import '../../widgets/chat_bubble.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final int chatRoomId;
  final String opponentNickname;
  final int? opponentUserId;

  const ChatScreen({
    Key? key,
    required this.chatRoomId,
    required this.opponentNickname,
    this.opponentUserId,
  }) : super(key: key);

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  int? photographerId; // photographer.id 저장
  bool isPhotographerIdLoaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeChat();
    });
  }

  void _initializeChat() async {
    final session = ref.read(sessionProvider);
    final chatNotifier =
        ref.read(chatMessagesProvider(widget.chatRoomId).notifier);

    print('[ChatScreen] 초기화 정보:');
    print('  - chatRoomId: ${widget.chatRoomId}');
    print('  - opponentUserId: ${widget.opponentUserId}');
    print('  - opponentNickname: ${widget.opponentNickname}');
    print('  - session.userId: ${session.userId}');
    print('  - session.userTypeCode: ${session.userTypeCode}');

    // photographer인 경우 photographer.id 로드
    if (session.userTypeCode?.toLowerCase() == 'photographer') {
      await _loadPhotographerId();
    }

    if (session.isLogin &&
        session.jwtToken != null &&
        session.userId != null &&
        session.userTypeCode != null) {
      chatNotifier.connectAndListen(
        jwtToken: session.jwtToken!,
        userId: session.userId!,
        userType: session.userTypeCode!,
        opponentUserId: widget.opponentUserId,
      );
    }
  }

  Future<void> _loadPhotographerId() async {
    try {
      final session = ref.read(sessionProvider);
      final photoService = ref.read(photoServiceRepositoryProvider);

      // 1단계: userId로 photographerId 매핑
      photographerId =
          await photoService.getPhotographerIdByUserId(session.userId!);

      if (photographerId != null) {
        print(
            '[ChatScreen] 매핑 성공: userId(${session.userId}) → photographerId($photographerId)');
      } else {
        print('[ChatScreen] 매핑 실패: 기본값 사용');
        photographerId = session.userId; // 기본값
      }
    } catch (e) {
      print('[ERROR] photographerId 매핑 실패: $e');
      photographerId = ref.read(sessionProvider).userId;
    } finally {
      setState(() {
        isPhotographerIdLoaded = true;
      });
    }
  }

  void _handleSubmitted(String text) {
    if (text.trim().isEmpty) return;

    final chatNotifier =
        ref.read(chatMessagesProvider(widget.chatRoomId).notifier);
    chatNotifier.sendMessage(messageContent: text);

    _textController.clear();
    _scrollToBottomWithDelay();
  }

  void _handlePaymentRequest(String title, int amount, String? description,
      int photoServiceInfoId, int priceInfoId) async {
    final chatNotifier =
        ref.read(chatMessagesProvider(widget.chatRoomId).notifier);
    final userProfileId =
        chatNotifier.opponentUserId ?? widget.opponentUserId; // getter 사용

    if (photographerId == null || userProfileId == null) {
      print('결제 요청에 필요한 사용자 ID가 누락되었습니다.');
      print('  - photographerId: $photographerId');
      print('  - userProfileId: $userProfileId');
      return;
    }

    print('[ChatScreen] 결제 요청 데이터:');
    print('  - photographerId: $photographerId (photographer.id)');
    print('  - userProfileId: $userProfileId (상대방 ID)');

    await chatNotifier.sendPaymentRequest(
      title: title,
      amount: amount,
      description: description,
      photoServiceInfoId: photoServiceInfoId,
      priceInfoId: priceInfoId,
      photographerId: photographerId!, // photographer.id 사용
      userProfileId: userProfileId, // 상대방 ID 사용
    );
    _scrollToBottomWithDelay();
  }

  void _scrollToBottomWithDelay() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showOptionsBottomSheet() {
    final session = ref.read(sessionProvider);
    final isPhotographer =
        session.userTypeCode?.toLowerCase() == 'photographer';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (isPhotographer &&
                    isPhotographerIdLoaded) // photographer.id 로드 완료 후에만 표시
                  _buildOptionButton(
                    icon: Icons.payment,
                    label: '결제 요청',
                    color: Colors.blue,
                    onTap: () {
                      Navigator.pop(context);
                      PaymentRequestDialog.show(
                        context,
                        onPaymentRequest: (title, amount, description,
                            photoServiceInfoId, priceInfoId) {
                          _handlePaymentRequest(title, amount, description,
                              photoServiceInfoId, priceInfoId);
                        },
                        ref: ref,
                      );
                    },
                  ),
                _buildOptionButton(
                  icon: Icons.image,
                  label: '이미지',
                  color: Colors.green,
                  onTap: () {
                    Navigator.pop(context);
                    ImageUploadHelper.pickAndUploadImage(
                      context,
                      onImageSelected: (base64Image, fileName, fileSize) {
                        final chatNotifier = ref.read(
                            chatMessagesProvider(widget.chatRoomId).notifier);
                        chatNotifier.sendImageMessage(
                          base64Image: base64Image,
                          fileName: fileName,
                          fileSize: fileSize,
                        );
                        _scrollToBottomWithDelay();
                      },
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(40),
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Icon(icon, color: color, size: 30),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: Icon(Icons.add_circle, color: Colors.grey.shade500),
              onPressed: _showOptionsBottomSheet,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: TextField(
                  controller: _textController,
                  decoration: InputDecoration(
                    hintText: '메시지를 입력하세요',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade200,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  onSubmitted: _handleSubmitted,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Material(
              color: Colors.blue.shade600,
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                onTap: () {
                  if (_textController.text.trim().isNotEmpty) {
                    _handleSubmitted(_textController.text);
                  }
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.send,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatMessagesProvider(widget.chatRoomId));
    final sessionState = ref.watch(sessionProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.opponentNickname),
      ),
      body: Column(
        children: [
          Expanded(
            child: chatState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : chatState.errorMessage != null
                    ? Center(
                        child: Text(
                          '${chatState.errorMessage}',
                          style: const TextStyle(color: Colors.red),
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        reverse: false,
                        itemCount: chatState.messages.length,
                        itemBuilder: (context, index) {
                          final message = chatState.messages[index];
                          final isMe = message.senderId == sessionState.userId;

                          DateTime timestamp;
                          try {
                            timestamp = message.createdAt != null
                                ? DateTime.parse(message.createdAt!)
                                : DateTime.now();
                          } catch (e) {
                            timestamp = DateTime.now();
                          }

                          if (message.messageType == 'PAYMENT_REQUEST') {
                            return PaymentRequestBubble(
                              title: message.message,
                              price: message.paymentAmount ?? 0,
                              description: message.paymentDescription ?? '',
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
          _buildInputArea(),
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
