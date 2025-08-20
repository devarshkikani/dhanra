import 'package:dhanra/core/services/local_storage_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'dashboard_event.dart';
import 'dashboard_state.dart';
import 'package:dhanra/core/services/sms_parser_service.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final SmsParserService _smsParserService = SmsParserService.instance;
  final LocalStorageService _storage = LocalStorageService();

  DashboardBloc() : super(const DashboardState()) {
    on<FetchDashboardSms>(_onFetchDashboardSms);
  }

  Future<void> _onFetchDashboardSms(
    FetchDashboardSms event,
    Emitter<DashboardState> emit,
  ) async {
    try {
      emit(state.copyWith(
        status: DashboardStatus.loading,
        statusMessage: 'Fetching SMS...',
      ));

      // Get monthly data for dashboard metrics
      final List<Map<String, dynamic>> monthlyMessages =
          _storage.getMonthlyData(event.month ?? '');

      // Get all available data for account summaries (all-time)
      final List<Map<String, dynamic>> allTimeMessages = _getAllTimeMessages();

      // Calculate monthly metrics
      final credited =
          monthlyMessages.where((m) => m['type'] == 'Credit').length;
      final debited = monthlyMessages.where((m) => m['type'] == 'Debit').length;
      final totalCredited =
          _smsParserService.getTotalCreditedAmount(monthlyMessages);
      final totalDebited =
          _smsParserService.getTotalDebitedAmount(monthlyMessages);
      final netAmount = totalCredited - totalDebited;

      // Generate account summaries from all-time data
      final accountSummaries =
          _smsParserService.generateAccountSummaries(allTimeMessages);

      emit(state.copyWith(
        totalSmsCount: monthlyMessages.length,
        transactionMessages: monthlyMessages,
        creditedMessagesCount: credited,
        debitedMessagesCount: debited,
        totalCreditedAmount: totalCredited,
        totalDebitedAmount: totalDebited,
        netAmount: netAmount,
        accountSummaries: accountSummaries,
        status: DashboardStatus.success,
        statusMessage: 'Found ${monthlyMessages.length} messages',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: DashboardStatus.failure,
        statusMessage: 'Error: $e',
      ));
    }
  }

  // Helper method to get all available transaction data
  List<Map<String, dynamic>> _getAllTimeMessages() {
    final List<Map<String, dynamic>> allMessages = [];

    // Get all available months
    final availableMonths = _storage.getAvailableMonths();

    // Collect messages from all months
    for (final month in availableMonths) {
      final monthlyData = _storage.getMonthlyData(month);
      allMessages.addAll(monthlyData);
    }

    return allMessages;
  }
}
