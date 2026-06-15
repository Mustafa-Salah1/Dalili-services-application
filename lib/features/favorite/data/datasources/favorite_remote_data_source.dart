import 'package:dio/dio.dart';

import '../../../../core/network/dio_client.dart';

class FavoriteRemoteDataSource {
  Future<Response> getMyFavorites() async {
    return await DioClient.dio.get('/api/favorites/my');
  }

  Future<Response> addFavorite(int providerId) async {
    return await DioClient.dio.post('/api/favorites/$providerId');
  }

  Future<Response> removeFavorite(int providerId) async {
    return await DioClient.dio.delete('/api/favorites/$providerId');
  }

  Future<Response> isFavorite(int providerId) async {
    return await DioClient.dio.get('/api/favorites/check/$providerId');
  }
}
