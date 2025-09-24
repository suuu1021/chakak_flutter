import 'package:dio/dio.dart';

import '../../dtos/photographer_profile_dto.dart';
import '../photographer_profile.dart'; 

/// 사진작가 프로필 관련 Repository 인터페이스
abstract class PhotographerProfileRepository {
  Future<PhotographerProfile> createProfile(PhotographerProfileFormDto dto);
  Future<void> updateProfile(String id, PhotographerProfileFormDto dto); // 반환 타입 변경
  Future<PhotographerProfile?> getProfile(String id);
  Future<PhotographerProfile?> getMyProfile();
  Future<void> deleteProfile(String id);
  Future<void> updateProfileStatus(String id, String status);
}

/// 사진작가 프로필 Repository 구현체
class PhotographerProfileRepositoryImpl implements PhotographerProfileRepository {
  final Dio _dio;

  PhotographerProfileRepositoryImpl(this._dio);

  @override
  Future<PhotographerProfile> createProfile(PhotographerProfileFormDto dto) async {
    try {
      print('[DEBUG] createProfile API 호출');
      final Map<String, dynamic> body = dto.toJson(); 

      final response = await _dio.post('/api/photographers/create', data: body);
      print('[DEBUG] createProfile 응답 코드: ${response.statusCode}');
      print('[DEBUG] createProfile 응답 데이터: ${response.data}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        if (response.data != null && response.data['response'] is Map<String, dynamic>) {
          return PhotographerProfile.fromJson(response.data['response']);
        } else if (response.data is Map<String, dynamic>) {
          return PhotographerProfile.fromJson(response.data);
        }
        throw Exception('프로필 생성 응답 형식이 올바르지 않습니다.');
      }
      throw Exception('프로필 생성에 실패했습니다: ${response.statusMessage}');
    } on DioException catch (e) {
      print('[DEBUG] createProfile DioException: ${e.response?.statusCode} ${e.message}');
      throw Exception('프로필 생성에 실패했습니다: ${e.message}');
    } catch (e) {
      throw Exception('프로필 생성에 실패했습니다: ${e.toString()}');
    }
  }

  @override
  Future<void> updateProfile(String id, PhotographerProfileFormDto dto) async { // 반환 타입 변경
    try {
      print('[DEBUG] updateProfile API 호출 for id=$id');
      final Map<String, dynamic> body = dto.toJson(); 

      final response = await _dio.put('/api/photographers/$id/update', data: body);
      print('[DEBUG] updateProfile 응답 코드: ${response.statusCode}');
      print('[DEBUG] updateProfile 응답 데이터: ${response.data}');

      if (response.statusCode == 200) {
        // 성공 시 별도의 객체를 반환하지 않음
        return;
      }
      // 성공적이지 않은 응답 처리 (예: 4xx, 5xx 에러)
      // 서버에서 보내는 오류 메시지가 있다면 response.data에서 추출 가능
      String errorMessage = '프로필 수정에 실패했습니다.';
      if (response.data is Map<String, dynamic> && response.data['msg'] != null) {
        errorMessage = response.data['msg'];
      } else if (response.statusMessage != null && response.statusMessage!.isNotEmpty) {
        errorMessage = response.statusMessage!;
      }
      throw Exception(errorMessage);
    } on DioException catch (e) {
      print('[DEBUG] updateProfile DioException: ${e.response?.statusCode} ${e.message}');
      // Dio 오류 메시지 또는 서버에서 제공하는 오류 메시지 사용
      String serverMsg = '프로필 수정 중 오류가 발생했습니다.';
      if (e.response?.data is Map<String, dynamic> && e.response!.data['msg'] != null){
        serverMsg = e.response!.data['msg'];
      } else if (e.message != null && e.message!.isNotEmpty) {
        serverMsg = e.message!;
      }
      throw Exception(serverMsg);
    } catch (e) {
      print('[DEBUG] updateProfile 일반 예외: ${e.toString()}');
      throw Exception('프로필 수정 중 예기치 않은 오류가 발생했습니다: ${e.toString()}');
    }
  }

  @override
  Future<PhotographerProfile?> getProfile(String id) async {
    try {
      final response = await _dio.get('/api/photographers/$id');
      if (response.statusCode == 200) {
        if (response.data != null && response.data['body'] is Map<String, dynamic>) {
          return PhotographerProfile.fromJson(response.data['body']);
        } else if (response.data != null && response.data['response'] is Map<String, dynamic>) {
          return PhotographerProfile.fromJson(response.data['response']);
        } else if (response.data is Map<String, dynamic>){
          return PhotographerProfile.fromJson(response.data);
        }
        return null;
      }
      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      print('[DEBUG] getProfile DioException: ${e.response?.statusCode} ${e.message}');
      throw Exception('프로필 조회에 실패했습니다: ${e.message}');
    } catch (e) {
      throw Exception('프로필 조회에 실패했습니다: ${e.toString()}');
    }
  }
  @override
  Future<PhotographerProfile?> getMyProfile() async {
    try {
      print('[DEBUG] 포토그래퍼 프로필 API 호출 시작');
      final endpoints = ['/api/photographers/me'];
      Response? response;
      for (final endpoint in endpoints) {
        try {
          print('[DEBUG] 시도 엔드포인트: $endpoint');
          response = await _dio.get(endpoint);
          print('[DEBUG] 응답 상태 코드: ${response.statusCode} (from $endpoint)');
          print('[DEBUG] 응답 데이터: ${response.data}');
          break;
        } on DioException catch (e) {
          print('[DEBUG] 시도한 엔드포인트 $endpoint 에러: ${e.response?.statusCode}');
          if (e.response?.statusCode == 404) {
            print('[DEBUG] 프로필이 등록되지 않음 (404 from $endpoint)');
            return null;
          }
          throw e;
        }
      }
      if (response == null) return null;

      dynamic responseBody = response.data; // 전체 응답 데이터
      Map<String, dynamic>? profileData;

      if (responseBody is Map<String, dynamic>) {
        if (responseBody.containsKey('data') && responseBody['data'] is Map<String, dynamic>) {
          profileData = responseBody['data'] as Map<String, dynamic>;
        } else if (responseBody.containsKey('body') && responseBody['body'] is Map<String, dynamic>) { // 기존 로직 유지 (하위 호환성)
          profileData = responseBody['body'] as Map<String, dynamic>;
        } else if (responseBody.containsKey('response') && responseBody['response'] is Map<String, dynamic>) { // 기존 로직 유지
          profileData = responseBody['response'] as Map<String, dynamic>;
        } else {
          // 'data', 'body', 'response' 키가 없고, responseBody 자체가 프로필 데이터일 경우
          profileData = responseBody;
        }
      }

      if (profileData == null) {
        print('[DEBUG] 파싱할 프로필 데이터(data, body, response)를 찾을 수 없거나 형식이 맞지 않습니다: $responseBody');
        return null;
      }
      
      print('[DEBUG] 파싱할 프로필 데이터: $profileData');
      return PhotographerProfile.fromJson(profileData);
    } on DioException catch (e) {
      print('[DEBUG] getMyProfile DioException: ${e.response?.statusCode} ${e.message}');
      if (e.response?.statusCode == 404) {
        print('[DEBUG] 프로필이 등록되지 않음 (404)');
        return null;
      } else if (e.response?.statusCode == 403) {
        throw Exception('포토그래퍼 권한이 없습니다');
      } else if (e.response?.statusCode == 401) {
        throw Exception('인증이 만료되었습니다. 다시 로그인해주세요');
      }
      throw Exception('프로필 조회 중 오류가 발생했습니다: ${e.message}');
    } catch (e) {
      print('[DEBUG] getMyProfile 일반 예외 발생: $e');
      throw Exception('내 프로필 조회에 실패했습니다: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteProfile(String id) async {
    try {
      final response = await _dio.delete('/api/photographers/$id/delete');
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('프로필 삭제에 실패했습니다: ${response.statusMessage}');
      }
      print('[DEBUG] deleteProfile 성공 for id=$id');
    } on DioException catch (e) {
      print('[DEBUG] deleteProfile DioException: ${e.response?.statusCode} ${e.message}');
      throw Exception('프로필 삭제에 실패했습니다: ${e.message}');
    } catch (e) {
      throw Exception('프로필 삭제에 실패했습니다: ${e.toString()}');
    }
  }

  @override
  Future<void> updateProfileStatus(String id, String status) async {
    try {
      final response = await _dio.put('/api/photographers/$id/status', data: {'status': status});
      if (response.statusCode != 200) {
        throw Exception('프로필 상태 변경에 실패했습니다: ${response.statusMessage}');
      }
      print('[DEBUG] updateProfileStatus 성공 for id=$id, status=$status');
    } on DioException catch (e) {
      print('[DEBUG] updateProfileStatus DioException: ${e.response?.statusCode} ${e.message}');
      throw Exception('프로필 상태 변경에 실패했습니다: ${e.message}');
    } catch (e) {
      throw Exception('프로필 상태 변경에 실패했습니다: ${e.toString()}');
    }
  }
}
