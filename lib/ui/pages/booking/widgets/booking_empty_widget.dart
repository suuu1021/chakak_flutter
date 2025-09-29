import 'package:flutter/material.dart';
import '../../../../data/models/booking/booking_model.dart';

/// 빈 예약 목록 위젯
class BookingEmptyWidget extends StatelessWidget {
  final BookingStatus? selectedFilter;

  const BookingEmptyWidget({
    super.key,
    this.selectedFilter,
  });

  @override
  Widget build(BuildContext context) {
    final emptyData = _getEmptyData();

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            emptyData.icon,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            emptyData.title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              emptyData.subtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[500],
                  ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  /// 빈 목록 데이터 반환
  _EmptyData _getEmptyData() {
    if (selectedFilter == null) {
      return const _EmptyData(
        icon: Icons.calendar_today,
        title: '아직 예약이 없습니다',
        subtitle: '포토그래퍼와의 첫 촬영을 예약해보세요!',
      );
    }

    switch (selectedFilter!) {
      case BookingStatus.PENDING:
        return const _EmptyData(
          icon: Icons.schedule,
          title: '대기중인 예약이 없습니다',
          subtitle: '새로운 예약을 진행해보세요',
        );
      case BookingStatus.CONFIRMED:
        return const _EmptyData(
          icon: Icons.check_circle_outline,
          title: '확정된 예약이 없습니다',
          subtitle: '결제 완료된 예약이 여기에 표시됩니다',
        );
      case BookingStatus.COMPLETED:
        return const _EmptyData(
          icon: Icons.camera_alt_outlined,
          title: '완료된 촬영이 없습니다',
          subtitle: '촬영이 완료되면 여기에서 확인할 수 있습니다',
        );
      case BookingStatus.REVIEWED:
        return const _EmptyData(
          icon: Icons.star_outline,
          title: '리뷰 완료한 촬영이 없습니다',
          subtitle: '촬영 후 리뷰를 작성하면 여기에 표시됩니다',
        );
      default:
        return const _EmptyData(
          icon: Icons.info_outline,
          title: '해당 상태의 예약이 없습니다',
          subtitle: '다른 상태의 예약을 확인해보세요',
        );
    }
  }
}

/// 빈 목록 데이터 클래스
class _EmptyData {
  final IconData icon;
  final String title;
  final String subtitle;

  const _EmptyData({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
}
