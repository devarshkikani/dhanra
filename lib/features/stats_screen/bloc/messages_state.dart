import 'package:equatable/equatable.dart';

enum MessagesStatus { initial, loading, success, failure }

class MessagesState extends Equatable {
  final MessagesStatus status;
  final String statusMessage;
  final List<Map<String, String>> transactionMessages;

  const MessagesState({
    this.status = MessagesStatus.initial,
    this.statusMessage = '',
    this.transactionMessages = const [],
  });

  MessagesState copyWith({
    MessagesStatus? status,
    String? statusMessage,
    List<Map<String, String>>? transactionMessages,
  }) {
    return MessagesState(
      status: status ?? this.status,
      statusMessage: statusMessage ?? this.statusMessage,
      transactionMessages: transactionMessages ?? this.transactionMessages,
    );
  }

  @override
  List<Object?> get props => [status, statusMessage, transactionMessages];
}
