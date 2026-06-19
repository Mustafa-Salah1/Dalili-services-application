import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/provider_availability_model.dart';
import 'request_provider.dart';

final providerAvailabilityProvider =
    FutureProvider.family<ProviderAvailabilityModel, int>((
      ref,
      providerId,
    ) async {
      final repository = ref.read(requestRepositoryProvider);

      return repository.getProviderAvailability(providerId);
    });
