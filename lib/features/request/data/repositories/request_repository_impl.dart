import '../../domain/repositories/request_repository.dart';

import '../datasources/request_remote_data_source.dart';
import '../models/request_model.dart';

class RequestRepositoryImpl implements RequestRepository {
  final RequestRemoteDataSource remoteDataSource;

  RequestRepositoryImpl(this.remoteDataSource);

  @override
  Future<RequestModel> createRequest({
    required int providerId,
    required String requestDate,
    required String notes,
  }) async {
    final response = await remoteDataSource.createRequest(
      providerId: providerId,
      requestDate: requestDate,
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
}
