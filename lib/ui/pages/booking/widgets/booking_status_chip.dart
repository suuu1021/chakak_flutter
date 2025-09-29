import 'package:flutter/material.dart';
import 'package:chakak_flutter/_core/constants/app_colors.dart';
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: chipData.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
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
      case BookingStatus.PENDING:
        return _ChipData(
          text: status.description,
          color: AppColors.warning,
        );
      case BookingStatus.CONFIRMED:
        return _ChipData(
          text: status.description,
          color: AppColors.success,
        );
      case BookingStatus.CANCELED:
        return _ChipData(
          text: status.description,
          color: AppColors.error,
        );
      case BookingStatus.COMPLETED:
        return _ChipData(
          text: status.description,
          color: AppColors.info,
        );
      case BookingStatus.REVIEWED:
        return _ChipData(
          text: status.description,
          color: AppColors.secondary,
        );
      default:
        return _ChipData(
          text: status.description,
          color: AppColors.gray500,
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
