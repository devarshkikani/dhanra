import 'package:another_telephony/telephony.dart';
import 'package:dhanra/core/services/sms_parser_service.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'transaction_state.dart';

class TransactionCubit extends HydratedCubit<TransactionState> {
  TransactionCubit() : super(const TransactionState());

  final Telephony _telephony = Telephony.instance;
  final SmsParserService _smsParserService = SmsParserService.instance;

  Future<void> fetchAndProcessSms() async {
    try {
      emit(state.copyWith(
        status: TransactionStatus.loading,
        statusMessage: 'Starting SMS fetch...',
      ));

      final bool? permissionsGranted =
          await _telephony.requestPhoneAndSmsPermissions;

      if (permissionsGranted != true) {
        throw Exception('SMS permissions not granted');
      }

      final List<SmsMessage> messages = await _telephony.getInboxSms(
        columns: [
          SmsColumn.ID,
          SmsColumn.ADDRESS,
          SmsColumn.BODY,
          SmsColumn.DATE
        ],
      );

      emit(state.copyWith(
        totalSmsCount: messages.length,
        statusMessage: 'Found ${messages.length} messages',
      ));

      final transactions =
          await _smsParserService.parseTransactionMessagesFlexible(
        messages,
        batchSize: 50,
        onProgress: (processed, total, found) {
          emit(state.copyWith(
            processedSmsCount: processed,
            statusMessage:
                'Analyzing messages: $processed/$total (Found $found transactions)',
          ));
        },
      );

      _finalizeTransactionProcessing(transactions);
    } catch (e) {
      emit(state.copyWith(
        status: TransactionStatus.failure,
        statusMessage: 'Error fetching SMS: $e',
      ));
    }
  }

  void _finalizeTransactionProcessing(List<Map<String, String>> messages) {
    final credited = messages.where((m) => m['type'] == 'Credit').length;
    final debited = messages.where((m) => m['type'] == 'Debit').length;
    final totalCredited = _smsParserService.getTotalCreditedAmount(messages);
    final totalDebited = _smsParserService.getTotalDebitedAmount(messages);
    final netAmount = totalCredited - totalDebited;

    emit(state.copyWith(
      status: TransactionStatus.success,
      transactionMessages: messages,
      creditedMessagesCount: credited,
      debitedMessagesCount: debited,
      totalCreditedAmount: totalCredited,
      totalDebitedAmount: totalDebited,
      netAmount: netAmount,
      statusMessage:
          'Found ${messages.length} transaction messages ($credited credits, $debited debits)',
    ));
  }

  @override
  TransactionState? fromJson(Map<String, dynamic> json) {
    try {
      return TransactionState.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  @override
  Map<String, dynamic>? toJson(TransactionState state) {
    if (state.status == TransactionStatus.success) {
      return state.toJson();
    }
    return null;
  }
}
