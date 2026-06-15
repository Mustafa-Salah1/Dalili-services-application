import '../../data/models/request_model.dart';

abstract class RequestRepository {
Future<RequestModel> createRequest({
required int providerId,
required String requestDate,
required String notes,
});

Future<List<RequestModel>> getMyRequests();

Future<List<RequestModel>> getProviderRequests(
int providerId,
);

Future<void> acceptRequest(
int requestId,
);

Future<void> rejectRequest(
int requestId,
);
}
