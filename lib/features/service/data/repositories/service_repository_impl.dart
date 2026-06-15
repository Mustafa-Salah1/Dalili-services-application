import '../../domain/repositories/service_repository.dart';
import '../datasources/service_remote_data_source.dart';
import '../models/service_model.dart';

class ServiceRepositoryImpl implements ServiceRepository {
  final ServiceRemoteDataSource remoteDataSource;

  ServiceRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<ServiceModel>> getServices() async {
    final response = await remoteDataSource.getServices();

    return (response.data as List)
        .map((service) => ServiceModel.fromJson(service))
        .toList();
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

    return ServiceModel.fromJson(response.data);
  }

  @override
  Future<void> deleteService(int serviceId) async {
    await remoteDataSource.deleteService(serviceId);
  }
}
