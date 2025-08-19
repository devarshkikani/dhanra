import 'package:equatable/equatable.dart';

enum TransactionStatus { initial, loading, success, failure }

class TransactionState extends Equatable {
  const TransactionState({
    this.status = TransactionStatus.initial,
    this.totalSmsCount = 0,
    this.processedSmsCount = 0,
    this.creditedMessagesCount = 0,
    this.debitedMessagesCount = 0,
    this.totalCreditedAmount = 0.0,
    this.totalDebitedAmount = 0.0,
    this.netAmount = 0.0,
    this.statusMessage = '',
    this.transactionMessages = const [],
  });

  final TransactionStatus status;
  final int totalSmsCount;
  final int processedSmsCount;
  final int creditedMessagesCount;
  final int debitedMessagesCount;
  final double totalCreditedAmount;
  final double totalDebitedAmount;
  final double netAmount;
  final String statusMessage;
  final List<Map<String, String>> transactionMessages;

  TransactionState copyWith({
    TransactionStatus? status,
    int? totalSmsCount,
    int? processedSmsCount,
    int? creditedMessagesCount,
    int? debitedMessagesCount,
    double? totalCreditedAmount,
    double? totalDebitedAmount,
    double? netAmount,
    String? statusMessage,
    List<Map<String, String>>? transactionMessages,
  }) {
    return TransactionState(
      status: status ?? this.status,
      totalSmsCount: totalSmsCount ?? this.totalSmsCount,
      processedSmsCount: processedSmsCount ?? this.processedSmsCount,
      creditedMessagesCount:
          creditedMessagesCount ?? this.creditedMessagesCount,
      debitedMessagesCount: debitedMessagesCount ?? this.debitedMessagesCount,
      totalCreditedAmount: totalCreditedAmount ?? this.totalCreditedAmount,
      totalDebitedAmount: totalDebitedAmount ?? this.totalDebitedAmount,
      netAmount: netAmount ?? this.netAmount,
      statusMessage: statusMessage ?? this.statusMessage,
      transactionMessages: transactionMessages ?? this.transactionMessages,
    );
  }

  factory TransactionState.fromJson(Map<String, dynamic> json) {
    return TransactionState(
      status: TransactionStatus.success,
      totalSmsCount: json['totalSmsCount'] as int,
      creditedMessagesCount: json['creditedMessagesCount'] as int,
      debitedMessagesCount: json['debitedMessagesCount'] as int,
      totalCreditedAmount: json['totalCreditedAmount'] as double,
      totalDebitedAmount: json['totalDebitedAmount'] as double,
      netAmount: json['netAmount'] as double,
      transactionMessages: (json['transactionMessages'] as List)
          .map((e) => Map<String, String>.from(e as Map))
          .toList(),
      statusMessage: 'Loaded from cache',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalSmsCount': totalSmsCount,
      'creditedMessagesCount': creditedMessagesCount,
      'debitedMessagesCount': debitedMessagesCount,
      'totalCreditedAmount': totalCreditedAmount,
      'totalDebitedAmount': totalDebitedAmount,
      'netAmount': netAmount,
      'transactionMessages': transactionMessages,
    };
  }

  @override
  List<Object?> get props => [
        status,
        totalSmsCount,
        processedSmsCount,
        creditedMessagesCount,
        debitedMessagesCount,
        totalCreditedAmount,
        totalDebitedAmount,
        netAmount,
        statusMessage,
        transactionMessages,
      ];
}
