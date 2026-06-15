import '../../domain/repositories/favorite_repository.dart';
import '../datasources/favorite_remote_data_source.dart';
import '../models/favorite_model.dart';

class FavoriteRepositoryImpl implements FavoriteRepository {
  final FavoriteRemoteDataSource remoteDataSource;

  FavoriteRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<FavoriteModel>> getMyFavorites() async {
    final response = await remoteDataSource.getMyFavorites();

    return (response.data as List)
        .map((e) => FavoriteModel.fromJson(e))
        .toList();
  }

  @override
  Future<void> addFavorite(int providerId) async {
    await remoteDataSource.addFavorite(providerId);
  }

  @override
  Future<void> removeFavorite(int providerId) async {
    await remoteDataSource.removeFavorite(providerId);
  }

  @override
  Future<bool> isFavorite(int providerId) async {
    final response = await remoteDataSource.isFavorite(providerId);

    return response.data as bool;
  }
}
