import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/provider_application_remote_data_source.dart';
import '../../data/repositories/provider_application_repository_impl.dart';
import '../../domain/repositories/provider_application_repository.dart';

import 'provider_application_state.dart';

final providerApplicationRepositoryProvider =
    Provider<ProviderApplicationRepository>(
      (ref) => ProviderApplicationRepositoryImpl(
        ProviderApplicationRemoteDataSource(),
      ),
    );

class ProviderApplicationNotifier
    extends StateNotifier<ProviderApplicationState> {
  final ProviderApplicationRepository repository;

  ProviderApplicationNotifier(this.repository)
    : super(ProviderApplicationInitial());

  Future<void> createApplication({
    required String phone,
    required String city,
    required String description,
    required int serviceId,
    required double latitude,
    required double longitude,
  }) async {
    state = ProviderApplicationLoading();

    try {
      final application = await repository.createApplication(
        phone: phone,
        city: city,
        description: description,
        serviceId: serviceId,
        latitude: latitude,
        longitude: longitude,
      );

      state = ProviderApplicationSuccess(application);
    } catch (e) {
      state = ProviderApplicationError(e.toString());
    }
  }

  Future<void> getMyApplication() async {
    state = ProviderApplicationLoading();

    try {
      final application = await repository.getMyApplication();

      state = ProviderApplicationSuccess(application);
    } catch (e) {
      print('APPLICATION ERROR: $e');

      if (e.toString().contains('Application not found')) {
        state = NoProviderApplication();
        return;
      }

      state = ProviderApplicationError(e.toString());
    }
  }
}

final providerApplicationProvider =
    StateNotifierProvider<
      ProviderApplicationNotifier,
      ProviderApplicationState
    >(
      (ref) => ProviderApplicationNotifier(
        ref.read(providerApplicationRepositoryProvider),
      ),
    );
