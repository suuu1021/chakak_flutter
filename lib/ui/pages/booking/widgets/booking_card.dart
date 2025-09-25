// features/booking/presentation/ui/widgets/booking_card.dart

import 'package:chakak_flutter/_core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../data/models/booking/booking_list_item.dart';
import '../../../../data/models/booking/booking_model.dart';
import '../../../../provider/auth/session_provider.dart';
import '../../../../provider/global/booking/booking_list_notifier.dart';
// 추가된 import 문들
import '../../../../provider/global/photoService/photo_service_provider.dart';
import '../../photo_service/photo_service_detail_page.dart'; // 경로는 실제 프로젝트 구조에 맞게 확인 필요
import '../../../../data/models/photo_service/photo_service.dart';

import '../../review/review_form_screen.dart';
import 'booking_cancel_dialog.dart';
import 'booking_status_chip.dart';

/// 예약 카드 위젯
class BookingCard extends ConsumerWidget {
  final BookingListItem booking;
  final VoidCallback? onTap;

  const BookingCard({
    super.key,
    required this.booking,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final userType = session.userTypeCode;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04), // LINT: Use .withValues()
            spreadRadius: 0,
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  BookingStatusChip(status: booking.status),
                  _buildActionButtons(context, ref, userType),
                ],
              ),
              const SizedBox(height: 12),
              if (booking.photoService != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: Colors.grey.shade200,
                      width: 0.5,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('yyyy년 M월 d일 HH:mm').format(booking.bookingDateTime), // LINT: Unnecessary string interpolation
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        booking.otherPartyName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Icon(
                              Icons.photo_camera_outlined,
                              size: 16,
                              color: Colors.blue.shade600,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              booking.photoService!.title,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Icon(
                              Icons.payments_outlined,
                              size: 16,
                              color: Colors.green.shade600,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '${NumberFormat('#,###').format(booking.photoService!.price)}원',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(
      BuildContext context, WidgetRef ref, String? userType) {
    if (userType == "user") {
      return _buildUserButtons(context, ref);
    } else if (userType == "photographer") {
      return _buildPhotographerButtons(context, ref);
    }
    return const SizedBox.shrink();
  }

  Widget _buildUserButtons(BuildContext context, WidgetRef ref) {
    switch (booking.status) {
      case BookingStatus.PENDING:
        return _buildActionChip(
          text: '예약 취소',
          color: AppColors.error,
          onPressed: () => _showCancelDialog(context, ref),
        );
      case BookingStatus.CONFIRMED:
        return _buildActionChip(text: '촬영 예정', color: AppColors.success);
      case BookingStatus.COMPLETED:
        return _buildActionChip(
          text: '리뷰 작성',
          color: AppColors.info,
          onPressed: () => _writeReview(context, ref),
        );
      case BookingStatus.REVIEWED:
        return _buildActionChip(
          text: '내 리뷰 보기',
          color: AppColors.secondary,
          onPressed: () => _viewMyReview(context, ref),
        );
      case BookingStatus.CANCELED:
        return _buildActionChip(text: '취소된 예약', color: AppColors.error);
      default: // LINT: This default clause is covered by the previous cases.
        return const SizedBox.shrink();
    }
  }

  Widget _buildPhotographerButtons(BuildContext context, WidgetRef ref) {
    switch (booking.status) {
      case BookingStatus.PENDING:
        return _buildActionChip(
          text: '결제 확인',
          color: AppColors.warning,
          onPressed: () => _confirmBooking(context, ref),
        );
      case BookingStatus.CONFIRMED:
        return _buildActionChip(
          text: '촬영 완료',
          color: AppColors.success,
          onPressed: () => _completeBooking(context, ref),
        );
      case BookingStatus.COMPLETED:
        return _buildActionChip(text: '촬영 완료', color: AppColors.info);
      case BookingStatus.REVIEWED:
        return _buildActionChip(
          text: '리뷰 확인',
          color: AppColors.secondary,
          onPressed: () => _viewReview(context, ref),
        );
      case BookingStatus.CANCELED:
        return _buildActionChip(text: '취소된 예약', color: AppColors.error);
      default: // LINT: This default clause is covered by the previous cases.
        return const SizedBox.shrink();
    }
  }

  Widget _buildActionChip({
    required String text,
    required Color color,
    VoidCallback? onPressed,
  }) {
    final isClickable = onPressed != null;

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isClickable ? color : color.withOpacity(0.1), // LINT: Use .withValues()
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isClickable ? color : color.withOpacity(0.3), // LINT: Use .withValues()
                ),
                boxShadow: isClickable
                    ? [
                        BoxShadow(
                          color: color.withOpacity(0.6), // LINT: Use .withValues()
                          blurRadius: 4,
                          offset: const Offset(1, 2),
                        ),
                      ]
                    : null,
              ),
              child: Text(
                text,
                style: TextStyle(
                  color: isClickable ? Colors.white : color,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showCancelDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => BookingCancelDialog(booking: booking),
    );
  }

  void _confirmBooking(BuildContext context, WidgetRef ref) {
    if (booking.bookingInfoId != null) {
      ref
          .read(bookingListProvider.notifier)
          .confirmBooking(booking.bookingInfoId!);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('예약이 확정되었습니다!')),
      );
    }
  }

  void _completeBooking(BuildContext context, WidgetRef ref) {
    if (booking.bookingInfoId != null) {
      ref
          .read(bookingListProvider.notifier)
          .completeBooking(booking.bookingInfoId!);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('촬영이 완료되었습니다!')),
      );
    }
  }

  void _writeReview(BuildContext context, WidgetRef ref) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReviewFormScreen(booking: booking),
      ),
    );

    if (result == true && context.mounted) {
      if (booking.bookingInfoId != null) {
        ref
            .read(bookingListProvider.notifier)
            .markBookingAsReviewed(booking.bookingInfoId!);
        // LINT: Don't invoke 'print' in production code.
        print(
            '[BookingCard] markBookingAsReviewed 호출 완료 for bookingId: ${booking.bookingInfoId}');
      } else {
        // LINT: Don't invoke 'print' in production code.
        print(
            '[BookingCard] booking.bookingInfoId is null, cannot update status.');
      }
    }
  }

  // 공통 서비스 상세 페이지 이동 로직
  Future<void> _navigateToServiceDetail(BuildContext context, WidgetRef ref) async {
    // booking.photoService?.id가 int? 타입이라고 가정하여 수정
    final int? serviceId = booking.photoService?.id;

    if (serviceId == null) { // .isEmpty 체크 제거, null 체크만 수행
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("서비스 ID가 없어 상세 페이지로 이동할 수 없습니다.")),
        );
      }
      return;
    }

    // serviceId는 이미 int? 타입이므로, 파싱 불필요. 바로 사용.
    final int intServiceId = serviceId;

    try {
      // 로딩 인디케이터 (선택적)
      // if (context.mounted) showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator()));

      final PhotoService? loadedPhotoService = await ref
          .read(photoServiceProvider.notifier)
          .loadServiceDetail(intServiceId); // intServiceId 직접 사용
      
      // if (context.mounted) Navigator.of(context).pop(); // 로딩 인디케이터 닫기

      if (loadedPhotoService != null && context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PhotoServiceDetailPage(service: loadedPhotoService),
          ),
        );
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("해당 서비스 정보를 찾을 수 없습니다.")),
        );
      }
    } catch (e) {
      // if (context.mounted) Navigator.of(context).pop(); // 로딩 인디케이터 닫기
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("상세 페이지 이동 중 오류 발생: $e")),
        );
      }
    }
  }

  /// 내 리뷰 보기 (서비스 상세 페이지로 이동)
  void _viewMyReview(BuildContext context, WidgetRef ref) {
    _navigateToServiceDetail(context, ref);
  }

  /// 작성된 리뷰 확인 (서비스 상세 페이지로 이동)
  void _viewReview(BuildContext context, WidgetRef ref) {
    _navigateToServiceDetail(context, ref);
  }
}
