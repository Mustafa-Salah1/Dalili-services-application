import '../../data/models/provider_model.dart';

abstract class ProviderState {}

class ProviderInitial extends ProviderState {}

class ProviderLoading extends ProviderState {}

class ProviderLoaded extends ProviderState {
  final List<ProviderModel> providers;

  ProviderLoaded(this.providers);
}

class MyProviderLoaded extends ProviderState {
  final ProviderModel provider;

  MyProviderLoaded(this.provider);
}

class ProviderError extends ProviderState {
  final String message;

  ProviderError(this.message);
}
