import '../../data/models/favorite_model.dart';


abstract class FavoriteState {}

class FavoriteInitial extends FavoriteState {}

class FavoriteLoading extends FavoriteState {}

class FavoriteLoaded extends FavoriteState {
  final List<FavoriteModel> favorites;

  FavoriteLoaded(this.favorites);
}

class FavoriteError extends FavoriteState {
  final String message;

  FavoriteError(this.message);
}
