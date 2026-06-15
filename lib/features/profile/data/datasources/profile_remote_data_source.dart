import 'package:dio/dio.dart';
import 'package:service_finder/core/network/dio_client.dart';

class ProfileRemoteDataSource {
  Future<Response> getProfile() async {
    return await DioClient.dio.get('/api/users/me');
  }

  Future<Response> updateProfile({
    required String username,
    required String email,
  }) async {
    return await DioClient.dio.put(
      '/api/users/profile',
      data: {'username': username, 'email': email},
    );
  }

  Future<Response> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    return await DioClient.dio.put(
      '/api/users/change-password',
      data: {'currentPassword': currentPassword, 'newPassword': newPassword},
    );
  }
}
