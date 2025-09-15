import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart'; // HTTP 클라이언트 사용 시

class ErrorHandler {
  /// 에러를 처리하고 사용자에게 표시
  static void handleError(
    BuildContext context, 
    dynamic error, {
    String? customMessage,
    bool showSnackBar = true,
  }) {
    // 개발 환경에서 로깅
    _logError(error);
    
    if (showSnackBar) {
      final errorInfo = _getErrorInfo(error, customMessage);
      _showErrorSnackBar(context, errorInfo);
    }
  }

  /// 개발용 로깅
  static void _logError(dynamic error) {
    print('Error occurred: $error');
    if (error is DioException) {
      print('Response: ${error.response?.data}');
      print('Status Code: ${error.response?.statusCode}');
    }
    // TODO: 프로덕션에서는 Firebase Crashlytics 등에 전송
  }

  /// 에러 정보 추출
  static _ErrorInfo _getErrorInfo(dynamic error, String? customMessage) {
    if (customMessage != null) {
      return _ErrorInfo(customMessage, Colors.red, Icons.error_outline);
    }

    // HTTP 에러 처리 (Dio 사용 시)
    if (error is DioException) {
      return _getHttpErrorInfo(error);
    }

    // 네트워크 에러
    if (error is SocketException) {
      return const _ErrorInfo(
        '인터넷 연결을 확인해주세요',
        Colors.blueGrey,
        Icons.wifi_off,
      );
    }

    // 타임아웃 에러
    if (error is TimeoutException) {
      return const _ErrorInfo(
        '서버 응답 시간이 초과되었습니다',
        Colors.deepOrange,
        Icons.timer_off_outlined,
      );
    }

    // 문자열 기반 HTTP 에러 체크 (백업)
    final errorString = error.toString().toLowerCase();
    if (errorString.contains('400')) {
      return _ErrorInfo(
        '잘못된 요청입니다. 입력값을 확인해주세요',
        Colors.grey[700]!,
        Icons.error,
      );
    }
    if (errorString.contains('401')) {
      return const _ErrorInfo(
        '인증되지 않은 사용자입니다. 로그인이 필요합니다',
        Colors.blue,
        Icons.lock_open,
      );
    }
    if (errorString.contains('403')) {
      return const _ErrorInfo(
        '접근 권한이 없습니다',
        Colors.orange,
        Icons.block,
      );
    }
    if (errorString.contains('404')) {
      return const _ErrorInfo(
        '요청한 데이터를 찾을 수 없습니다',
        Colors.brown,
        Icons.search_off,
      );
    }
    if (errorString.contains('500')) {
      return const _ErrorInfo(
        '서버에 문제가 발생했습니다. 잠시 후 다시 시도해 주세요',
        Colors.purple,
        Icons.cloud_off,
      );
    }

    // 기본 에러
    return _ErrorInfo(
      '알 수 없는 에러가 발생했습니다',
      Colors.red,
      Icons.error_outline,
    );
  }

  /// HTTP 에러 정보 추출 (Dio 기반)
  static _ErrorInfo _getHttpErrorInfo(DioException error) {
    switch (error.response?.statusCode) {
      case 400:
        return _ErrorInfo(
          '잘못된 요청입니다. 입력값을 확인해주세요',
          Colors.grey[700]!,
          Icons.error,
        );
      case 401:
        return const _ErrorInfo(
          '인증되지 않은 사용자입니다. 로그인이 필요합니다',
          Colors.blue,
          Icons.lock_open,
        );
      case 403:
        return const _ErrorInfo(
          '접근 권한이 없습니다',
          Colors.orange,
          Icons.block,
        );
      case 404:
        return const _ErrorInfo(
          '요청한 데이터를 찾을 수 없습니다',
          Colors.brown,
          Icons.search_off,
        );
      case 422:
        return const _ErrorInfo(
          '입력 데이터에 문제가 있습니다',
          Colors.amber,
          Icons.warning,
        );
      case 429:
        return const _ErrorInfo(
          '요청이 너무 많습니다. 잠시 후 다시 시도해주세요',
          Colors.indigo,
          Icons.hourglass_empty,
        );
      case 500:
      case 502:
      case 503:
        return const _ErrorInfo(
          '서버에 문제가 발생했습니다. 잠시 후 다시 시도해 주세요',
          Colors.purple,
          Icons.cloud_off,
        );
      default:
        return _ErrorInfo(
          '네트워크 오류가 발생했습니다 (${error.response?.statusCode})',
          Colors.red,
          Icons.error_outline,
        );
    }
  }

  /// 스낵바 표시
  static void _showErrorSnackBar(BuildContext context, _ErrorInfo errorInfo) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(errorInfo.icon, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(errorInfo.message)),
          ],
        ),
        backgroundColor: errorInfo.color,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: '확인',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  /// 성공 메시지 표시
  static void showSuccess(BuildContext context, String message) {
    _showErrorSnackBar(
      context,
      _ErrorInfo(message, Colors.green, Icons.check_circle_outline),
    );
  }

  /// 경고 메시지 표시
  static void showWarning(BuildContext context, String message) {
    _showErrorSnackBar(
      context,
      _ErrorInfo(message, Colors.orange, Icons.warning_amber_outlined),
    );
  }
}

/// 에러 정보 클래스
class _ErrorInfo {
  final String message;
  final Color color;
  final IconData icon;

  const _ErrorInfo(this.message, this.color, this.icon);
}
