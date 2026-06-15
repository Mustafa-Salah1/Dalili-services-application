import '../../data/models/service_model.dart';

abstract class ServiceRepository {
  Future<List<ServiceModel>> getServices();

  Future<ServiceModel> createService({
    required String title,
    required String description,
  });

  Future<ServiceModel> updateService({
    required int serviceId,
    required String title,
    required String description,
  });

  Future<void> deleteService(int serviceId);
}
