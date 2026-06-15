import 'package:dio/dio.dart';

import '../../../../core/network/dio_client.dart';

class ReviewRemoteDataSource {
  Future<Response> getProviderReviews(int providerId) async {
    return await DioClient.dio.get('/api/reviews/provider/$providerId');
  }

  Future<Response> getAverageRating(int providerId) async {
    return await DioClient.dio.get('/api/reviews/provider/$providerId/average');
  }

  Future<Response> createReview({
    required int providerId,
    required int rating,
    required String comment,
  }) async {
    return await DioClient.dio.post(
      '/api/reviews',
      data: {'providerId': providerId, 'rating': rating, 'comment': comment},
    );
  }

  Future<void> deleteReview(int reviewId) async {
    await DioClient.dio.delete('/api/reviews/$reviewId');
  }
}
