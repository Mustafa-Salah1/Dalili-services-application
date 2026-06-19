import '../../domain/repositories/request_repository.dart';

import '../datasources/request_remote_data_source.dart';
import '../models/request_model.dart';
import '../models/provider_availability_model.dart';

class RequestRepositoryImpl implements RequestRepository {
  final RequestRemoteDataSource remoteDataSource;

  RequestRepositoryImpl(this.remoteDataSource);

  @override
  Future<RequestModel> createRequest({
    required int providerId,
    required String requestDate,
    required String requestTime,
    required int estimatedDurationMinutes,
    required String notes,
  }) async {
    final response = await remoteDataSource.createRequest(
      providerId: providerId,
      requestDate: requestDate,
      requestTime: requestTime,
      estimatedDurationMinutes: estimatedDurationMinutes,
      notes: notes,
    );

    return RequestModel.fromJson(response.data);
  }

  @override
  Future<List<RequestModel>> getMyRequests() async {
    final response = await remoteDataSource.getMyRequests();

    return (response.data as List)
        .map((request) => RequestModel.fromJson(request))
        .toList();
  }

  @override
  Future<List<RequestModel>> getProviderRequests(int providerId) async {
    final response = await remoteDataSource.getProviderRequests(providerId);

    return (response.data as List)
        .map((request) => RequestModel.fromJson(request))
        .toList();
  }

  @override
  Future<void> acceptRequest(int requestId) async {
    await remoteDataSource.acceptRequest(requestId);
  }

  @override
  Future<void> rejectRequest(int requestId) async {
    await remoteDataSource.rejectRequest(requestId);
  }

  @override
  Future<ProviderAvailabilityModel> getProviderAvailability(
    int providerId,
  ) async {
    final response = await remoteDataSource.getProviderAvailability(providerId);

    return ProviderAvailabilityModel.fromJson(response.data);
  }

  @override
  Future<void> startRequest(int requestId) async {
    await remoteDataSource.startRequest(requestId);
  }

  @override
  Future<void> completeRequest(int requestId) async {
    await remoteDataSource.completeRequest(requestId);
  }
}
