import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';

class ProviderApplicationRemoteDataSource {
  Future<Response> createApplication({
    required String phone,
    required String city,
    required String description,
    required int serviceId,
    required double latitude,
    required double longitude,
  }) async {
    return await DioClient.dio.post(
      '/api/provider-applications',
      data: {
        'phone': phone,
        'city': city,
        'description': description,
        'serviceId': serviceId,
        'latitude': latitude,
        'longitude': longitude,
      },
    );
  }

  Future<Response> getMyApplication() async {
    return await DioClient.dio.get('/api/provider-applications/my');
  }
}
