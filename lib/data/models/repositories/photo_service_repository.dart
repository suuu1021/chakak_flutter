import 'dart:io';

import 'package:chakak_flutter/data/dtos/photo_service_dto.dart';
import 'package:dio/dio.dart';

import '../../../_core/constants/api_config.dart';
import '../photo_service/photo_service.dart';

abstract class PhotoServiceRepository {
  Future<List<PhotoService>> getServices();
  Future<List<PhotoService>> getServicesByPhotographer(int photographerId);
  Future<void> updateLikeStatus(int serviceId, bool isLiked);
}

class PhotoServiceRepositoryImpl implements PhotoServiceRepository {
  final Dio _dio = Dio();

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
  Future<List<PhotoService>> getServices() async {
    final String apiUrl = '$serverUrl/api/photo/services/list?size=30'; //
    try {
      final response = await _dio.get(apiUrl);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = response.data;

        if (responseData.containsKey('body') && responseData['body'] is List) {
          final List<dynamic> serviceListFromResponse =
              responseData['body'] as List<dynamic>;

          // print('=== PhotoService API 응답 디버깅 ===');
          print('총 서비스 개수: ${serviceListFromResponse.length}');

          if (serviceListFromResponse.isNotEmpty) {
            // print('첫 번째 서비스 데이터:');
            print(serviceListFromResponse[0]);
          }
          // print('===================================');

          final List<PhotoService> services = serviceListFromResponse
              .map((item) {
                if (item is Map<String, dynamic>) {
                  // print('=== PhotoService Item 디버깅 ===');
                  // print('Item JSON: $item');

                  // photographerId 관련 필드들 체크
                  // print('photographerId: ${item['photographerId']}');
                  // print('userId: ${item['userId']}');
                  // print('ownerId: ${item['ownerId']}');
                  // print('user: ${item['user']}');
                  // print('photographer: ${item['photographer']}');
                  // print('createdBy: ${item['createdBy']}');
                  // print('============================');

                  final dto = PhotoServiceDto.fromJson(item);
                  final service = dto.toModel();

                  // print('=== 최종 PhotoService ===');
                  print('service.photographerId: ${service.photographerId}');
                  // print('========================');

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
          final List<PhotoService> services = serviceListFromResponse
              .map((item) {
                if (item is Map<String, dynamic>) {
                  final dto = PhotoServiceDto.fromJson(item);
                  return dto.toModel();
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
