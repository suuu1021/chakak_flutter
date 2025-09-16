import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/session_provider.dart';

// TODO: 앱 전체에서 사용할 API 서버의 기본 주소로 변경하세요.
const String apiBaseUrl = "http://10.0.2.2:8080";

// Dio 인스턴스를 제공하는 Provider
// Provider가 생성될 때 Ref를 저장해두고, 인터셉터에서 사용합니다.
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: apiBaseUrl,
      connectTimeout: const Duration(seconds: 10), // 연결 타임아웃
      receiveTimeout: const Duration(seconds: 10), // 응답 타임아웃
    ),
  );

  // QueuedInterceptorsWrapper를 사용하여 요청/응답/에러를 비동기적으로 처리합니다.
  // 이렇게 하면 인터셉터 내에서 다른 Provider의 최신 상태를 안전하게 읽어올 수 있습니다.
  dio.interceptors.add(
    QueuedInterceptorsWrapper(
      // 1. 요청을 보내기 전 (Request)
      onRequest: (options, handler) async {
        // 요청이 발생할 때마다 항상 최신 SessionProvider 상태를 읽어옵니다.
        final session = ref.read(sessionProvider);

        // 로그인 상태이고, 토큰이 존재한다면 헤더에 추가합니다.
        if (session.isLogin && session.jwtToken != null) {
          options.headers['Authorization'] = 'Bearer ${session.jwtToken}';
        }

        if (kDebugMode) {
          print('[REQ] [${options.method}] ${options.uri}'); // API 요청 로그
        }
        // 요청 데이터가 있다면 함께 로그를 남깁니다.
        if (kDebugMode && options.data != null) {
          print('[REQ-DATA] ${options.data}');
        }
        return handler.next(options); // 요청을 계속 진행합니다.
      },

      // 2. 응답을 받은 후 (Response)
      onResponse: (response, handler) {
        if (kDebugMode) {
          print(
              '[RES] [${response.requestOptions.method}] ${response.requestOptions.uri}] ${response.statusCode}'); // API 응답 로그
          // 서버에서 받은 원본 데이터를 그대로 출력합니다.
          print('[RES-DATA] ${response.data}');
        }
        return handler.next(response); // 응답을 계속 진행합니다.
      },

      // 3. 에러가 발생했을 때 (Error)
      onError: (DioException e, handler) async {
        if (kDebugMode) {
          print(
              '[ERR] [${e.requestOptions.method}] ${e.requestOptions.uri}] ${e.message}'); // API 에러 로그
        }

        // 401 Unauthorized 에러(토큰 만료 등)가 발생했을 때
        if (e.response?.statusCode == 401) {
          // SessionProvider를 통해 강제로 로그아웃 처리합니다.
          // 화면 전환 등 UI와 관련된 작업이므로, microtask로 안전하게 실행합니다.
          Future.microtask(() {
            ref.read(sessionProvider.notifier).logout();
          });

          // 여기서 에러를 중단시켜, 각 호출부에서는 로그인 화면으로 이동 등의 후속 처리를 할 수 있습니다.
          return handler.next(e);
        }

        return handler.next(e); // 다른 에러는 그대로 진행합니다.
      },
    ),
  );

  return dio;
});
