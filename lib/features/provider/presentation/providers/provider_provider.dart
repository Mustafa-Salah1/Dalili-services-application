import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/provider_remote_data_source.dart';
import '../../data/models/provider_image_model.dart';
import '../../data/models/provider_model.dart';
import '../../data/repositories/provider_repository_impl.dart';
import '../../domain/repositories/provider_repository.dart';

import 'provider_state.dart';

final providerRepositoryProvider = Provider<ProviderRepository>(
  (ref) => ProviderRepositoryImpl(ProviderRemoteDataSource()),
);

final providerImagesProvider = StateProvider<List<ProviderImageModel>>(
  (ref) => [],
);

class ProviderNotifier extends StateNotifier<ProviderState> {
  final ProviderRepository repository;

  ProviderNotifier(this.repository) : super(ProviderInitial());

  Future<void> getProvidersByService(int serviceId) async {
    state = ProviderLoading();

    try {
      final providers = await repository.getProvidersByService(serviceId);

      state = ProviderLoaded(providers);
    } catch (e) {
      state = ProviderError(e.toString());
    }
  }

  Future<void> getMyProvider() async {
    state = ProviderLoading();

    try {
      final provider = await repository.getMyProvider();

      state = MyProviderLoaded(provider);
    } catch (e) {
      state = ProviderError(e.toString());
    }
  }

  Future<List<ProviderModel>> getAllProviders() async {
    return await repository.getAllProviders();
  }

  Future<void> uploadCoverImage({
    required int providerId,
    required String imagePath,
  }) async {
    try {
      final provider = await repository.uploadCoverImage(
        providerId: providerId,
        imagePath: imagePath,
      );

      state = MyProviderLoaded(provider);
    } catch (e) {
      state = ProviderError(e.toString());
    }
  }

  Future<void> updateMyProvider({
    required String name,
    required String phone,
    required String description,
    required String city,
    required int serviceId,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final provider = await repository.updateMyProvider(
        name: name,
        phone: phone,
        description: description,
        city: city,
        serviceId: serviceId,
        latitude: latitude,
        longitude: longitude,
      );

      state = MyProviderLoaded(provider);
    } catch (e) {
      state = ProviderError(e.toString());
    }
  }

  Future<ProviderImageModel> uploadGalleryImage({
    required int providerId,
    required String imagePath,
  }) async {
    return await repository.uploadGalleryImage(
      providerId: providerId,
      imagePath: imagePath,
    );
  }

  Future<List<ProviderImageModel>> getProviderImages(int providerId) async {
    return await repository.getProviderImages(providerId);
  }

  Future<void> loadProviderImages(WidgetRef ref, int providerId) async {
    final images = await repository.getProviderImages(providerId);

    ref.read(providerImagesProvider.notifier).state = images;
  }

  Future<ProviderModel> getProviderById(int providerId) async {
    return await repository.getProviderById(providerId);
  }
}

final providerProvider = StateNotifierProvider<ProviderNotifier, ProviderState>(
  (ref) => ProviderNotifier(ref.read(providerRepositoryProvider)),
);
