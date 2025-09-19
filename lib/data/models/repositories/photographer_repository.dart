import 'dart:io';
import 'package:dio/dio.dart';
import 'package:chakak_flutter/data/dtos/photographer_dto.dart';
import 'package:chakak_flutter/data/models/photographer.dart';

import '../../../_core/constants/api_config.dart';

abstract class PhotographerRepository {
  Future<List<Photographer>> getPhotographers();
  Future<void> updateLikeStatus(int photographerId, bool isLiked);
}

class PhotographerRepositoryImpl implements PhotographerRepository {
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
  Future<List<Photographer>> getPhotographers() async {
    final String apiUrl = '$serverUrl/api/photographers';
    try {
      final response = await _dio.get(apiUrl);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = response.data;

        if (responseData.containsKey('body') && responseData['body'] is List) {
          final List<dynamic> photographerListFromResponse =
              responseData['body'] as List<dynamic>;
          final List<Photographer> photographers = photographerListFromResponse
              .map((item) {
                if (item is Map<String, dynamic>) {
                  final dto = PhotographerDto.fromJson(item);
                  return dto.toModel();
                } else {
                  print('Invalid item format in photographer list: $item');
                  return null;
                }
              })
              .where((photographer) => photographer != null)
              .cast<Photographer>()
              .toList();
          return photographers;
        } else {
          print(
              'Error: Response "body" is not a list or "body" key is missing for photographers. URL: $apiUrl, Response: $responseData');
          return [];
        }
      } else {
        print(
            'Error fetching photographers: ${response.statusCode}, URL: $apiUrl');
        return [];
      }
    } on DioException catch (e) {
      print('DioError fetching photographers: ${e.message}, URL: $apiUrl');
      return [];
    } catch (e) {
      print('Unexpected error fetching photographers: $e, URL: $apiUrl');
      return [];
    }
  }

  @override
  Future<void> updateLikeStatus(int photographerId, bool isLiked) async {
    final String apiUrl = '$serverUrl/api/photographers/$photographerId/like';
    try {
      final response = await _dio.patch(
        apiUrl,
        data: {'isLiked': isLiked},
      );

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to update photographer like status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print(
          'DioError updating photographer like status: ${e.message}, URL: $apiUrl');
      throw Exception(
          'Failed to update photographer like status: ${e.message}');
    } catch (e) {
      print(
          'Unexpected error updating photographer like status: $e, URL: $apiUrl');
      throw Exception('Failed to update photographer like status: $e');
    }
  }
}
