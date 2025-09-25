import 'package:chakak_flutter/ui/pages/photo_service/photo_service_form_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../_core/constants/app_colors.dart';
import '../../../../_core/utils/error_handler.dart';
import '../../../data/dtos/chat_room_create_request_dto.dart';
import '../../../data/models/photo_service/photo_service.dart';
import '../../../data/models/review.dart';
import '../../../provider/auth/session_provider.dart';
import '../../../provider/chat/chat_provider.dart';
import '../../../provider/global/photoService/photo_service_provider.dart';
import '../../../provider/global/photographer/photographer_provider.dart';
import '../../../provider/review/review_provider.dart';
import '../chat/chat_screen.dart';
import '../profile/photographer/photographer_profile_page.dart';
import '../profile/user/widgets/login_required_dialog.dart';
import '../review/review_list_screen.dart';
import '../review/widgets/review_card_widget.dart';
import 'widgets/other_services_section.dart';
import 'widgets/photographer_info_section.dart';
import 'widgets/service_description_section.dart';
import 'widgets/service_gallery_section.dart';
import 'widgets/service_image_section.dart';
import 'widgets/service_info_section.dart';
import 'widgets/service_price_section.dart';

// ConsumerWidget 대신 ConsumerStatefulWidget 사용
class PhotoServiceDetailPage extends ConsumerStatefulWidget {
  final PhotoService service;
  final List<PhotoService>? otherServices;

  const PhotoServiceDetailPage({
    super.key,
    required this.service,
    this.otherServices,
  });

  @override
  ConsumerState<PhotoServiceDetailPage> createState() =>
      _PhotoServiceDetailPageState();
}

class _PhotoServiceDetailPageState
    extends ConsumerState<PhotoServiceDetailPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final reviewStatusNotifier = ref.read(reviewStatusProvider.notifier);
      final currentStatus = ref.read(reviewStatusProvider);
      if (currentStatus.currentServiceId != widget.service.id ||
          currentStatus.status == ReviewServiceFetchStatus.initial) {
        debugPrint(
            "[PhotoServiceDetailPage] Fetching review status for service ID: ${widget.service.id}");
        reviewStatusNotifier.fetchStatus(widget.service.id);
      } else {
        debugPrint(
            "[PhotoServiceDetailPage] Review status for service ID: ${widget.service.id} is already up-to-date or loading.");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final serviceState = ref.watch(photoServiceProvider);

    // provider에서 최신 데이터 찾기
    final currentService = serviceState.services
            .where((s) => s.id == widget.service.id)
            .firstOrNull ??
        widget.service;

    print('=== 이미지 디버깅 ===');
    print('currentService.imageUrl: ${currentService.imageUrl}');
    print('imageUrl length: ${currentService.imageUrl.length}');

    return Scaffold(
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ServiceImageSection(service: currentService),
            ServiceInfoSection(service: currentService),
            ServicePriceSection(service: currentService),
            ServiceDescriptionSection(service: currentService),
            ServiceGallerySection(
                photographerId: currentService.photographerId),
            PhotographerInfoSection(
              service: currentService,
              onProfileTap: () => _onPhotographerProfileTap(context),
            ),
            OtherServicesSection(
              service: currentService,
              otherServices: widget.otherServices,
              onServiceTap: (otherService) =>
                  _onOtherServiceTap(context, otherService),
            ),
            ServiceReviewSection(
              service: currentService,
              onViewAllTap: () => _onViewAllReviewsTap(context),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(context, ref),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final serviceState = ref.watch(photoServiceProvider); // 추가
    final bool isOwner = _isOwner();
    final currentService = serviceState.services
            .where((s) => s.id == widget.service.id)
            .firstOrNull ??
        widget.service;

    return AppBar(
      backgroundColor: AppColors.primaryLight,
      title: Text(
        currentService.title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      actions: [
        // 수정 버튼 (소유자만 표시)
        if (isOwner)
          IconButton(
            onPressed: _onEditTap,
            icon: const Icon(Icons.edit_outlined),
          ),
        // 삭제 버튼 (소유자만 표시)
        if (isOwner)
          IconButton(
            onPressed: _onDeleteTap,
            icon: const Icon(Icons.delete_outlined),
          ),
        // 공유 버튼
        IconButton(
          onPressed: _onShareTap,
          icon: const Icon(Icons.share_outlined),
        ),
      ],
    );
  }

  bool _isOwner() {
    final session = ref.watch(sessionProvider);
    debugPrint('현재 로그인 userId: ${session.userId}');
    debugPrint(
        '현재 서비스 photographerUserId: ${widget.service.photographerUserId}');
    // userId가 포토그래퍼의 User ID와 일치하는지 확인
    final bool isMatch =
        session.userId == widget.service.photographerUserId; // 이 부분 수정
    debugPrint('두 ID가 일치하는가? $isMatch');
    return isMatch;
  }

  Widget _buildBottomBar(BuildContext context, WidgetRef ref) {
    final serviceState = ref.watch(photoServiceProvider);
    final currentService = serviceState.services.firstWhere(
        (s) => s.id == widget.service.id,
        orElse: () => widget.service);

    // 현재 유저가 포토그래퍼인지 확인 (로그인한 유저가 포토그래퍼 타입이면 모든 예약 버튼 숨김)
    final session = ref.watch(sessionProvider);
    final bool isPhotographer = session.userTypeCode == 'photographer';

    // 포토그래퍼인 경우 bottomNavigationBar를 null로 반환하여 숨김
    if (isPhotographer) {
      return const SizedBox
          .shrink(); // 또는 null을 반환할 수 있지만, Widget을 반환하는 것이 더 안전
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () => _onBookingTap(context, ref),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                '예약하기',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onEditTap() {
    debugPrint('서비스 수정: ${widget.service.title}');
    try {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PhotoServiceFormPage(
            service: widget.service,
            photographerId: widget.service.photographerId,
          ),
        ),
      ).then((result) async {
        if (result == true) {
          // 데이터 새로고침
          await ref
              .read(photoServiceProvider.notifier)
              .loadServicesByPhotographer(widget.service.photographerId);

          // 현재 화면 새로고침을 위해 setState 호출
          if (mounted) {
            setState(() {
              // 화면 리빌드를 트리거
            });
          }
        }
      });
    } catch (error) {
      ErrorHandler.handleError(
        context,
        error,
        customMessage: '서비스 수정 페이지를 불러올 수 없습니다',
      );
    }
  }

  void _onDeleteTap() {
    debugPrint('서비스 삭제: ${widget.service.title}');
    _showDeleteConfirmDialog();
  }

  void _showDeleteConfirmDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('서비스 삭제'),
        content: const Text('정말로 이 서비스를 삭제하시겠습니까?\n삭제된 서비스는 복구할 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              try {
                // 삭제 API 호출
                await ref
                    .read(photoServiceProvider.notifier)
                    .deleteService(widget.service.id);
                if (context.mounted) {
                  Navigator.of(context).pop(); // 다이얼로그 닫기
                  Navigator.of(context).pop(); // 이전 페이지로 돌아가기
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('서비스가 삭제되었습니다.'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.of(context).pop(); // 다이얼로그 닫기
                  ErrorHandler.handleError(context, e,
                      customMessage: '서비스 삭제에 실패했습니다.');
                }
              }
            },
            child: const Text('삭제', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  void _onShareTap() {
    debugPrint("[PhotoServiceDetailPage] _onShareTap called.");
    try {
      final reviewStatusState = ref.read(reviewStatusProvider);
      debugPrint(
          "[PhotoServiceDetailPage] Current reviewStatusState status: ${reviewStatusState.status}, serviceId: ${reviewStatusState.currentServiceId}, data: ${reviewStatusState.data}");

      final String averageRatingStr =
          (reviewStatusState.status == ReviewServiceFetchStatus.success &&
                  reviewStatusState.data != null &&
                  reviewStatusState.currentServiceId == widget.service.id)
              ? reviewStatusState.data!.averageRating.toStringAsFixed(1)
              : widget.service.rating.toStringAsFixed(1);

      final String totalReviewsStr =
          (reviewStatusState.status == ReviewServiceFetchStatus.success &&
                  reviewStatusState.data != null &&
                  reviewStatusState.currentServiceId == widget.service.id)
              ? reviewStatusState.data!.totalReviews.toString()
              : widget.service.reviewCount.toString();

      debugPrint(
          "[PhotoServiceDetailPage] Sharing with: ratingStr: $averageRatingStr, reviewsStr: $totalReviewsStr");

      final shareText = '${widget.service.title}\n'
          '평점: ⭐ $averageRatingStr점 ($totalReviewsStr개 리뷰)\n'
          '가격: ${widget.service.price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원~\n'
          '카테고리: ${widget.service.categories.join(', ')}\n'
          '\n이 서비스를 확인해보세요!';

      Share.share(
        shareText,
        subject: widget.service.title,
      );
    } catch (error) {
      ErrorHandler.handleError(context, error,
          customMessage: '공유 중 오류가 발생했습니다');
    }
  }

  void _onBookingTap(BuildContext context, WidgetRef ref) async {
    final session = ref.read(sessionProvider);

    // 비로그인 사용자 체크
    if (!session.isLogin) {
      LoginRequiredDialog.show(context);
      return;
    }

    try {
      final photographer = ref
          .read(photographerProvider.notifier)
          .getPhotographerById(widget.service.photographerId);

      final chatRequest = ChatRoomCreateRequestDto(
        photographerProfileId: widget.service.photographerId,
        userProfileId: session.userId,
      );

      final chatRoom = await ref
          .read(chatRepositoryProvider)
          .createOrGetChatRoom(chatRequest);

      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              chatRoomId: chatRoom.chatRoomId,
              opponentNickname: photographer?.businessName ?? "포토그래퍼",
            ),
          ),
        );
      }
    } catch (error) {
      ErrorHandler.handleError(context, error,
          customMessage: '채팅 연결 중 오류가 발생했습니다');
    }
  }

  void _onPhotographerProfileTap(BuildContext context) {
    try {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PhotographerProfilePage(
            photographerId: widget.service.photographerId,
          ),
        ),
      );
    } catch (error) {
      ErrorHandler.handleError(
        context,
        error,
        customMessage: '포토그래퍼 프로필을 불러올 수 없습니다',
      );
    }
  }

  void _onOtherServiceTap(BuildContext context, PhotoService otherService) {
    try {
      final remainingServices = widget.otherServices
          ?.where((s) => s.id != widget.service.id && s.id != otherService.id)
          .toList();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PhotoServiceDetailPage(
            service: otherService,
            otherServices: remainingServices,
          ),
        ),
      );
    } catch (error) {
      ErrorHandler.handleError(
        context,
        error,
        customMessage: '다른 서비스로 이동할 수 없습니다',
      );
    }
  }

  void _onViewAllReviewsTap(BuildContext context) {
    try {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ReviewListScreen(serviceId: widget.service.id),
        ),
      );
    } catch (error) {
      ErrorHandler.handleError(
        context,
        error,
        customMessage: '리뷰를 불러올 수 없습니다',
      );
    }
  }
}

/// --------------------
/// 리뷰 미리보기 섹션 (ServiceReviewSection으로 이름 통일)
/// --------------------
class ServiceReviewSection extends ConsumerWidget {
  final PhotoService service;
  final VoidCallback onViewAllTap;

  const ServiceReviewSection({
    super.key,
    required this.service,
    required this.onViewAllTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // recentReviewsProvider는 List<ReviewDto>를 반환합니다.
    final asyncReviews = ref.watch(recentReviewsProvider(service.id));

    return asyncReviews.when(
      data: (reviewDtoList) {
        // 변수명을 reviewDtoList로 변경하여 명확화
        if (reviewDtoList.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text("아직 리뷰가 없습니다."),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 "최근 리뷰" + "모두 보기"를 한 줄에 배치
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "최근 리뷰",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: onViewAllTap,
                    child: const Text("모두 보기"),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // reviewDtoList (List<ReviewDto>)를 사용
            ...reviewDtoList.take(5).map(
              (reviewDto) {
                // 변수명을 reviewDto로 변경
                // ReviewDto를 Review 모델로 변환
                final Review reviewModel = reviewDto.toModel();

                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
                  child: ReviewCardWidget(
                    review: reviewModel, // 변환된 Review 모델 전달
                    mode: "user", // 또는 "service_detail" 등 적절한 모드
                  ),
                );
              },
            ),
          ],
        );
      },
      loading: () =>
          const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      error: (err, stack) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text("리뷰 불러오기 실패: $err"),
      ),
    );
  }
}
