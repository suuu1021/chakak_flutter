// features/booking/presentation/ui/widgets/booking_card.dart

import 'package:chakak_flutter/_core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../data/models/booking/booking_list_item.dart';
import '../../../../data/models/booking/booking_model.dart';
import '../../../../provider/auth/session_provider.dart';
import '../../../../provider/global/booking/booking_list_notifier.dart';
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
            color: Colors.black.withOpacity(0.04),
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
              // 상단: 상대방명 + 상태칩
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  BookingStatusChip(status: booking.status),
                  // 액션 버튼
                  _buildActionButtons(context, ref, userType),
                ],
              ),

              const SizedBox(height: 12),

              // 서비스 정보
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
                        booking.otherPartyName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
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

  /// 헤더 영역
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            booking.otherPartyName,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        BookingStatusChip(status: booking.status),
      ],
    );
  }

  /// 서비스 정보 영역 (서비스명, 가격)
  Widget _buildServiceInfo() {
    // 통화 형식 수정 - 원화 기호를 직접 사용
    final currencyFormat = NumberFormat.currency(locale: 'ko_KR', symbol: '₩');
    final service = booking.photoService;

    // service가 null일 경우 빈 위젯 반환
    if (service == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.photo_camera_outlined,
                  size: 16, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  service.title,
                  style: TextStyle(
                      color: Colors.grey[800], fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.paid_outlined, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(
                currencyFormat.format(service.price),
                style: TextStyle(
                    color: Colors.grey[800], fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 액션 버튼 영역 (사용자 타입별 분기)
  Widget _buildActionButtons(
      BuildContext context, WidgetRef ref, String? userType) {
    if (userType == "user") {
      return _buildUserButtons(context, ref);
    } else if (userType == "photographer") {
      return _buildPhotographerButtons(context, ref);
    }
    return const SizedBox.shrink();
  }

  /// 사용자 버튼들
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
          onPressed: () => _viewMyReview(context),
        );
      case BookingStatus.CANCELED:
        return _buildActionChip(text: '취소된 예약', color: AppColors.error);
      default:
        return const SizedBox.shrink();
    }
  }

  /// 포토그래퍼 버튼들
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
          onPressed: () => _viewReview(context),
        );
      case BookingStatus.CANCELED:
        return _buildActionChip(text: '취소된 예약', color: AppColors.error);
      default:
        return const SizedBox.shrink();
    }
  }

  /// 통합 액션 칩 위젯
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
                // 클릭 가능하면 진한 배경, 아니면 연한 배경
                color: isClickable ? color : color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8), // 상태칩보다 덜 둥글게
                border: Border.all(
                  color: isClickable ? color : color.withOpacity(0.3),
                ),
                // 클릭 가능하면 미세한 그림자
                boxShadow: isClickable
                    ? [
                        BoxShadow(
                          color: color.withOpacity(0.6),
                          blurRadius: 4,
                          offset: const Offset(1, 2),
                        ),
                      ]
                    : null,
              ),
              child: Text(
                text,
                style: TextStyle(
                  // 클릭 가능하면 흰색, 아니면 원래 색상
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

  /// 예약 취소 다이얼로그 표시
  void _showCancelDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => BookingCancelDialog(booking: booking),
    );
  }

  /// 예약 확정 처리 (포토그래퍼만 가능)
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

  /// 촬영 완료 처리
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

  /// 리뷰 작성
  void _writeReview(BuildContext context, WidgetRef ref) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReviewFormScreen(booking: booking),
      ),
    );
  }

  /// 내 리뷰 보기 (TODO: 리뷰 상세 화면으로 이동)
  void _viewMyReview(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('리뷰 보기 기능은 준비 중입니다')),
    );
  }

  /// 작성된 리뷰 확인 (TODO: 리뷰 상세 화면으로 이동)
  void _viewReview(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('리뷰 확인 기능은 준비 중입니다')),
    );
  }
}
