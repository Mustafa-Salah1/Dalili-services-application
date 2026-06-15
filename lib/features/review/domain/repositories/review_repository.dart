import '../../data/models/review_model.dart';

abstract class ReviewRepository {
  Future<List<ReviewModel>> getProviderReviews(int providerId);

  Future<double> getAverageRating(int providerId);

  Future<ReviewModel> createReview({
    required int providerId,
    required int rating,
    required String comment,
  });

  Future<void> deleteReview(int reviewId);
}
