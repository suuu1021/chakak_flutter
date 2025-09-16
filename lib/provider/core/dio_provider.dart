import 'package:chakak_flutter/_core/constants/api_config.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/session_provider.dart';

// Dio 인스턴스를 제공하는 Provider
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: const Duration(seconds: 10), // 연결 타임아웃
      receiveTimeout: const Duration(seconds: 10), // 응답 타임아웃
    ),
  );

  // 인터셉터를 추가하여 모든 요청과 응답, 에러를 중간에 가로챕니다.
  dio.interceptors.add(
    InterceptorsWrapper(
      // 1. 요청을 보내기 전 (Request)
      onRequest: (options, handler) {
        // SessionProvider에서 현재 로그인 정보를 가져옵니다.
        final session = ref.read(sessionProvider);

        // 디버그 로그 추가
        print('[DIO] 세션 상태 확인:');
        print('[DIO] - isLogin: ${session.isLogin}');
        print('[DIO] - jwtToken 존재: ${session.jwtToken != null}');
        if (session.jwtToken != null) {
          print('[DIO] - 토큰 앞부분: ${session.jwtToken!.substring(0, 20)}...');
        }

        // 로그인 상태이고, 토큰이 존재한다면 헤더에 추가합니다.
        if (session.isLogin && session.jwtToken != null) {
          options.headers['Authorization'] = 'Bearer ${session.jwtToken}';
          print('[DIO] Authorization 헤더 추가 완료');
        } else {
          print('[DIO] 토큰이 없어서 Authorization 헤더 추가하지 않음');
        }

        print('[REQ] [${options.method}] ${options.uri}'); // API 요청 로그
        return handler.next(options); // 요청을 계속 진행합니다.
      },

      // 2. 응답을 받은 후 (Response)
      onResponse: (response, handler) {
        print(
            '[RES] [${response.requestOptions.method}] ${response.requestOptions.uri}] ${response.statusCode}'); // API 응답 로그
        return handler.next(response); // 응답을 계속 진행합니다.
      },

      // 3. 에러가 발생했을 때 (Error)
      onError: (DioException e, handler) async {
        print(
            '[ERR] [${e.requestOptions.method}] ${e.requestOptions.uri}] ${e.message}'); // API 에러 로그

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
