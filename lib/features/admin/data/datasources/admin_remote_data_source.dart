import 'package:dio/dio.dart';

import '../../../../core/network/dio_client.dart';

class AdminRemoteDataSource {
  Future<Response> getApplications() async {
    return await DioClient.dio.get('/api/provider-applications');
  }

  Future<Response> approveApplication(int id) async {
    return await DioClient.dio.put('/api/provider-applications/$id/approve');
  }

  Future<Response> rejectApplication(int id) async {
    return await DioClient.dio.put('/api/provider-applications/$id/reject');
  }
}
