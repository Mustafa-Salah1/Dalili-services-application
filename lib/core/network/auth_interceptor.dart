import 'package:dio/dio.dart';
import 'package:service_finder/core/storage/secure_storage_service.dart';
import 'package:service_finder/features/auth/data/datasources/auth_remote_source.dart';

class AuthInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await SecureStorageService.getAccessToken();

    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';

      print('Token Attached');
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    print('Interceptor Error: ${err.response?.statusCode}');
    print('Request URL: ${err.requestOptions.path}');

    if (err.requestOptions.path == '/api/auth/refresh') {
      return handler.next(err);
    }

    if (err.response?.statusCode == 401) {
      try {
        final refreshToken = await SecureStorageService.getRefreshToken();

        if (refreshToken != null) {
          final response = await AuthRemoteDataSource().refreshToken(
            refreshToken: refreshToken,
          );

          final newAccessToken = response.data['accessToken'];

          await SecureStorageService.saveAccessToken(newAccessToken);

          print('New Access Token Saved');

          final requestOptions = err.requestOptions;

          requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';

          final retryResponse = await Dio().fetch(requestOptions);

          return handler.resolve(retryResponse);
        }
      } catch (e) {
        print('Refresh Failed: $e');
      }
    }

    handler.next(err);
  }
}
