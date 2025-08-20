import 'package:equatable/equatable.dart';

enum SmsFetchingStatus { initial, loading, success, failure }

class SmsFetchingFeaturesState extends Equatable {
  final SmsFetchingStatus status;
  final int totalSmsCount;
  final int processedSmsCount;
  // final int creditedMessagesCount;
  // final int debitedMessagesCount;
  // final double totalCreditedAmount;
  // final double totalDebitedAmount;
  // final double netAmount;
  final String statusMessage;
  final List<Map<String, String>> transactionMessages;

  const SmsFetchingFeaturesState({
    this.status = SmsFetchingStatus.initial,
    this.totalSmsCount = 0,
    this.processedSmsCount = 0,
    // this.creditedMessagesCount = 0,
    // this.debitedMessagesCount = 0,
    // this.totalCreditedAmount = 0.0,
    // this.totalDebitedAmount = 0.0,
    // this.netAmount = 0.0,
    this.statusMessage = '',
    this.transactionMessages = const [],
  });

  SmsFetchingFeaturesState copyWith({
    SmsFetchingStatus? status,
    int? totalSmsCount,
    int? processedSmsCount,
    // int? creditedMessagesCount,
    // int? debitedMessagesCount,
    // double? totalCreditedAmount,
    // double? totalDebitedAmount,
    // double? netAmount,
    String? statusMessage,
    List<Map<String, String>>? transactionMessages,
  }) {
    return SmsFetchingFeaturesState(
      status: status ?? this.status,
      totalSmsCount: totalSmsCount ?? this.totalSmsCount,
      processedSmsCount: processedSmsCount ?? this.processedSmsCount,
      // creditedMessagesCount:
      //     creditedMessagesCount ?? this.creditedMessagesCount,
      // debitedMessagesCount: debitedMessagesCount ?? this.debitedMessagesCount,
      // totalCreditedAmount: totalCreditedAmount ?? this.totalCreditedAmount,
      // totalDebitedAmount: totalDebitedAmount ?? this.totalDebitedAmount,
      // netAmount: netAmount ?? this.netAmount,
      statusMessage: statusMessage ?? this.statusMessage,
      transactionMessages: transactionMessages ?? this.transactionMessages,
    );
  }

  @override
  List<Object?> get props => [
        status,
        totalSmsCount,
        processedSmsCount,
        // creditedMessagesCount,
        // debitedMessagesCount,
        // totalCreditedAmount,
        // totalDebitedAmount,
        // netAmount,
        statusMessage,
        transactionMessages,
      ];
}
