import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';

class AuthRemoteDataSource {
  final Dio dio = DioClient.dio;

  Future<Response> register({
    required String username,
    required String email,
    required String password,
  }) async {
    return await dio.post(
      '/api/auth/register',
      data: {'username': username, 'email': email, 'password': password},
    );
  }

  Future<Response> login({
    required String usernameOrEmail,
    required String password,
  }) async {
    return await dio.post(
      '/api/auth/login',
      data: {'usernameOrEmail': usernameOrEmail, 'password': password},
    );
  }

  Future<void> logout({required String refreshToken}) async {
    await dio.post('/api/auth/logout', data: {'refreshToken': refreshToken});
  }

  Future<Response> refreshToken({required String refreshToken}) async {
    return await dio.post(
      '/api/auth/refresh',
      data: {'refreshToken': refreshToken},
    );
  }
}
