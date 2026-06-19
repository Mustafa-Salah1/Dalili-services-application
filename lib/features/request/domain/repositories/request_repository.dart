import '../../data/models/provider_availability_model.dart';
import '../../data/models/request_model.dart';

abstract class RequestRepository {
  Future<RequestModel> createRequest({
    required int providerId,
    required String requestDate,
    required String notes,
    required String requestTime,
    required int estimatedDurationMinutes,
  });

  Future<List<RequestModel>> getMyRequests();

  Future<List<RequestModel>> getProviderRequests(int providerId);

  Future<void> acceptRequest(int requestId);

  Future<void> rejectRequest(int requestId);

  Future<ProviderAvailabilityModel> getProviderAvailability(int providerId);
  
  Future<void> startRequest(int requestId);

  Future<void> completeRequest(int requestId);
}
