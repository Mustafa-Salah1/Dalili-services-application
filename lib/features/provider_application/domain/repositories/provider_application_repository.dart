import '../../data/models/provider_application_model.dart';

abstract class ProviderApplicationRepository {
  Future<ProviderApplicationModel> createApplication({
    required String phone,
    required String city,
    required String description,
    required int serviceId,
    required double latitude,
    required double longitude,
  });

  Future<ProviderApplicationModel> getMyApplication();
}
