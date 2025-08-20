import 'package:equatable/equatable.dart';

enum DashboardStatus { initial, loading, success, failure }

class DashboardState extends Equatable {
  final DashboardStatus status;
  final int totalSmsCount;
  final int creditedMessagesCount;
  final int debitedMessagesCount;
  final double totalCreditedAmount;
  final double totalDebitedAmount;
  final double netAmount;
  final String statusMessage;
  final List<Map<String, dynamic>> transactionMessages;
  final List<Map<String, dynamic>> accountSummaries;

  const DashboardState({
    this.status = DashboardStatus.initial,
    this.totalSmsCount = 0,
    this.creditedMessagesCount = 0,
    this.debitedMessagesCount = 0,
    this.totalCreditedAmount = 0.0,
    this.totalDebitedAmount = 0.0,
    this.netAmount = 0.0,
    this.statusMessage = '',
    this.transactionMessages = const [],
    this.accountSummaries = const [],
  });

  DashboardState copyWith({
    DashboardStatus? status,
    int? totalSmsCount,
    int? creditedMessagesCount,
    int? debitedMessagesCount,
    double? totalCreditedAmount,
    double? totalDebitedAmount,
    double? netAmount,
    String? statusMessage,
    List<Map<String, dynamic>>? transactionMessages,
    List<Map<String, dynamic>>? accountSummaries,
  }) {
    return DashboardState(
      status: status ?? this.status,
      totalSmsCount: totalSmsCount ?? this.totalSmsCount,
      creditedMessagesCount:
          creditedMessagesCount ?? this.creditedMessagesCount,
      debitedMessagesCount: debitedMessagesCount ?? this.debitedMessagesCount,
      totalCreditedAmount: totalCreditedAmount ?? this.totalCreditedAmount,
      totalDebitedAmount: totalDebitedAmount ?? this.totalDebitedAmount,
      netAmount: netAmount ?? this.netAmount,
      statusMessage: statusMessage ?? this.statusMessage,
      transactionMessages: transactionMessages ?? this.transactionMessages,
      accountSummaries: accountSummaries ?? this.accountSummaries,
    );
  }

  @override
  List<Object?> get props => [
        status,
        totalSmsCount,
        creditedMessagesCount,
        debitedMessagesCount,
        totalCreditedAmount,
        totalDebitedAmount,
        netAmount,
        statusMessage,
        transactionMessages,
        accountSummaries,
      ];
}
