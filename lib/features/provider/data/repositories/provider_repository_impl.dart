import 'package:service_finder/core/cache/cache_service.dart';

import '../../domain/repositories/provider_repository.dart';
import '../datasources/provider_remote_data_source.dart';
import '../models/provider_model.dart';
import '../models/provider_image_model.dart';

class ProviderRepositoryImpl implements ProviderRepository {
  final ProviderRemoteDataSource remoteDataSource;

  ProviderRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<ProviderModel>> getProvidersByService(int serviceId) async {
    try {
      final response = await remoteDataSource.getProvidersByService(serviceId);

      await CacheService.providersBox.put(
        'providers_service_$serviceId',
        response.data,
      );

      return (response.data as List)
          .map((provider) => ProviderModel.fromJson(provider))
          .toList();
    } catch (e) {
      final cachedData = CacheService.providersBox.get(
        'providers_service_$serviceId',
      );

      if (cachedData != null) {
        return (cachedData as List)
            .map(
              (provider) =>
                  ProviderModel.fromJson(Map<String, dynamic>.from(provider)),
            )
            .toList();
      }

      rethrow;
    }
  }

  @override
  Future<ProviderModel> getMyProvider() async {
    final response = await remoteDataSource.getMyProvider();

    return ProviderModel.fromJson(response.data);
  }

  @override
  Future<List<ProviderModel>> getAllProviders() async {
    try {
      final response = await remoteDataSource.getAllProviders();

      await CacheService.providersBox.put(
        'all_providers',
        response.data['content'],
      );

      return (response.data['content'] as List)
          .map((provider) => ProviderModel.fromJson(provider))
          .toList();
    } catch (e) {
      final cachedData = CacheService.providersBox.get('all_providers');

      if (cachedData != null) {
        return (cachedData as List)
            .map(
              (provider) =>
                  ProviderModel.fromJson(Map<String, dynamic>.from(provider)),
            )
            .toList();
      }

      rethrow;
    }
  }

  @override
  Future<ProviderModel> uploadCoverImage({
    required int providerId,
    required String imagePath,
  }) async {
    final response = await remoteDataSource.uploadCoverImage(
      providerId: providerId,
      imagePath: imagePath,
    );

    return ProviderModel.fromJson(response.data);
  }

  @override
  Future<ProviderImageModel> uploadGalleryImage({
    required int providerId,
    required String imagePath,
  }) async {
    final response = await remoteDataSource.uploadGalleryImage(
      providerId: providerId,
      imagePath: imagePath,
    );

    return ProviderImageModel.fromJson(response.data);
  }

  @override
  Future<List<ProviderImageModel>> getProviderImages(int providerId) async {
    final response = await remoteDataSource.getProviderImages(providerId);

    return (response.data as List)
        .map((image) => ProviderImageModel.fromJson(image))
        .toList();
  }

  @override
  Future<ProviderModel> updateMyProvider({
    required String name,
    required String phone,
    required String description,
    required String city,
    required int serviceId,
    required double latitude,
    required double longitude,
  }) async {
    final response = await remoteDataSource.updateMyProvider(
      name: name,
      phone: phone,
      description: description,
      city: city,
      serviceId: serviceId,
      latitude: latitude,
      longitude: longitude,
    );

    return ProviderModel.fromJson(response.data);
  }

  @override
  Future<ProviderModel> getProviderById(int providerId) async {
    try {
      final response = await remoteDataSource.getProviderById(providerId);

      await CacheService.providersBox.put(
        'provider_$providerId',
        response.data,
      );

      return ProviderModel.fromJson(response.data);
    } catch (e) {
      final cachedData = CacheService.providersBox.get('provider_$providerId');

      if (cachedData != null) {
        return ProviderModel.fromJson(Map<String, dynamic>.from(cachedData));
      }

      rethrow;
    }
  }
}
