import 'dart:io' show Platform;
import 'package:dio/dio.dart';
import 'package:chakak_flutter/data/dtos/photographer_dto.dart'; // PhotographerDto 경로 (실제 경로로 수정 필요)
import 'package:chakak_flutter/data/models/photographer.dart';

import '../../../_core/constants/api_config.dart';
// AppStrings, AppImages 등 목 데이터 관련 import는 제거됩니다.

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
    // TODO: 실제 API 엔드포인트로 교체 (예: /api/photographers 또는 /api/photographers/list)
    final String apiUrl = '$serverUrl/api/photographers';
    try {
      final response = await _dio.get(apiUrl);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = response.data;
        // 서버 응답 구조에 'body' 키가 있고, 그 값이 리스트인지 확인
        if (responseData.containsKey('body') && responseData['body'] is List) {
          final List<dynamic> photographerListFromResponse =
              responseData['body'] as List<dynamic>;
          final List<Photographer> photographers = photographerListFromResponse
              .map((item) {
                // 각 아이템이 Map 형태인지 확인 후 DTO로 변환
                if (item is Map<String, dynamic>) {
                  // PhotographerDto가 정의되어 있고 fromJson, toModel 메서드가 있다고 가정
                  final dto = PhotographerDto.fromJson(item);
                  return dto.toModel();
                } else {
                  print('Invalid item format in photographer list: $item');
                  return null;
                }
              })
              .where((photographer) => photographer != null) // null이 아닌 객체만 필터링
              .cast<Photographer>() // 타입 캐스팅
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
    // TODO: 실제 API 엔드포인트 및 HTTP 메서드 (POST, PUT 등)로 교체
    final String apiUrl = '$serverUrl/api/photographers/$photographerId/like';
    try {
      final response = await _dio.post(
        // 또는 _dio.put 등 API 명세에 따름
        apiUrl,
        data: {'isLiked': isLiked}, // 서버가 기대하는 요청 본문 형식으로 수정
      );

      // 성공 응답 코드 확인 (200, 204 등 API 명세에 따름)
      if (response.statusCode == 200 || response.statusCode == 204) {
        print(
            'Photographer like status updated successfully: $photographerId, $isLiked. URL: $apiUrl');
      } else {
        print(
            'Error updating photographer like status: ${response.statusCode}, Message: ${response.data}, URL: $apiUrl');
        // 필요시 예외 발생 또는 사용자에게 오류 알림
      }
    } on DioException catch (e) {
      print(
          'DioError updating photographer like status: ${e.message}, URL: $apiUrl');
      // 필요시 예외 발생 또는 사용자에게 오류 알림
    } catch (e) {
      print(
          'Unexpected error updating photographer like status: $e, URL: $apiUrl');
      // 필요시 예외 발생 또는 사용자에게 오류 알림
    }
  }
}
