import 'package:another_telephony/telephony.dart';
import 'package:dhanra/core/services/local_storage_service.dart';
import 'package:dhanra/core/services/sms_parser_service.dart';
import 'package:dhanra/features/sms_fetching/bloc/sms_fetching_features_event.dart';
import 'package:dhanra/features/sms_fetching/bloc/sms_fetching_features_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

class SmsFetchingFeaturesBloc
    extends Bloc<SmsFetchingFeaturesEvent, SmsFetchingFeaturesState> {
  final Telephony _telephony = Telephony.instance;
  final SmsParserService _smsParserService = SmsParserService.instance;
  final LocalStorageService _storage = LocalStorageService();

  SmsFetchingFeaturesBloc() : super(const SmsFetchingFeaturesState()) {
    on<StartSmsFetching>(_onStartSmsFetching);
  }

  Future<void> _onStartSmsFetching(
    StartSmsFetching event,
    Emitter<SmsFetchingFeaturesState> emit,
  ) async {
    try {
      emit(state.copyWith(
        status: SmsFetchingStatus.loading,
        statusMessage: 'Starting SMS fetch...',
      ));

      if (!event.hasPermissions) {
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

      List<Map<String, String>> transactionData =
          await _smsParserService.parseTransactionMessagesFlexible(
        messages,
        onProgress: (processed, total, found, month, results) {
          _storage.saveMonthlyData(month, results);
          emit(state.copyWith(
            processedSmsCount: processed,
            statusMessage:
                'Analyzing messages: $processed/$total (Found $found transactions)',
          ));
        },
      );

      _storage.saveTransactionData(transactionData);
      emit(state.copyWith(
          status: SmsFetchingStatus.success,
          statusMessage: 'Found ${messages.length} transaction messages'));
    } catch (e) {
      emit(state.copyWith(
        status: SmsFetchingStatus.failure,
        statusMessage: 'Error fetching SMS: $e',
      ));
    }
  }

//   void _finalizeTransactionProcessing(
//       String month,
//       List<Map<String, String>> messages,
//       Emitter<SmsFetchingFeaturesState> emit) {
//     final credited = messages.where((m) => m['type'] == 'Credit').length;
//     final debited = messages.where((m) => m['type'] == 'Debit').length;
//     _storage.saveMonthlyData(month, messages);

//     // final totalCredited = _smsParserService.getTotalCreditedAmount(messages);
//     // final totalDebited = _smsParserService.getTotalDebitedAmount(messages);
//     // final netAmount = totalCredited - totalDebited;

//     emit(state.copyWith(
//       status: SmsFetchingStatus.success,
//       transactionMessages: messages,
//       // creditedMessagesCount: credited,
//       // debitedMessagesCount: debited,
//       // totalCreditedAmount: totalCredited,
//       // totalDebitedAmount: totalDebited,
//       // netAmount: netAmount,
  // statusMessage:
  //     'Found ${messages.length} transaction messages ($credited credits, $debited debits)',
//     ));
//   }
}
