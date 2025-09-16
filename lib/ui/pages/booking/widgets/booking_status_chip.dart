// features/booking/presentation/ui/widgets/booking_status_chip.dart

import 'package:flutter/material.dart';
import '../../../../data/models/booking/booking_model.dart';

/// 예약 상태 칩 위젯
class BookingStatusChip extends StatelessWidget {
  final BookingStatus status;

  const BookingStatusChip({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final chipData = _getChipData(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipData.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: chipData.color.withOpacity(0.3)),
      ),
      child: Text(
        chipData.text,
        style: TextStyle(
          color: chipData.color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// 상태별 칩 데이터 반환
  _ChipData _getChipData(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return _ChipData(
          text: status.description,
          color: const Color(0xFFFF9800), // 주황색
        );
      case BookingStatus.confirmed:
        return _ChipData(
          text: status.description,
          color: const Color(0xFF4CAF50), // 초록색
        );
      case BookingStatus.rejected:
      case BookingStatus.canceled:
        return _ChipData(
          text: status.description,
          color: const Color(0xFFF44336), // 빨간색
        );
      case BookingStatus.completed:
        return _ChipData(
          text: status.description,
          color: const Color(0xFF2196F3), // 파란색
        );
      case BookingStatus.reviewed:
        return _ChipData(
          text: status.description,
          color: const Color(0xFF9C27B0), // 보라색
        );
    }
  }
}

/// 칩 데이터 클래스
class _ChipData {
  final String text;
  final Color color;

  const _ChipData({
    required this.text,
    required this.color,
  });
}
