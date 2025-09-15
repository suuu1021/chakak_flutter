// features/booking/presentation/ui/user_booking_list_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/booking_model.dart';
import '../../../provider/global/booking/booking_list_notifier.dart';
import 'widgets/booking_cancel_dialog.dart';
import 'widgets/booking_card.dart';
import 'widgets/booking_filter_dialog.dart';
import 'widgets/booking_empty_widget.dart';
import 'widgets/booking_error_widget.dart';

class UserBookingListPage extends ConsumerWidget {
  const UserBookingListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserId = ref.watch(currentUserIdProvider);
    final bookingState = ref.watch(userBookingListProvider(currentUserId));

    return Scaffold(
      appBar: _buildAppBar(context, ref, currentUserId),
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(userBookingListProvider(currentUserId).notifier).refresh(),
        child: _buildBody(context, ref, bookingState, currentUserId),
      ),
    );
  }

  /// AppBar 구성
  PreferredSizeWidget _buildAppBar(
      BuildContext context, WidgetRef ref, int userId) {
    return AppBar(
      title: const Text('내 예약'),
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 0,
      actions: [
        IconButton(
          onPressed: () => _showFilterDialog(context, ref, userId),
          icon: const Icon(Icons.filter_list),
        ),
      ],
    );
  }

  /// Body 구성
  Widget _buildBody(
      BuildContext context, WidgetRef ref, BookingListState state, int userId) {
    // 로딩 상태 (초기 로딩만)
    if (state.isLoading && state.bookings.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    // 에러 상태
    if (state.errorMessage != null) {
      return BookingErrorWidget(
        error: state.errorMessage!,
        onRetry: () =>
            ref.read(userBookingListProvider(userId).notifier).refresh(),
      );
    }

    final filteredBookings = state.filteredBookings;

    // 빈 목록 상태
    if (filteredBookings.isEmpty) {
      return BookingEmptyWidget(selectedFilter: state.selectedFilter);
    }

    // 목록 표시
    return Column(
      children: [
        if (state.selectedFilter != null) _buildFilterChip(ref, state, userId),
        Expanded(
          child: _buildBookingList(context, ref, filteredBookings, userId),
        ),
      ],
    );
  }

  /// 선택된 필터 칩 표시
  Widget _buildFilterChip(WidgetRef ref, BookingListState state, int userId) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Chip(
            label: Text(state.selectedFilter!.description),
            deleteIcon: const Icon(Icons.close, size: 18),
            onDeleted: () => ref
                .read(userBookingListProvider(userId).notifier)
                .clearFilter(),
          ),
        ],
      ),
    );
  }

  /// 예약 목록 구성
  Widget _buildBookingList(
    BuildContext context,
    WidgetRef ref,
    List<BookingListItem> bookings,
    int userId,
  ) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: bookings.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final booking = bookings[index];
        return BookingCard(
          booking: booking,
          onTap: () => _navigateToDetail(context, booking),
          onCancel: booking.status == BookingStatus.pending
              ? () => _handleCancelBooking(context, ref, booking, userId)
              : null,
        );
      },
    );
  }

  /// 필터 다이얼로그 표시
  void _showFilterDialog(BuildContext context, WidgetRef ref, int userId) {
    showDialog(
      context: context,
      builder: (context) => BookingFilterDialog(
        onFilterSelected: (filter) {
          if (filter == null) {
            ref.read(userBookingListProvider(userId).notifier).clearFilter();
          } else {
            ref
                .read(userBookingListProvider(userId).notifier)
                .setFilter(filter);
          }
          Navigator.of(context).pop();
        },
      ),
    );
  }

  /// 예약 상세 화면으로 이동
  void _navigateToDetail(BuildContext context, BookingListItem booking) {
    // TODO: 예약 상세 화면으로 이동
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${booking.photographerName} 예약 상세 (개발 예정)'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// 예약 취소 처리
  void _handleCancelBooking(BuildContext context, WidgetRef ref,
      BookingListItem booking, int userId) {
    showDialog(
      context: context,
      builder: (context) => BookingCancelDialog(
        booking: booking,
        onConfirm: () async {
          try {
            // TODO: bookingInfoId가 현재 DTO에 없어서 임시 처리
            // 실제로는 booking.bookingInfoId를 사용해야 함
            // await ref.read(userBookingListProvider(userId).notifier)
            //     .cancelBooking(booking.bookingInfoId);

            // 임시: 성공 메시지 표시
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${booking.photographerName}님과의 예약이 취소되었습니다'),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }

            // TODO: bookingInfoId 구현 후 주석 해제
            // 목록 새로고침
            // ref.read(userBookingListProvider(userId).notifier).refresh();
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('예약 취소 중 오류가 발생했습니다: $e'),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          }
        },
      ),
    );
  }
}
