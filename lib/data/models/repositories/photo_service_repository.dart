import 'dart:io';
import 'package:chakak_flutter/data/dtos/photo_service_dto.dart';
import 'package:chakak_flutter/data/models/photo_service/price_option.dart';
import 'package:dio/dio.dart';
import '../../../_core/constants/api_config.dart';
import '../photo_service/photo_service.dart';

abstract class PhotoServiceRepository {
  Future<List<PhotoService>> getServices();
  Future<List<PhotoService>> getServicesByPhotographer(int photographerId);
  Future<int?> getPhotographerIdByUserId(int userId);
  Future<void> updateLikeStatus(int serviceId, bool isLiked);
}

class PhotoServiceRepositoryImpl implements PhotoServiceRepository {
  final Dio _dio;
  PhotoServiceRepositoryImpl(this._dio);

  String get serverUrl {
    if (Platform.isAndroid) {
      return ApiConfig.baseUrl;
    } else if (Platform.isIOS) {
      return ApiConfig.baseUrl;
    } else {
      return ApiConfig.baseUrl;
    }
  }

  @override
  Future<int?> getPhotographerIdByUserId(int userId) async {
    final String apiUrl = '$serverUrl/api/photographers/profile/user/$userId';
    try {
      final response = await _dio.get(apiUrl);

      if (response.statusCode == 200) {
        final data = response.data;

        // ApiUtil 래퍼 구조 처리
        if (data is Map<String, dynamic> && data.containsKey('body')) {
          return data['body']['photographerProfileId'] as int?;
        }

        // 직접 응답인 경우
        return data['photographerProfileId'] as int?;
      }
      return null;
    } catch (e) {
      print('Error getting photographer ID by userId: $e');
      return null;
    }
  }

  @override
  Future<List<PhotoService>> getServices() async {
    final String apiUrl = '$serverUrl/api/photo/services/list?size=30';
    try {
      final response = await _dio.get(apiUrl);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = response.data;

        if (responseData.containsKey('body') && responseData['body'] is List) {
          final List<dynamic> serviceListFromResponse =
              responseData['body'] as List<dynamic>;

          print('총 서비스 개수: ${serviceListFromResponse.length}');

          if (serviceListFromResponse.isNotEmpty) {
            print(serviceListFromResponse[0]);
          }

          final List<PhotoService> services = serviceListFromResponse
              .map((item) {
                if (item is Map<String, dynamic>) {
                  // PhotoServiceDto를 사용하여 올바르게 파싱
                  final dto = PhotoServiceDto.fromJson(item);
                  final service = dto.toModel();
                  print('service.photographerId: ${service.photographerId}');
                  print(
                      'service.photographerUserId: ${service.photographerUserId}');
                  return service;
                } else {
                  print('Invalid item format in service list: $item');
                  return null;
                }
              })
              .where((service) => service != null)
              .cast<PhotoService>()
              .toList();
          return services;
        } else {
          print(
              'Error: Response "body" is not a list or "body" key is missing. URL: $apiUrl, Response: $responseData');
          return [];
        }
      } else {
        print('Error fetching services: ${response.statusCode}, URL: $apiUrl');
        return [];
      }
    } on DioException catch (e) {
      print('DioError fetching services: ${e.message}, URL: $apiUrl');
      return [];
    } catch (e) {
      print('Unexpected error fetching services: $e, URL: $apiUrl');
      return [];
    }
  }

  @override
  Future<List<PhotoService>> getServicesByPhotographer(
      int photographerId) async {
    final String apiUrl =
        '$serverUrl/api/photo/services/photographer/$photographerId';
    try {
      final response = await _dio.get(apiUrl);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = response.data;
        if (responseData.containsKey('body') && responseData['body'] is List) {
          final List<dynamic> serviceListFromResponse =
              responseData['body'] as List<dynamic>;

          print('[PhotoServiceRepository] 서버 응답 데이터:');
          for (int i = 0; i < serviceListFromResponse.length; i++) {
            print('서비스 $i: ${serviceListFromResponse[i]}');
          }

          final List<PhotoService> services = serviceListFromResponse
              .map((item) {
                if (item is Map<String, dynamic>) {
                  // PhotoServiceDto를 사용하여 올바르게 파싱
                  final dto = PhotoServiceDto.fromJson(item);
                  final service = dto.toModel();

                  print('[PhotoServiceRepository] 변환된 서비스:');
                  print('  서비스 ID: ${service.id}');
                  print('  포토그래퍼 프로필 ID: ${service.photographerId}');
                  print('  포토그래퍼 사용자 ID: ${service.photographerUserId}');
                  print('  가격 옵션 개수: ${service.priceOptions.length}');

                  return service;
                } else {
                  print(
                      'Invalid item format in photographer service list: $item');
                  return null;
                }
              })
              .where((service) => service != null)
              .cast<PhotoService>()
              .toList();

          return services;
        } else {
          print(
              'Error: Response "body" is not a list or "body" key is missing for photographer services. URL: $apiUrl, Response: $responseData');
          return [];
        }
      } else {
        print(
            'Error fetching services by photographer: ${response.statusCode}, URL: $apiUrl');
        return [];
      }
    } on DioException catch (e) {
      print(
          'DioError fetching services by photographer: ${e.message}, URL: $apiUrl');
      return [];
    } catch (e) {
      print(
          'Unexpected error fetching services by photographer: $e, URL: $apiUrl');
      return [];
    }
  }

  @override
  Future<void> updateLikeStatus(int serviceId, bool isLiked) async {
    final String apiUrl = '$serverUrl/api/photo/services/$serviceId/like';
    try {
      final response = await _dio.patch(
        apiUrl,
        data: {'isLiked': isLiked},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update like status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('DioError updating like status: ${e.message}, URL: $apiUrl');
      throw Exception('Failed to update like status: ${e.message}');
    } catch (e) {
      print('Unexpected error updating like status: $e, URL: $apiUrl');
      throw Exception('Failed to update like status: $e');
    }
  }
}
