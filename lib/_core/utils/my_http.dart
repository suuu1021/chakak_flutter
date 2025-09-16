import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../constants/api_config.dart';

final dio = Dio(
  BaseOptions(
    baseUrl: ApiConfig.baseUrl,
    contentType: "application/json; charset=utf-8",
    validateStatus: (status) => true,
  ),
);

const secureStorage = FlutterSecureStorage();
