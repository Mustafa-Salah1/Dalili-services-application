import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/review_remote_data_source.dart';
import '../../data/repositories/review_repository_impl.dart';
import '../../domain/repositories/review_repository.dart';

import 'review_state.dart';

final reviewRepositoryProvider = Provider<ReviewRepository>(
  (ref) => ReviewRepositoryImpl(ReviewRemoteDataSource()),
);

class ReviewNotifier extends StateNotifier<ReviewState> {
  final ReviewRepository repository;

  ReviewNotifier(this.repository) : super(ReviewInitial());

  Future<void> getProviderReviews(int providerId) async {
    state = ReviewLoading();

    try {
      final reviews = await repository.getProviderReviews(providerId);

      final average = await repository.getAverageRating(providerId);

      state = ReviewLoaded(reviews, average);
    } catch (e) {
      state = ReviewError(e.toString());
    }
  }

  Future<void> createReview({
    required int providerId,
    required int rating,
    required String comment,
  }) async {
    try {
      await repository.createReview(
        providerId: providerId,
        rating: rating,
        comment: comment,
      );

      await getProviderReviews(providerId);
    } catch (e) {
      state = ReviewError(e.toString());
    }
  }

  Future<void> deleteReview({
    required int reviewId,
    required int providerId,
  }) async {
    try {
      await repository.deleteReview(reviewId);

      await getProviderReviews(providerId);
    } catch (e) {
      state = ReviewError(e.toString());
    }
  }
}

final reviewProvider = StateNotifierProvider<ReviewNotifier, ReviewState>(
  (ref) => ReviewNotifier(ref.read(reviewRepositoryProvider)),
);
