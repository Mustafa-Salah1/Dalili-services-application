import '../../data/models/review_model.dart';

abstract class ReviewState {}

class ReviewInitial extends ReviewState {}

class ReviewLoading extends ReviewState {}

class ReviewLoaded extends ReviewState {
  final List<ReviewModel> reviews;
  final double averageRating;

  ReviewLoaded(this.reviews, this.averageRating);
}

class ReviewSuccess extends ReviewState {
  final ReviewModel review;

  ReviewSuccess(this.review);
}

class ReviewError extends ReviewState {
  final String message;

  ReviewError(this.message);
}
