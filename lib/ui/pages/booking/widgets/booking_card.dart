// features/booking/presentation/ui/widgets/booking_card.dart

import 'package:flutter/material.dart';

import '../../../../data/models/booking/booking_model.dart';
import 'booking_status_chip.dart';

/// 예약 카드 위젯
class BookingCard extends StatelessWidget {
  final BookingListItem booking;
  final VoidCallback? onTap;
  final VoidCallback? onCancel;

  const BookingCard({
    super.key,
    required this.booking,
    this.onTap,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 12),
              _buildDateTimeInfo(),
              if (onCancel != null) ...[
                const SizedBox(height: 12),
                _buildActionButtons(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// 헤더 영역 (포토그래퍼명 + 상태)
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            booking.photographerName,
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

  /// 날짜/시간 정보 영역
  Widget _buildDateTimeInfo() {
    return Column(
      children: [
        Row(
          children: [
            const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
            const SizedBox(width: 8),
            Text(
              booking.formattedDate,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            const Icon(Icons.access_time, size: 16, color: Colors.grey),
            const SizedBox(width: 8),
            Text(
              booking.formattedTime,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 액션 버튼 영역
  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: onCancel,
          style: TextButton.styleFrom(
            foregroundColor: Colors.red,
          ),
          child: const Text('취소하기'),
        ),
      ],
    );
  }
}
