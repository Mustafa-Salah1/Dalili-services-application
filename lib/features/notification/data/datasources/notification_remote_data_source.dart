import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';

class NotificationRemoteDataSource {
  final Dio dio = DioClient.dio;

  Future<Response> getNotifications() async {
    return await dio.get('/api/notifications');
  }

  Future<void> markAsRead(int id) async {
    await dio.put('/api/notifications/$id/read');
  }
}
