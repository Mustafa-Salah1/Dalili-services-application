import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/service_remote_data_source.dart';
import '../../data/repositories/service_repository_impl.dart';
import '../../domain/repositories/service_repository.dart';

import 'service_state.dart';

final serviceRepositoryProvider = Provider<ServiceRepository>(
  (ref) => ServiceRepositoryImpl(ServiceRemoteDataSource()),
);

class ServiceNotifier extends StateNotifier<ServiceState> {
  final ServiceRepository repository;

  ServiceNotifier(this.repository) : super(ServiceInitial());

  Future<void> getServices() async {
    state = ServiceLoading();

    try {
      final services = await repository.getServices();

      state = ServiceLoaded(services);
    } catch (e) {
      state = ServiceError(e.toString());
    }
  }

  Future<void> createService({
    required String title,
    required String description,
  }) async {
    await repository.createService(title: title, description: description);

    await getServices();
  }

  Future<void> updateService({
    required int serviceId,
    required String title,
    required String description,
  }) async {
    await repository.updateService(
      serviceId: serviceId,
      title: title,
      description: description,
    );

    await getServices();
  }

  Future<void> deleteService(int serviceId) async {
    await repository.deleteService(serviceId);

    await getServices();
  }
}

final serviceProvider = StateNotifierProvider<ServiceNotifier, ServiceState>(
  (ref) => ServiceNotifier(ref.read(serviceRepositoryProvider)),
);
