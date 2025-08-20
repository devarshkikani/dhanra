import 'package:equatable/equatable.dart';

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

class FetchDashboardSms extends DashboardEvent {
  final String? month;
  const FetchDashboardSms({this.month});

  @override
  List<Object?> get props => [month];
}
