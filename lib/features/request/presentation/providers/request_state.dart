import '../../data/models/request_model.dart';

abstract class RequestState {}

class RequestInitial extends RequestState {}

class RequestLoading extends RequestState {}

class RequestSuccess extends RequestState {
  final RequestModel request;

  RequestSuccess(this.request);
}

class MyRequestsLoaded extends RequestState {
  final List<RequestModel> requests;

  MyRequestsLoaded(this.requests);
}

class ProviderRequestsLoaded extends RequestState {
  final List<RequestModel> requests;

  ProviderRequestsLoaded(this.requests);
}

class RequestError extends RequestState {
  final String message;

  RequestError(this.message);
}
