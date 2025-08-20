import 'package:equatable/equatable.dart';

abstract class SmsFetchingFeaturesEvent extends Equatable {
  const SmsFetchingFeaturesEvent();

  @override
  List<Object?> get props => [];
}

class StartSmsFetching extends SmsFetchingFeaturesEvent {
  final bool hasPermissions;
  const StartSmsFetching(this.hasPermissions);

  @override
  List<Object?> get props => [hasPermissions];
}
