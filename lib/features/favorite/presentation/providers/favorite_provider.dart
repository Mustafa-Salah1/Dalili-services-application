import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/favorite_remote_data_source.dart';
import '../../data/repositories/favorite_repository_impl.dart';
import '../../domain/repositories/favorite_repository.dart';

import 'favorite_state.dart';

final favoriteRepositoryProvider = Provider<FavoriteRepository>(
  (ref) => FavoriteRepositoryImpl(FavoriteRemoteDataSource()),
);

class FavoriteNotifier extends StateNotifier<FavoriteState> {
  final FavoriteRepository repository;

  FavoriteNotifier(this.repository) : super(FavoriteInitial());

  Future<void> getMyFavorites() async {
    state = FavoriteLoading();

    try {
      final favorites = await repository.getMyFavorites();

      state = FavoriteLoaded(favorites);
    } catch (e) {
      state = FavoriteError(e.toString());
    }
  }

  Future<void> addFavorite(int providerId) async {
    await repository.addFavorite(providerId);
  }

  Future<void> removeFavorite(int providerId) async {
    await repository.removeFavorite(providerId);
  }

  Future<bool> isFavorite(int providerId) async {
    return await repository.isFavorite(providerId);
  }
}

final favoriteProvider = StateNotifierProvider<FavoriteNotifier, FavoriteState>(
  (ref) => FavoriteNotifier(ref.read(favoriteRepositoryProvider)),
);
