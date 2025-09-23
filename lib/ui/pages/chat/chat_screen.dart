import 'package:cached_network_image/cached_network_image.dart';
import 'package:chakak_flutter/provider/auth/session_provider.dart';
import 'package:chakak_flutter/provider/chat/chat_provider.dart';
import 'package:chakak_flutter/ui/pages/chat/widgets/image_upload_helper.dart';
import 'package:chakak_flutter/ui/pages/chat/widgets/payment_request_bubble.dart';
import 'package:chakak_flutter/ui/pages/chat/widgets/payment_request_dialog.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import 'package:permission_handler/permission_handler.dart';
import '../../../_core/constants/app_colors.dart';
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

  int? photographerId;
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

      photographerId =
          await photoService.getPhotographerIdByUserId(session.userId!);

      if (photographerId != null) {
        print(
            '[ChatScreen] 매핑 성공: userId(${session.userId}) → photographerId($photographerId)');
      } else {
        print('[ChatScreen] 매핑 실패: 기본값 사용');
        photographerId = session.userId;
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

  Future<void> _pickImage() async {
    if (kDebugMode) {
      print('[DEBUG] _pickImage() 함수 시작');
    }

    var status = await Permission.photos.status;
    if (kDebugMode) {
      print('[DEBUG] 현재 사진 권한 상태: $status');
    }

    if (status.isDenied) {
      if (kDebugMode) {
        print('[DEBUG] 권한이 거부되어 있어 요청합니다.');
      }
      status = await Permission.photos.request();
      if (kDebugMode) {
        print('[DEBUG] 권한 요청 후 상태: $status');
      }
    }

    if (status.isGranted || status.isLimited) {
      if (kDebugMode) {
        print('[DEBUG] 권한이 허용 또는 일부 허용되었습니다. 이미지 선택 로직을 실행합니다.');
      }
      if (mounted) {
        ImageUploadHelper.pickAndUploadImage(
          context,
          onImageSelected: (base64Image, fileName, fileSize) {
            final chatNotifier =
                ref.read(chatMessagesProvider(widget.chatRoomId).notifier);
            chatNotifier.sendImageMessage(
              base64Image: base64Image,
              fileName: fileName,
              fileSize: fileSize,
            );
            _scrollToBottomWithDelay();
          },
        );
      }
    } else if (status.isPermanentlyDenied) {
      if (kDebugMode) {
        print('[DEBUG] 권한이 영구적으로 거부되었습니다. 설정 안내를 표시합니다.');
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('사진 접근 권한이 필요합니다. 앱 설정에서 허용해주세요.'),
            action: SnackBarAction(
              label: '설정 열기',
              onPressed: () => openAppSettings(),
            ),
          ),
        );
      }
    } else {
      if (kDebugMode) {
        print('[DEBUG] 권한이 허용되지 않았습니다 (현재 상태: $status). 아무 동작도 하지 않습니다.');
      }
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
    final userProfileId = chatNotifier.opponentUserId ?? widget.opponentUserId;

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
      photographerId: photographerId!,
      userProfileId: userProfileId,
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
          color: AppColors.surface, // white → AppColors.surface
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
                color: AppColors
                    .gray300, // Colors.grey.shade300 → AppColors.gray300
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (isPhotographer && isPhotographerIdLoaded)
                  _buildOptionButton(
                    icon: Icons.payment,
                    label: '결제 요청',
                    color: AppColors.primary, // Colors.blue → AppColors.primary
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
                  color:
                      AppColors.secondary, // Colors.green → AppColors.secondary
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage();
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
          style: const TextStyle(
            color: AppColors
                .textSecondary, // Colors.grey.shade700 → AppColors.textSecondary
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildImageBubble({
    required bool isMe,
    String? imageUrl,
    DateTime? timestamp,
  }) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return const SizedBox.shrink();
    }

    final imageWidget = CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      placeholder: (context, url) =>
          const Center(child: CircularProgressIndicator()),
      errorWidget: (context, url, error) {
        print('##### CachedNetworkImage Error #####');
        print('Failed to load image from URL: $url');
        print('Error: $error');
        print('####################################');
        return const Icon(Icons.error);
      },
    );

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.all(8.0),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.6),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: imageWidget,
            ),
            if (timestamp != null)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(fontSize: 10.0, color: Colors.grey),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: const BoxDecoration(
        color: AppColors.surface, // Colors.white → AppColors.surface
        border: Border(
            top: BorderSide(
                color: AppColors
                    .border)), // Colors.grey.shade200 → AppColors.border
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.add_circle,
                  color: AppColors
                      .gray500), // Colors.grey.shade500 → AppColors.gray500
              onPressed: _showOptionsBottomSheet,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: TextField(
                  controller: _textController,
                  decoration: const InputDecoration(
                    hintText: '메시지를 입력하세요',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(24)),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: AppColors
                        .gray200, // Colors.grey.shade200 → AppColors.gray200
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  onSubmitted: _handleSubmitted,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Material(
              color:
                  AppColors.primary, // Colors.blue.shade600 → AppColors.primary
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
                    color: AppColors
                        .textOnPrimary, // Colors.white → AppColors.textOnPrimary
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

                          final timestamp = message.createdAt != null
                              ? DateTime.tryParse(message.createdAt!)
                              : null;

                          if (message.isImageMessage) {
                            return _buildImageBubble(
                              isMe: isMe,
                              imageUrl: message.imageUrl,
                              timestamp: timestamp,
                            );
                          }

                          if (message.messageType == 'PAYMENT_REQUEST') {
                            return PaymentRequestBubble(
                              title: message.message,
                              price: message.paymentAmount ?? 0,
                              description: message.paymentDescription ?? '',
                              isMe: isMe,
                              bookingInfoId: message.bookingInfoId!,
                            );
                          }
                          return ChatBubble(
                            message: message.message,
                            isMe: isMe,
                            timestamp: timestamp ?? DateTime.now(),
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
