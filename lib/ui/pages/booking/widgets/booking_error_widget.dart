// features/booking/presentation/ui/widgets/booking_error_widget.dart

import 'package:flutter/material.dart';

/// 예약 에러 상태 위젯
class BookingErrorWidget extends StatelessWidget {
  final String error;
  final VoidCallback? onRetry;

  const BookingErrorWidget({
    super.key,
    required this.error,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final errorData = _getErrorData(error);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              errorData.icon,
              size: 64,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              errorData.title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.red[700],
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              errorData.subtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (onRetry != null)
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('다시 시도'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// 에러 타입별 데이터 반환
  _ErrorData _getErrorData(String error) {
    final lowerError = error.toLowerCase();

    // 네트워크 에러
    if (lowerError.contains('network') ||
        lowerError.contains('connection') ||
        lowerError.contains('네트워크')) {
      return const _ErrorData(
        icon: Icons.wifi_off,
        title: '네트워크 연결 오류',
        subtitle: '인터넷 연결을 확인하고 다시 시도해주세요',
      );
    }

    // 인증 에러
    if (lowerError.contains('auth') ||
        lowerError.contains('login') ||
        lowerError.contains('인증') ||
        lowerError.contains('로그인')) {
      return const _ErrorData(
        icon: Icons.lock_outline,
        title: '인증 오류',
        subtitle: '다시 로그인해주세요',
      );
    }

    // 권한 에러
    if (lowerError.contains('permission') ||
        lowerError.contains('forbidden') ||
        lowerError.contains('권한') ||
        lowerError.contains('접근')) {
      return const _ErrorData(
        icon: Icons.block,
        title: '접근 권한 없음',
        subtitle: '해당 데이터에 접근할 권한이 없습니다',
      );
    }

    // 서버 에러
    if (lowerError.contains('server') ||
        lowerError.contains('500') ||
        lowerError.contains('서버')) {
      return const _ErrorData(
        icon: Icons.dns,
        title: '서버 오류',
        subtitle: '잠시 후 다시 시도해주세요',
      );
    }

    // 데이터 없음
    if (lowerError.contains('not found') ||
        lowerError.contains('404') ||
        lowerError.contains('찾을 수 없습니다')) {
      return const _ErrorData(
        icon: Icons.search_off,
        title: '데이터를 찾을 수 없음',
        subtitle: '요청한 정보가 존재하지 않습니다',
      );
    }

    // 일반적인 에러
    return const _ErrorData(
      icon: Icons.error_outline,
      title: '오류가 발생했습니다',
      subtitle: '잠시 후 다시 시도해주세요',
    );
  }
}

/// 에러 데이터 클래스
class _ErrorData {
  final IconData icon;
  final String title;
  final String subtitle;

  const _ErrorData({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
}
