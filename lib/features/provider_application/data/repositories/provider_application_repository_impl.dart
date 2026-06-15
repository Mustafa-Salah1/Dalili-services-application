import '../../domain/repositories/provider_application_repository.dart';
import '../datasources/provider_application_remote_data_source.dart';
import '../models/provider_application_model.dart';

class ProviderApplicationRepositoryImpl
    implements ProviderApplicationRepository {
  final ProviderApplicationRemoteDataSource remoteDataSource;

  ProviderApplicationRepositoryImpl(this.remoteDataSource);

  @override
  Future<ProviderApplicationModel> createApplication({
    required String phone,
    required String city,
    required String description,
    required int serviceId,
    required double latitude,
    required double longitude,
  }) async {
    final response = await remoteDataSource.createApplication(
      phone: phone,
      city: city,
      description: description,
      serviceId: serviceId,
      latitude: latitude,
      longitude: longitude,
    );

    return ProviderApplicationModel.fromJson(response.data);
  }

  @override
  Future<ProviderApplicationModel> getMyApplication() async {
    final response = await remoteDataSource.getMyApplication();

    return ProviderApplicationModel.fromJson(response.data);
  }
}
