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
    final chatNotifier =
        ref.read(chatMessagesProvider(widget.chatRoomId).notifier);

    if (session.isLogin &&
        session.jwtToken != null &&
        session.userId != null &&
        session.userTypeCode != null) {
      chatNotifier.connectAndListen(
        jwtToken: session.jwtToken!,
        userId: session.userId!,
        userType: session.userTypeCode!,
      );
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

  void _handlePaymentRequest(String title, int amount, String? description) {
    final chatNotifier =
        ref.read(chatMessagesProvider(widget.chatRoomId).notifier);
    chatNotifier.sendPaymentRequest(
      title: title,
      amount: amount,
      description: description,
    );
    _scrollToBottomWithDelay();
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
            // 핸들 바
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            // 옵션 리스트
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // 결제 요청 (포토그래퍼만)
                if (isPhotographer)
                  _buildOptionButton(
                    icon: Icons.payment,
                    label: '결제 요청',
                    color: Colors.blue,
                    onTap: () {
                      Navigator.pop(context);
                      PaymentRequestDialog.show(context,
                          onPaymentRequest: _handlePaymentRequest, ref: ref);
                    },
                  ),

                // 이미지 업로드
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

                // 포토그래퍼가 아닌 경우 빈 공간 추가
                if (!isPhotographer) const SizedBox(width: 60),
              ],
            ),

            const SizedBox(height: 20),
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
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: color.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              color: color,
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  // 이미지 버블 위젯 (추가)
  Widget _buildImageBubble({
    String? imageData,
    required String fileName,
    int? fileSize,
    required bool isMe,
    required DateTime timestamp,
  }) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              constraints: const BoxConstraints(maxWidth: 250),
              decoration: BoxDecoration(
                color: isMe ? Colors.blue.shade600 : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 이미지 표시
                  if (imageData != null && imageData.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.memory(
                        base64Decode(imageData),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 100,
                            width: double.infinity,
                            color: Colors.grey.shade300,
                            child: const Icon(
                              Icons.broken_image,
                              color: Colors.grey,
                              size: 40,
                            ),
                          );
                        },
                      ),
                    )
                  else
                    Container(
                      height: 100,
                      width: double.infinity,
                      color: Colors.grey.shade300,
                      child: const Icon(
                        Icons.image,
                        color: Colors.grey,
                        size: 40,
                      ),
                    ),

                  const SizedBox(height: 8),

                  // 파일 정보
                  Row(
                    children: [
                      Icon(
                        Icons.attachment,
                        size: 16,
                        color: isMe ? Colors.white70 : Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          fileName,
                          style: TextStyle(
                            color: isMe ? Colors.white : Colors.black87,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  if (fileSize != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      ImageUploadHelper.formatFileSize(fileSize),
                      style: TextStyle(
                        color: isMe ? Colors.white70 : Colors.grey.shade600,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 2),

            // 타임스탬프
            Text(
              '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
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
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          opponentName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: false,
      ),
      body: Column(
        children: [
          if (chatState.isLoading) const LinearProgressIndicator(),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16.0),
              itemCount: chatState.messages.length,
              itemBuilder: (context, index) {
                final message = chatState.messages[index];
                final isMe = message.senderId == myUserId;
                final timestamp = DateTime.tryParse(message.createdAt ?? '') ??
                    DateTime.now();

                // 결제 요청 메시지
                if (message.messageType == 'PAYMENT_REQUEST') {
                  return PaymentRequestBubble(
                    title: message.message,
                    price: message.paymentAmount ?? 0,
                    description: message.paymentDescription ?? "결제 요청 메시지",
                    isMe: isMe,
                  );
                }

                // 이미지 메시지
                if (message.messageType == 'IMAGE') {
                  return _buildImageBubble(
                    imageData: message.imageData,
                    fileName: message.fileName ?? message.message,
                    fileSize: message.fileSize,
                    isMe: isMe,
                    timestamp: timestamp,
                  );
                }

                // 일반 텍스트 메시지
                return ChatBubble(
                  message: message.message,
                  isMe: isMe,
                  timestamp: timestamp,
                );
              },
            ),
          ),

          // 수정된 입력 영역
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            child: Row(
              children: [
                // + 버튼 (결제 요청/이미지)
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: Material(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                    child: InkWell(
                      onTap: _showOptionsBottomSheet,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          Icons.add,
                          color: Colors.grey.shade600,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ),

                // 메시지 입력 필드
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: TextField(
                      controller: _textController,
                      decoration: const InputDecoration(
                        hintText: '메시지를 입력하세요...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                      maxLines: null,
                      onSubmitted: (text) {
                        if (text.trim().isNotEmpty) {
                          _handleSubmitted(text);
                        }
                      },
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // 전송 버튼
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
