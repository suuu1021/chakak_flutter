import 'dart:io';

class ApiConfig {
  static String get baseUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8080'; // 에뮬레이터
      // return 'http://192.168.0.82:8080'; // 팀장 IP
      // return 'http://192.168.0.132:8080'; // 강사님 IP
    } else if (Platform.isIOS) {
      return 'http://localhost:8080'; // iOS 시뮬레이터
    }
    return 'http://localhost:8080';
  }
}
