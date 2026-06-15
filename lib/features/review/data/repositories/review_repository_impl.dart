import '../../domain/repositories/review_repository.dart';
import '../datasources/review_remote_data_source.dart';
import '../models/review_model.dart';

class ReviewRepositoryImpl implements ReviewRepository {
  final ReviewRemoteDataSource remoteDataSource;

  ReviewRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<ReviewModel>> getProviderReviews(int providerId) async {
    final response = await remoteDataSource.getProviderReviews(providerId);

    return (response.data as List).map((e) => ReviewModel.fromJson(e)).toList();
  }

  @override
  Future<double> getAverageRating(int providerId) async {
    final response = await remoteDataSource.getAverageRating(providerId);

    return (response.data as num).toDouble();
  }

  @override
  Future<ReviewModel> createReview({
    required int providerId,
    required int rating,
    required String comment,
  }) async {
    final response = await remoteDataSource.createReview(
      providerId: providerId,
      rating: rating,
      comment: comment,
    );

    return ReviewModel.fromJson(response.data);
  }

  @override
  Future<void> deleteReview(int reviewId) async {
    await remoteDataSource.deleteReview(reviewId);
  }
}
