import 'package:flutter/foundation.dart';
import 'package:service_finder/core/cache/cache_service.dart';

import '../../domain/repositories/service_repository.dart';
import '../datasources/service_remote_data_source.dart';
import '../models/service_model.dart';

class ServiceRepositoryImpl implements ServiceRepository {
  final ServiceRemoteDataSource remoteDataSource;

  ServiceRepositoryImpl(this.remoteDataSource);

  static const String _cacheKey = 'services';
  static const String _cacheTimestampKey = 'services_timestamp';
  static const Duration _cacheDuration = Duration(minutes: 1);

  List<ServiceModel>? _memoryCache;
  DateTime? _memoryCacheTimestamp;

  @override
  Future<List<ServiceModel>> getServices() async {
    // Memory Cache Expiration Check
    if (_memoryCache != null && _memoryCacheTimestamp != null) {
      final age = DateTime.now().difference(_memoryCacheTimestamp!);

      if (age < _cacheDuration) {
        debugPrint('SERVICES => MEMORY CACHE');

        return _memoryCache!;
      }

      debugPrint('SERVICES => MEMORY CACHE EXPIRED');

      _memoryCache = null;
      _memoryCacheTimestamp = null;
    }

    // Hive Cache Expiration Check
    final timestamp = CacheService.servicesBox.get(_cacheTimestampKey);

    if (timestamp != null) {
      final cacheAge = DateTime.now().millisecondsSinceEpoch - timestamp;

      final isExpired = cacheAge > _cacheDuration.inMilliseconds;

      if (!isExpired) {
        final cachedData = CacheService.servicesBox.get(_cacheKey);

        if (cachedData != null) {
          debugPrint('SERVICES => HIVE CACHE (VALID)');

          final services = (cachedData as List)
              .map(
                (service) =>
                    ServiceModel.fromJson(Map<String, dynamic>.from(service)),
              )
              .toList();

          _memoryCache = services;
          _memoryCacheTimestamp = DateTime.now();

          return services;
        }
      }

      debugPrint('SERVICES => CACHE EXPIRED');
    }

    try {
      debugPrint('SERVICES => API');

      final response = await remoteDataSource.getServices();

      final rawList = response.data as List;

      final services = rawList
          .map((service) => ServiceModel.fromJson(service))
          .toList();

      _memoryCache = services;
      _memoryCacheTimestamp = DateTime.now();

      try {
        await CacheService.servicesBox.put(_cacheKey, rawList);

        await CacheService.servicesBox.put(
          _cacheTimestampKey,
          DateTime.now().millisecondsSinceEpoch,
        );
      } catch (e) {
        debugPrint('SERVICES => HIVE WRITE FAILED: $e');
      }

      return services;
    } catch (e) {
      final cachedData = CacheService.servicesBox.get(_cacheKey);

      if (cachedData != null) {
        debugPrint('SERVICES => HIVE CACHE');

        final services = (cachedData as List)
            .map(
              (service) =>
                  ServiceModel.fromJson(Map<String, dynamic>.from(service)),
            )
            .toList();

        _memoryCache = services;
        _memoryCacheTimestamp = DateTime.now();

        return services;
      }

      rethrow;
    }
  }

  void clearServicesCache() {
    _memoryCache = null;
    _memoryCacheTimestamp = null;

    CacheService.servicesBox.delete(_cacheKey);

    CacheService.servicesBox.delete(_cacheTimestampKey);
  }

  @override
  Future<ServiceModel> createService({
    required String title,
    required String description,
  }) async {
    final response = await remoteDataSource.createService(
      title: title,
      description: description,
    );

    clearServicesCache();

    return ServiceModel.fromJson(response.data);
  }

  @override
  Future<ServiceModel> updateService({
    required int serviceId,
    required String title,
    required String description,
  }) async {
    final response = await remoteDataSource.updateService(
      serviceId: serviceId,
      title: title,
      description: description,
    );

    clearServicesCache();

    return ServiceModel.fromJson(response.data);
  }

  @override
  Future<void> deleteService(int serviceId) async {
    await remoteDataSource.deleteService(serviceId);

    clearServicesCache();
  }
}
