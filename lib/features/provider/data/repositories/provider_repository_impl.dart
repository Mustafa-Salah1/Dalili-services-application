import '../../domain/repositories/provider_repository.dart';
import '../datasources/provider_remote_data_source.dart';
import '../models/provider_model.dart';
import '../models/provider_image_model.dart';

class ProviderRepositoryImpl implements ProviderRepository {
  final ProviderRemoteDataSource remoteDataSource;

  ProviderRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<ProviderModel>> getProvidersByService(int serviceId) async {
    final response = await remoteDataSource.getProvidersByService(serviceId);

    return (response.data as List)
        .map((provider) => ProviderModel.fromJson(provider))
        .toList();
  }

  @override
  Future<ProviderModel> getMyProvider() async {
    final response = await remoteDataSource.getMyProvider();

    return ProviderModel.fromJson(response.data);
  }

  @override
  Future<List<ProviderModel>> getAllProviders() async {
    final response = await remoteDataSource.getAllProviders();

    return (response.data['content'] as List)
        .map((provider) => ProviderModel.fromJson(provider))
        .toList();
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
    final response = await remoteDataSource.getProviderById(providerId);

    return ProviderModel.fromJson(response.data);
  }
}
