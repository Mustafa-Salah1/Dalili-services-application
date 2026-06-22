import 'package:flutter/foundation.dart';
import 'package:service_finder/core/cache/cache_service.dart';

import '../../domain/repositories/provider_repository.dart';
import '../datasources/provider_remote_data_source.dart';
import '../models/provider_model.dart';
import '../models/provider_image_model.dart';

class ProviderRepositoryImpl implements ProviderRepository {
  final ProviderRemoteDataSource remoteDataSource;

  ProviderRepositoryImpl(this.remoteDataSource);

  final Map<int, List<ProviderModel>> _providersByServiceMemoryCache = {};

  static const Duration _cacheDuration = Duration(minutes: 30);

  final Map<int, DateTime> _providersByServiceMemoryCacheTimestamp = {};

  @override
  Future<List<ProviderModel>> getProvidersByService(int serviceId) async {
    if (_providersByServiceMemoryCache.containsKey(serviceId) &&
        _providersByServiceMemoryCacheTimestamp.containsKey(serviceId)) {
      final age = DateTime.now().difference(
        _providersByServiceMemoryCacheTimestamp[serviceId]!,
      );

      if (age < _cacheDuration) {
        debugPrint('PROVIDERS => MEMORY CACHE');

        return _providersByServiceMemoryCache[serviceId]!;
      }

      debugPrint('PROVIDERS => MEMORY CACHE EXPIRED');

      _providersByServiceMemoryCache.remove(serviceId);

      _providersByServiceMemoryCacheTimestamp.remove(serviceId);
    }

    final timestamp = CacheService.providersBox.get(
      'providers_service_${serviceId}_timestamp',
    );

    if (timestamp != null) {
      final cacheAge = DateTime.now().millisecondsSinceEpoch - timestamp;

      final isExpired = cacheAge > _cacheDuration.inMilliseconds;

      if (!isExpired) {
        final cachedData = CacheService.providersBox.get(
          'providers_service_$serviceId',
        );

        if (cachedData != null) {
          debugPrint('PROVIDERS => HIVE CACHE (VALID)');

          final providers = (cachedData as List)
              .map(
                (provider) =>
                    ProviderModel.fromJson(Map<String, dynamic>.from(provider)),
              )
              .toList();

          _providersByServiceMemoryCache[serviceId] = providers;

          _providersByServiceMemoryCacheTimestamp[serviceId] = DateTime.now();

          return providers;
        }
      }

      debugPrint('PROVIDERS => CACHE EXPIRED');
    }

    try {
      debugPrint('PROVIDERS => API');

      final response = await remoteDataSource.getProvidersByService(serviceId);

      final providers = (response.data as List)
          .map((provider) => ProviderModel.fromJson(provider))
          .toList();

      _providersByServiceMemoryCache[serviceId] = providers;

      _providersByServiceMemoryCacheTimestamp[serviceId] = DateTime.now();

      await CacheService.providersBox.put(
        'providers_service_$serviceId',
        response.data,
      );

      await CacheService.providersBox.put(
        'providers_service_${serviceId}_timestamp',
        DateTime.now().millisecondsSinceEpoch,
      );

      return providers;
    } catch (e) {
      final cachedData = CacheService.providersBox.get(
        'providers_service_$serviceId',
      );

      if (cachedData != null) {
        debugPrint('PROVIDERS => HIVE CACHE');

        final providers = (cachedData as List)
            .map(
              (provider) =>
                  ProviderModel.fromJson(Map<String, dynamic>.from(provider)),
            )
            .toList();

        _providersByServiceMemoryCache[serviceId] = providers;

        _providersByServiceMemoryCacheTimestamp[serviceId] = DateTime.now();

        return providers;
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

  final Map<int, List<ProviderImageModel>> _providerImagesMemoryCache = {};

  @override
  Future<List<ProviderImageModel>> getProviderImages(int providerId) async {
    if (_providerImagesMemoryCache.containsKey(providerId)) {
      debugPrint('PROVIDER IMAGES => MEMORY CACHE');

      return _providerImagesMemoryCache[providerId]!;
    }

    try {
      debugPrint('PROVIDER IMAGES => API');

      final response = await remoteDataSource.getProviderImages(providerId);

      final images = (response.data as List)
          .map((image) => ProviderImageModel.fromJson(image))
          .toList();

      _providerImagesMemoryCache[providerId] = images;

      await CacheService.providersBox.put(
        'provider_images_$providerId',
        response.data,
      );

      return images;
    } catch (e) {
      final cachedData = CacheService.providersBox.get(
        'provider_images_$providerId',
      );

      if (cachedData != null) {
        debugPrint('PROVIDER IMAGES => HIVE CACHE');

        final images = (cachedData as List)
            .map(
              (image) =>
                  ProviderImageModel.fromJson(Map<String, dynamic>.from(image)),
            )
            .toList();

        _providerImagesMemoryCache[providerId] = images;

        return images;
      }

      rethrow;
    }
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
