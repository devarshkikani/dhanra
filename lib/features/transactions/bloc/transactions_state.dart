part of 'transactions_bloc.dart';

enum TransactionsStatus { initial, loading, success, failure }

class TransactionsState extends Equatable {
  final TransactionsStatus status;
  final List<String> availableMonths;
  final String currentMonth;
  final List<Map<String, dynamic>> transactions;
  final int creditedCount;
  final int debitedCount;
  final double totalCreditedAmount;
  final double totalDebitedAmount;
  final double netAmount;
  final String statusMessage;

  const TransactionsState({
    this.status = TransactionsStatus.initial,
    this.statusMessage = '',
    this.availableMonths = const [],
    this.currentMonth = '',
    this.transactions = const [],
    this.creditedCount = 0,
    this.debitedCount = 0,
    this.totalCreditedAmount = 0.0,
    this.totalDebitedAmount = 0.0,
    this.netAmount = 0.0,
  });

  TransactionsState copyWith({
    TransactionsStatus? status,
    String? statusMessage,
    List<String>? availableMonths,
    String? currentMonth,
    List<Map<String, dynamic>>? transactions,
    int? creditedCount,
    int? debitedCount,
    double? totalCreditedAmount,
    double? totalDebitedAmount,
    double? netAmount,
  }) {
    return TransactionsState(
      status: status ?? this.status,
      statusMessage: statusMessage ?? this.statusMessage,
      availableMonths: availableMonths ?? this.availableMonths,
      currentMonth: currentMonth ?? this.currentMonth,
      transactions: transactions ?? this.transactions,
      creditedCount: creditedCount ?? this.creditedCount,
      debitedCount: debitedCount ?? this.debitedCount,
      totalCreditedAmount: totalCreditedAmount ?? this.totalCreditedAmount,
      totalDebitedAmount: totalDebitedAmount ?? this.totalDebitedAmount,
      netAmount: netAmount ?? this.netAmount,
    );
  }

  @override
  List<Object> get props => [
        status,
        statusMessage,
        availableMonths,
        currentMonth,
        transactions,
        creditedCount,
        debitedCount,
        totalCreditedAmount,
        totalDebitedAmount,
        netAmount,
      ];
}
