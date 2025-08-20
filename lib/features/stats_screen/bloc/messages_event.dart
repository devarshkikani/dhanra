import 'package:equatable/equatable.dart';

abstract class MessagesEvent extends Equatable {
  const MessagesEvent();

  @override
  List<Object?> get props => [];
}

class LoadMessagesData extends MessagesEvent {
  final String month;
  const LoadMessagesData(this.month);

  @override
  List<Object?> get props => [month];
}
