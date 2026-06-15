import 'package:dio/dio.dart';
import 'package:service_finder/core/network/dio_client.dart';

class ProviderRemoteDataSource {
  Future<Response> getProvidersByService(int serviceId) async {
    return await DioClient.dio.get('/api/providers/service/$serviceId');
  }

  Future<Response> getMyProvider() async {
    return await DioClient.dio.get('/api/providers/me');
  }

  Future<Response> getAllProviders() async {
    return await DioClient.dio.get('/api/providers?page=0&size=100');
  }

  Future<Response> uploadCoverImage({
    required int providerId,
    required String imagePath,
  }) async {
    FormData formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(imagePath),
    });

    return await DioClient.dio.post(
      '/api/providers/$providerId/cover-image',
      data: formData,
    );
  }

  Future<Response> getProviderById(int providerId) async {
    return await DioClient.dio.get('/api/providers/$providerId');
  }

  Future<Response> uploadGalleryImage({
    required int providerId,
    required String imagePath,
  }) async {
    FormData formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(imagePath),
    });

    return await DioClient.dio.post(
      '/api/providers/$providerId/gallery',
      data: formData,
    );
  }

  Future<Response> getProviderImages(int providerId) async {
    return await DioClient.dio.get('/api/providers/$providerId/gallery');
  }

  Future<Response> updateMyProvider({
    required String name,
    required String phone,
    required String description,
    required String city,
    required int serviceId,
    required double latitude,
    required double longitude,
  }) async {
    return await DioClient.dio.put(
      '/api/providers/me',
      data: {
        'name': name,
        'phone': phone,
        'description': description,
        'city': city,
        'serviceId': serviceId,
        'latitude': latitude,
        'longitude': longitude,
      },
    );
  }
}
