import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/request_remote_data_source.dart';
import '../../data/repositories/request_repository_impl.dart';
import '../../domain/repositories/request_repository.dart';

import 'request_state.dart';

final requestRepositoryProvider = Provider<RequestRepository>(
  (ref) => RequestRepositoryImpl(RequestRemoteDataSource()),
);

class RequestNotifier extends StateNotifier<RequestState> {
  final RequestRepository repository;

  RequestNotifier(this.repository) : super(RequestInitial());

  Future<void> createRequest({
    required int providerId,
    required String requestDate,
    required String requestTime,
    required int estimatedDurationMinutes,
    required String notes,
  }) async {
    state = RequestLoading();

    try {
      final request = await repository.createRequest(
        providerId: providerId,
        requestDate: requestDate,
        requestTime: requestTime,
        estimatedDurationMinutes: estimatedDurationMinutes,
        notes: notes,
      );

      state = RequestSuccess(request);
    } catch (e) {
      state = RequestError(e.toString());
    }
  }

  Future<void> getMyRequests() async {
    state = RequestLoading();

    try {
      final requests = await repository.getMyRequests();

      state = MyRequestsLoaded(requests);
    } catch (e) {
      state = RequestError(e.toString());
    }
  }

  Future<void> getProviderRequests(int providerId) async {
    state = RequestLoading();

    try {
      final requests = await repository.getProviderRequests(providerId);

      state = ProviderRequestsLoaded(requests);
    } catch (e) {
      state = RequestError(e.toString());
    }
  }

  Future<void> acceptRequest(int requestId, int providerId) async {
    try {
      await repository.acceptRequest(requestId);

      await getProviderRequests(providerId);
    } catch (e) {
      state = RequestError(e.toString());
    }
  }

  Future<void> rejectRequest(int requestId, int providerId) async {
    try {
      await repository.rejectRequest(requestId);

      await getProviderRequests(providerId);
    } catch (e) {
      state = RequestError(e.toString());
    }
  }

  Future<void> getProviderAvailability(int providerId) async {
    state = RequestLoading();

    try {
      final availability = await repository.getProviderAvailability(providerId);

      state = ProviderAvailabilityLoaded(availability);
    } catch (e) {
      state = RequestError(e.toString());
    }
  }

  Future<void> startRequest(int requestId, int providerId) async {
    try {
      await repository.startRequest(requestId);

      await getProviderRequests(providerId);
    } catch (e) {
      state = RequestError(e.toString());
    }
  }

  Future<void> completeRequest(int requestId, int providerId) async {
    try {
      await repository.completeRequest(requestId);

      await getProviderRequests(providerId);
    } catch (e) {
      state = RequestError(e.toString());
    }
  }
}

final requestProvider = StateNotifierProvider<RequestNotifier, RequestState>(
  (ref) => RequestNotifier(ref.read(requestRepositoryProvider)),
);
