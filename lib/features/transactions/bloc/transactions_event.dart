part of 'transactions_bloc.dart';

abstract class TransactionsEvent extends Equatable {
  const TransactionsEvent();

  @override
  List<Object?> get props => [];
}

class LoadTransactions extends TransactionsEvent {
  final DateTime? startDate;
  final DateTime? endDate;

  const LoadTransactions({this.startDate, this.endDate});

  @override
  List<Object?> get props => [startDate, endDate];
}

class AddTransaction extends TransactionsEvent {
  final Map<String, dynamic> transaction;

  const AddTransaction(this.transaction);

  @override
  List<Object> get props => [transaction];
}

class UpdateTransaction extends TransactionsEvent {
  final Map<String, dynamic> transaction;

  const UpdateTransaction(this.transaction);

  @override
  List<Object> get props => [transaction];
}

class DeleteTransaction extends TransactionsEvent {
  final String transactionId;

  const DeleteTransaction(this.transactionId);

  @override
  List<Object> get props => [transactionId];
}

class ChangeMonth extends TransactionsEvent {
  final DateTime newMonth;

  const ChangeMonth(this.newMonth);

  @override
  List<Object?> get props => [newMonth];
}

class BulkUpdateTransactionsByUpiId extends TransactionsEvent {
  final String upiIdOrSenderName;
  final String newCategory;

  const BulkUpdateTransactionsByUpiId({
    required this.upiIdOrSenderName,
    required this.newCategory,
  });

  @override
  List<Object> get props => [upiIdOrSenderName, newCategory];
}
