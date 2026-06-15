import '../../data/models/favorite_model.dart';

abstract class FavoriteRepository {
  Future<List<FavoriteModel>> getMyFavorites();

  Future<void> addFavorite(int providerId);

  Future<void> removeFavorite(int providerId);

  Future<bool> isFavorite(int providerId);
}
