import '../../data/models/admin_application_model.dart';

abstract class AdminState {}

class AdminInitial extends AdminState {}

class AdminLoading extends AdminState {}

class AdminLoaded extends AdminState {
  final List<AdminApplicationModel> applications;

  AdminLoaded(this.applications);
}

class AdminError extends AdminState {
  final String message;

  AdminError(this.message);
}
