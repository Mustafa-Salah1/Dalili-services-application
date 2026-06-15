import '../../data/models/provider_application_model.dart';

abstract class ProviderApplicationState {}

class ProviderApplicationInitial extends ProviderApplicationState {}

class ProviderApplicationLoading extends ProviderApplicationState {}

class NoProviderApplication extends ProviderApplicationState {}

class ProviderApplicationSuccess extends ProviderApplicationState {
  final ProviderApplicationModel application;

  ProviderApplicationSuccess(this.application);
}

class ProviderApplicationError extends ProviderApplicationState {
  final String message;

  ProviderApplicationError(this.message);
}
