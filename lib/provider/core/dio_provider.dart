import 'package:chakak_flutter/_core/constants/api_config.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth/session_provider.dart';

const String apiBaseUrl = "http://10.0.2.2:8080";

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: const Duration(seconds: 10), // 연결 타임아웃
      receiveTimeout: const Duration(seconds: 10), // 응답 타임아웃
    ),
  );

  // QueuedInterceptorsWrapper를 사용하여 요청/응답/에러를 비동기적으로 처리
  dio.interceptors.add(
    QueuedInterceptorsWrapper(
      // 1. 요청을 보내기 전 (Request)
      onRequest: (options, handler) async {
        // 요청이 발생할 때마다 항상 최신 SessionProvider 상태를 읽어옴
        final session = ref.read(sessionProvider);

        // 디버그 로그 추가
        print('[DIO] 세션 상태 확인:');
        print('[DIO] - isLogin: ${session.isLogin}');
        print('[DIO] - jwtToken 존재: ${session.jwtToken != null}');
        if (session.jwtToken != null) {
          print('[DIO] - 토큰 앞부분: ${session.jwtToken!.substring(0, 20)}...');
        }

        // 로그인 상태이고, 토큰이 존재한다면 헤더에 추가
        if (session.isLogin && session.jwtToken != null) {
          options.headers['Authorization'] = 'Bearer ${session.jwtToken}';
          print('[DIO] Authorization 헤더 추가 완료');
        } else {
          print('[DIO] 토큰이 없어서 Authorization 헤더 추가하지 않음');
        }

        if (kDebugMode) {
          print('[REQ] [${options.method}] ${options.uri}'); // API 요청 로그
        }
        // 요청 데이터가 있다면 함께 로그를 남김
        if (kDebugMode && options.data != null) {
          print('[REQ-DATA] ${options.data}');
        }
        return handler.next(options); // 요청을 계속 진행
      },

      // 2. 응답을 받은 후 (Response)
      onResponse: (response, handler) {
        if (kDebugMode) {
          print(
              '[RES] [${response.requestOptions.method}] ${response.requestOptions.uri}] ${response.statusCode}');
          print('[RES-DATA] ${response.data}');
        }
        return handler.next(response); // 응답을 계속 진행
      },

      // 3. 에러가 발생했을 때 (Error)
      onError: (DioException e, handler) async {
        if (kDebugMode) {
          print(
              '[ERR] [${e.requestOptions.method}] ${e.requestOptions.uri}] ${e.message}');
        }

        if (e.response?.statusCode == 401) {
          // SessionProvider를 통해 강제로 로그아웃 처리
          // 화면 전환 등 UI와 관련된 작업이므로, microtask로 안전하게 실행
          Future.microtask(() {
            ref.read(sessionProvider.notifier).logout();
          });

          // 여기서 에러를 중단시켜, 각 호출부에서는 로그인 화면으로 이동 등의 후속 처리
          return handler.next(e);
        }
        return handler.next(e); // 다른 에러는 그대로 진행
      },
    ),
  );

  return dio;
});
