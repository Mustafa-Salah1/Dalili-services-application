import 'package:dio/dio.dart';
import 'package:service_finder/core/network/dio_client.dart';

class RequestRemoteDataSource {
  Future<Response> createRequest({
    required int providerId,
    required String requestDate,
    required String requestTime,
    required int estimatedDurationMinutes,
    required String notes,
  }) async {
    return await DioClient.dio.post(
      '/api/requests',
      data: {
        'providerId': providerId,
        'requestDate': requestDate,
        'requestTime': requestTime,
        'estimatedDurationMinutes': estimatedDurationMinutes,
        'notes': notes,
      },
    );
  }

  Future<Response> getMyRequests() async {
    return await DioClient.dio.get('/api/requests/my');
  }

  Future<Response> getProviderRequests(int providerId) async {
    return await DioClient.dio.get('/api/requests/provider/$providerId');
  }

  Future<Response> acceptRequest(int requestId) async {
    return await DioClient.dio.put('/api/requests/$requestId/accept');
  }

  Future<Response> rejectRequest(int requestId) async {
    return await DioClient.dio.put('/api/requests/$requestId/reject');
  }

  Future<Response> getProviderAvailability(int providerId) async {
    return await DioClient.dio.get(
      '/api/requests/provider/$providerId/availability',
    );
  }

  Future<Response> startRequest(int requestId) async {
    return await DioClient.dio.put('/api/requests/$requestId/start');
  }

  Future<Response> completeRequest(int requestId) async {
    return await DioClient.dio.put('/api/requests/$requestId/complete');
  }
}
