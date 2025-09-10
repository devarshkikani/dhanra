import 'package:dhanra/core/services/local_storage_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dhanra/core/services/sms_parser_service.dart';
import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';

part 'transactions_event.dart';
part 'transactions_state.dart';

class TransactionsBloc extends Bloc<TransactionsEvent, TransactionsState> {
  final SmsParserService _smsParserService = SmsParserService.instance;
  final LocalStorageService _storage = LocalStorageService();

  TransactionsBloc() : super(const TransactionsState()) {
    on<LoadTransactions>(_onLoadTransactions);
    on<ChangeMonth>(_onChangeMonth);
    on<AddTransaction>(_onAddTransaction);
    on<UpdateTransaction>(_onUpdateTransaction);
    on<DeleteTransaction>(_onDeleteTransaction);
    on<BulkUpdateTransactionsByUpiId>(_onBulkUpdateTransactionsByUpiId);
  }

  Future<void> _onAddTransaction(
    AddTransaction event,
    Emitter<TransactionsState> emit,
  ) async {
    try {
      // Save the new transaction to local storage
      _storage.addTransaction(event.transaction);

      // Reload all transactions to reflect the new addition
      await _onLoadTransactions(const LoadTransactions(), emit);
    } catch (e) {
      emit(state.copyWith(
        status: TransactionsStatus.failure,
        statusMessage: 'Error adding transaction: $e',
      ));
    }
  }

  Future<void> _onLoadTransactions(
    LoadTransactions event,
    Emitter<TransactionsState> emit,
  ) async {
    try {
      emit(state.copyWith(
        status: TransactionsStatus.loading,
        statusMessage: 'Loading transactions...',
      ));

      // Get all available months
      final availableMonths = _storage.getAvailableMonths();

      // Sort months in descending order (latest first)
      availableMonths.sort((a, b) => b.compareTo(a));

      // Set current month to the selected period's month if provided, else latest available month
      String currentMonth =
          availableMonths.isNotEmpty ? availableMonths.first : '';

      // Initialize list to collect all transactions
      List<Map<String, dynamic>> allTransactions = [];

      if (event.startDate != null && event.endDate != null) {
        // Start from the startDate
        DateTime current =
            DateTime(event.startDate!.year, event.startDate!.month);

        // Loop until the current month is after endDate
        while (current.isBefore(event.endDate!) ||
            (current.year == event.endDate!.year &&
                current.month == event.endDate!.month)) {
          String monthKey = DateFormat('yyyy-MM').format(current);
          var monthlyData = _storage.getMonthlyData(monthKey);

          if (monthlyData.isNotEmpty) {
            allTransactions.addAll(monthlyData);
          }

          // Move to the next month
          current = DateTime(current.year, current.month + 1);
        }
      } else {
        var transactions = _storage.getMonthlyData(currentMonth);
        if (transactions.isNotEmpty) {
          allTransactions.addAll(transactions);
        }
      }

      // Filter by date range if provided
      if (event.startDate != null && event.endDate != null) {
        allTransactions = allTransactions.where((tx) {
          final dateValue = tx['date'];
          DateTime? date;
          if (dateValue is int) {
            date = DateTime.fromMillisecondsSinceEpoch(dateValue);
          } else if (dateValue is String) {
            try {
              date = DateTime.fromMillisecondsSinceEpoch(int.parse(dateValue));
            } catch (_) {
              date = null;
            }
          }
          if (date == null) return false;
          return !date.isBefore(event.startDate!) &&
              !date.isAfter(event.endDate!);
        }).toList();
      }

      // Calculate monthly statistics
      final credited =
          allTransactions.where((m) => m['type'] == 'Credit').length;
      final debited = allTransactions.where((m) => m['type'] == 'Debit').length;
      final totalCredited =
          _smsParserService.getTotalCreditedAmount(allTransactions);
      final totalDebited =
          _smsParserService.getTotalDebitedAmount(allTransactions);
      final netAmount = totalCredited - totalDebited;

      emit(state.copyWith(
        availableMonths: availableMonths,
        currentMonth: currentMonth,
        transactions: allTransactions,
        creditedCount: credited,
        debitedCount: debited,
        totalCreditedAmount: totalCredited,
        totalDebitedAmount: totalDebited,
        netAmount: netAmount,
        status: TransactionsStatus.success,
        statusMessage: 'Loaded ${allTransactions.length} transactions',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: TransactionsStatus.failure,
        statusMessage: 'Error: $e',
      ));
    }
  }

  Future<void> _onChangeMonth(
    ChangeMonth event,
    Emitter<TransactionsState> emit,
  ) async {
    try {
      final monthKey = DateFormat('yyyy-MM').format(event.newMonth);
      emit(state.copyWith(
        status: TransactionsStatus.loading,
        statusMessage: 'Loading $monthKey transactions...',
      ));

      // Get transactions for selected month
      final transactions = _storage.getMonthlyData(monthKey);

      // Calculate monthly statistics
      final credited = transactions.where((m) => m['type'] == 'Credit').length;
      final debited = transactions.where((m) => m['type'] == 'Debit').length;
      final totalCredited =
          _smsParserService.getTotalCreditedAmount(transactions);
      final totalDebited =
          _smsParserService.getTotalDebitedAmount(transactions);
      final netAmount = totalCredited - totalDebited;

      emit(state.copyWith(
        currentMonth: monthKey,
        transactions: transactions,
        creditedCount: credited,
        debitedCount: debited,
        totalCreditedAmount: totalCredited,
        totalDebitedAmount: totalDebited,
        netAmount: netAmount,
        status: TransactionsStatus.success,
        statusMessage:
            'Loaded ${transactions.length} transactions for $monthKey',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: TransactionsStatus.failure,
        statusMessage: 'Error: $e',
      ));
    }
  }

  Future<void> _onUpdateTransaction(
    UpdateTransaction event,
    Emitter<TransactionsState> emit,
  ) async {
    try {
      await _storage.updateTransaction(event.transaction);
      await _onLoadTransactions(const LoadTransactions(), emit);
    } catch (e) {
      emit(state.copyWith(
        status: TransactionsStatus.failure,
        statusMessage: 'Error updating transaction: $e',
      ));
    }
  }

  Future<void> _onDeleteTransaction(
    DeleteTransaction event,
    Emitter<TransactionsState> emit,
  ) async {
    try {
      // We need the month to know which list to modify in storage.
      // The current state holds the currently viewed month.
      await _storage.deleteTransaction(event.transactionId, state.currentMonth);
      await _onLoadTransactions(const LoadTransactions(), emit);
    } catch (e) {
      emit(state.copyWith(
        status: TransactionsStatus.failure,
        statusMessage: 'Error deleting transaction: $e',
      ));
    }
  }

  Future<void> _onBulkUpdateTransactionsByUpiId(
    BulkUpdateTransactionsByUpiId event,
    Emitter<TransactionsState> emit,
  ) async {
    try {
      emit(state.copyWith(
        status: TransactionsStatus.loading,
        statusMessage: 'Updating transactions...',
      ));

      // Get all available months
      final availableMonths = _storage.getAvailableMonths();
      int updatedCount = 0;

      // Update transactions in all months
      for (final month in availableMonths) {
        final monthlyData = _storage.getMonthlyData(month);
        bool monthUpdated = false;

        for (int i = 0; i < monthlyData.length; i++) {
          final transaction = monthlyData[i];
          if (transaction['upiIdOrSenderName'] == event.upiIdOrSenderName &&
              transaction['category'] == 'Miscellaneous') {
            monthlyData[i] = {
              ...transaction,
              'category': event.newCategory,
            };
            monthUpdated = true;
            updatedCount++;
          }
        }

        // Save the updated month data if any transactions were updated
        if (monthUpdated) {
          await _storage.saveMonthlyData(month, monthlyData);
        }
      }

      // Reload all transactions to reflect the changes
      await _onLoadTransactions(const LoadTransactions(), emit);

      emit(state.copyWith(
        status: TransactionsStatus.success,
        statusMessage: 'Updated $updatedCount transactions',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: TransactionsStatus.failure,
        statusMessage: 'Error updating transactions: $e',
      ));
    }
  }
}
