// features/booking/presentation/ui/widgets/booking_filter_dialog.dart

import 'package:flutter/material.dart';
import '../../../../data/models/booking_model.dart';

/// 예약 필터 다이얼로그 위젯
class BookingFilterDialog extends StatelessWidget {
  final void Function(BookingStatus?) onFilterSelected;

  const BookingFilterDialog({
    super.key,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('상태 필터'),
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildAllFilterTile(),
          const Divider(height: 1),
          ..._buildStatusFilterTiles(),
        ],
      ),
    );
  }

  /// '전체' 필터 타일
  Widget _buildAllFilterTile() {
    return ListTile(
      leading: const Icon(
        Icons.list_alt,
        color: Colors.blue,
      ),
      title: const Text(
        '전체',
        style: TextStyle(fontWeight: FontWeight.w500),
      ),
      onTap: () => onFilterSelected(null),
    );
  }

  /// 상태별 필터 타일들
  List<Widget> _buildStatusFilterTiles() {
    return BookingStatus.values.map((status) {
      return ListTile(
        leading: Icon(
          _getStatusIcon(status),
          color: _getStatusColor(status),
        ),
        title: Text(status.description),
        onTap: () => onFilterSelected(status),
      );
    }).toList();
  }

  /// 상태별 아이콘 반환
  IconData _getStatusIcon(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return Icons.schedule;
      case BookingStatus.confirmed:
        return Icons.check_circle;
      case BookingStatus.rejected:
        return Icons.cancel;
      case BookingStatus.canceled:
        return Icons.block;
      case BookingStatus.completed:
        return Icons.camera_alt;
      case BookingStatus.reviewed:
        return Icons.star;
    }
  }

  /// 상태별 색상 반환
  Color _getStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return const Color(0xFFFF9800); // 주황색
      case BookingStatus.confirmed:
        return const Color(0xFF4CAF50); // 초록색
      case BookingStatus.rejected:
      case BookingStatus.canceled:
        return const Color(0xFFF44336); // 빨간색
      case BookingStatus.completed:
        return const Color(0xFF2196F3); // 파란색
      case BookingStatus.reviewed:
        return const Color(0xFF9C27B0); // 보라색
    }
  }
}
