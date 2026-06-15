import 'package:dio/dio.dart';
import 'package:service_finder/core/network/dio_client.dart';

class ServiceRemoteDataSource {
  Future<Response> getServices() async {
    return await DioClient.dio.get('/api/services');
  }

  Future<Response> createService({
    required String title,
    required String description,
  }) async {
    return await DioClient.dio.post(
      '/api/services',
      data: {'title': title, 'description': description},
    );
  }

  Future<Response> updateService({
    required int serviceId,
    required String title,
    required String description,
  }) async {
    return await DioClient.dio.put(
      '/api/services/$serviceId',
      data: {'title': title, 'description': description},
    );
  }

  Future<void> deleteService(int serviceId) async {
    await DioClient.dio.delete('/api/services/$serviceId');
  }
}
