import 'dart:io';

import 'package:chakak_flutter/data/dtos/photo_service/photo_service_dto.dart';
import 'package:chakak_flutter/data/models/photo_service/price_option.dart';
import 'package:chakak_flutter/data/models/review.dart';
import 'package:dio/dio.dart';

import '../../../_core/constants/api_config.dart';
import '../photo_service/photo_service.dart';

abstract class PhotoServiceRepository {
  Future<List<PhotoService>> getServices();
  Future<List<PhotoService>> getServicesByPhotographer(int photographerId);
  Future<int?> getPhotographerIdByUserId(int userId);
  Future<void> updateLikeStatus(int serviceId, bool isLiked);
  Future<ReviewPage> fetchReviews(
      {required int serviceId, int page = 0, int size = 10});
  Future<void> updateService(int serviceId, Map<String, dynamic> serviceData);
  Future<void> createService(Map<String, dynamic> serviceData);
  Future<void> deleteService(int serviceId);
  Future<List<Map<String, dynamic>>> loadCategories();
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
  Future<ReviewPage> fetchReviews(
      {required int serviceId, int page = 0, int size = 10}) async {
    final String apiUrl =
        '$serverUrl/api/v1/photo-services/$serviceId/reviews?page=$page&size=$size';
    try {
      final response = await _dio.get(apiUrl);

      if (response.statusCode == 200) {
        return ReviewPage.fromJson(response.data['body']);
      } else {
        throw Exception('Failed to load reviews: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('DioError fetching reviews: ${e.message}, URL: $apiUrl');
      throw Exception('Failed to load reviews: ${e.message}');
    } catch (e) {
      print('Unexpected error fetching reviews: $e, URL: $apiUrl');
      throw Exception('Failed to load reviews: $e');
    }
  }

  @override
  Future<int?> getPhotographerIdByUserId(int userId) async {
    final String apiUrl = '$serverUrl/api/photographers/profile/user/$userId';
    try {
      final response = await _dio.get(apiUrl);

      if (response.statusCode == 200) {
        final data = response.data;

        if (data is Map<String, dynamic> && data.containsKey('body')) {
          return data['body']['photographerProfileId'] as int?;
        }

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
                  List<PriceOption> priceOptionsList = [];
                  if (item['priceInfoList'] != null) {
                    priceOptionsList = (item['priceInfoList'] as List)
                        .map((priceJson) => PriceOption.fromJson(
                            priceJson as Map<String, dynamic>))
                        .toList();
                  }
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

  @override
  Future<void> updateService(
      int serviceId, Map<String, dynamic> serviceData) async {
    print('=== Repository updateService 시작 ===');
    print('serviceId: $serviceId');
    print(
        '받은 데이터의 imageData 길이: ${serviceData['imageData']?.toString().length ?? 0}');

    final String apiUrl = '$serverUrl/api/photo/services/$serviceId';

    try {
      // 데이터 복사 및 최종 확인
      final requestData = Map<String, dynamic>.from(serviceData);
      print(
          '요청 직전 imageData 길이: ${requestData['imageData']?.toString().length ?? 0}');
      print(
          '요청 직전 imageData 미리보기: ${requestData['imageData']!.toString().length > 100 ? requestData['imageData'].toString().substring(0, 100) + "..." : requestData['imageData']}');

      final response = await _dio.patch(
        apiUrl,
        data: requestData,
        options: Options(
          headers: {'Content-Type': 'application/json'},
          sendTimeout: const Duration(minutes: 5), // 큰 데이터 전송을 위한 타임아웃 연장
          receiveTimeout: const Duration(minutes: 5),
        ),
      );

      print('=== Repository updateService 완료 ===');
      print('서버 응답: ${response.statusCode}');

      if (response.statusCode != 200) {
        throw Exception('Failed to update service: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('DioError updating service: ${e.message}');
      print('Error type: ${e.type}');
      if (e.response != null) {
        print('Response status: ${e.response?.statusCode}');
        print('Response data: ${e.response?.data}');
      }
      throw Exception('Failed to update service: ${e.message}');
    } catch (e) {
      print('Unexpected error updating service: $e');
      throw Exception('Failed to update service: $e');
    }
  }

  @override
  Future<void> createService(Map<String, dynamic> serviceData) async {
    print('=== Repository createService 시작 ===');
    print(
        '받은 데이터의 imageData 길이: ${serviceData['imageData']?.toString().length ?? 0}');

    final String apiUrl = '$serverUrl/api/photo/services';

    try {
      final response = await _dio.post(
        apiUrl,
        data: serviceData,
        options: Options(
          headers: {'Content-Type': 'application/json'},
          sendTimeout: const Duration(minutes: 5),
          receiveTimeout: const Duration(minutes: 5),
        ),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to create service: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('DioError creating service: ${e.message}');
      throw Exception('Failed to create service: ${e.message}');
    } catch (e) {
      print('Unexpected error creating service: $e');
      throw Exception('Failed to create service: $e');
    }
  }

  @override
  Future<void> deleteService(int serviceId) async {
    final String apiUrl = '$serverUrl/api/photo/services/$serviceId';

    try {
      final response = await _dio.delete(apiUrl);

      if (response.statusCode != 200) {
        throw Exception('Failed to delete service: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('DioError deleting service: ${e.message}');
      throw Exception('Failed to delete service: ${e.message}');
    } catch (e) {
      print('Unexpected error deleting service: $e');
      throw Exception('Failed to delete service: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> loadCategories() async {
    final String apiUrl = '$serverUrl/api/photo/categories/list';

    try {
      final response = await _dio.get(apiUrl);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = response.data;
        if (responseData.containsKey('body') && responseData['body'] is List) {
          return List<Map<String, dynamic>>.from(responseData['body']);
        }
      }

      throw Exception('Failed to load categories: ${response.statusCode}');
    } on DioException catch (e) {
      print('DioError loading categories: ${e.message}');
      throw Exception('Failed to load categories: ${e.message}');
    } catch (e) {
      print('Unexpected error loading categories: $e');
      throw Exception('Failed to load categories: $e');
    }
  }
}
