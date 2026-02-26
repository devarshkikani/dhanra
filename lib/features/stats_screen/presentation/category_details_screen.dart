import 'package:dhanra/features/stats_screen/presentation/widget/category_details_utils.dart';
import 'package:dhanra/features/stats_screen/presentation/widget/summary_card.dart';
import 'package:dhanra/features/stats_screen/presentation/widget/transaction_list.dart';
import 'package:dhanra/features/stats_screen/presentation/widget/trend_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:dhanra/core/constants/category_keyword.dart';
import 'package:dhanra/features/transactions/bloc/transactions_bloc.dart';

class CategoryDetailsScreen extends StatefulWidget {
  final String category;
  final String period; // 'Weekly', 'Monthly', 'Yearly', 'Custom'
  final DateTime startDate;
  final DateTime endDate;
  final String type; // 'Credit' or 'Debit'

  const CategoryDetailsScreen({
    super.key,
    required this.category,
    required this.period,
    required this.startDate,
    required this.endDate,
    required this.type,
  });

  @override
  State<CategoryDetailsScreen> createState() => _CategoryDetailsScreenState();
}

class _CategoryDetailsScreenState extends State<CategoryDetailsScreen> {
  late String _currentPeriod;
  late DateTime _currentStartDate;
  late DateTime _currentEndDate;

  @override
  void initState() {
    super.initState();
    _currentPeriod = widget.period;
    _currentStartDate = widget.startDate;
    _currentEndDate = widget.endDate;
  }

  void _navigatePeriod(bool isPrevious) {
    final newKey = isPrevious
        ? CategoryDetailsUtils.getPreviousPeriod(
            _currentPeriod, _currentStartDate)
        : CategoryDetailsUtils.getNextPeriod(_currentPeriod, _currentStartDate);

    final dates = CategoryDetailsUtils.updatePeriodDates(
        _currentPeriod, newKey, _currentStartDate, _currentEndDate);

    setState(() {
      _currentStartDate = dates.start;
      _currentEndDate = dates.end;
    });

    context.read<TransactionsBloc>().add(
          LoadTransactions(
              startDate: _currentStartDate, endDate: _currentEndDate),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionsBloc, TransactionsState>(
      builder: (context, state) {
        final filteredTransactions = state.transactions.where((tx) {
          if (tx['category'] != widget.category || tx['type'] != widget.type) {
            return false;
          }
          final date = CategoryDetailsUtils.parseDate(tx['date']);
          return date != null &&
              !date.isBefore(_currentStartDate) &&
              !date.isAfter(_currentEndDate);
        }).toList();

        final stats = CategoryDetailsUtils.calculateStats(filteredTransactions);
        final periodData = CategoryDetailsUtils.groupByPeriod(
          filteredTransactions,
          _currentPeriod,
          _currentStartDate,
          _currentEndDate,
        );

        final chartMax = periodData.isEmpty
            ? 0.0
            : periodData.map((e) => e.value).reduce((a, b) => a > b ? a : b);

        final iconAndColor = CategoryKeyWord.getIconAndColor(widget.category);
        final catColor =
            CategoryKeyWord.parseHexColor(iconAndColor['color'] ?? '#2196F3');
        final catIcon = iconAndColor['icon'] ?? '';

        final banks = state.transactions
            .map((tx) => tx['bank'] as String? ?? '')
            .where((b) => b.isNotEmpty)
            .toSet()
            .toList()
          ..add('Cash');

        final total = filteredTransactions.fold(0.0,
            (a, tx) => a + (double.tryParse(tx['amount'].toString()) ?? 0.0));

        return Scaffold(
          appBar: _buildAppBar(catColor,
              isPrev: CategoryDetailsUtils.canGoToPrevious(
                  _currentPeriod, _currentStartDate),
              isNext: CategoryDetailsUtils.canGoToNext(
                  _currentPeriod, _currentEndDate),
              onPrev: () => _navigatePeriod(true),
              onNext: () => _navigatePeriod(false)),
          backgroundColor: Colors.transparent,
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SummaryCard(
                  catColor: catColor,
                  catIcon: catIcon,
                  stats: stats,
                  category: widget.category,
                  total: total,
                  min: filteredTransactions.isEmpty
                      ? 0.0
                      : filteredTransactions
                          .map((tx) =>
                              double.tryParse(tx['amount'].toString()) ?? 0.0)
                          .reduce((a, b) => a < b ? a : b),
                  max: filteredTransactions.isEmpty
                      ? 0.0
                      : filteredTransactions
                          .map((tx) =>
                              double.tryParse(tx['amount'].toString()) ?? 0.0)
                          .reduce((a, b) => a > b ? a : b),
                  avg: filteredTransactions.isEmpty
                      ? 0.0
                      : total / filteredTransactions.length,
                ),
                sectionTitle("Trend"),
                TrendChartUI(
                  periodData: periodData,
                  chartMax: chartMax,
                  catColor: catColor,
                ),
                sectionTitle("Transactions"),
                Expanded(
                  child: filteredTransactions.isEmpty
                      ? const Center(
                          child: Text("No transactions found",
                              style: TextStyle(color: Colors.white54)))
                      : TransactionList(
                          transactions: filteredTransactions,
                          banks: banks,
                          startDate: _currentStartDate,
                          lastDate: _currentEndDate,
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(Color catColor,
      {required bool isPrev,
      required bool isNext,
      required VoidCallback onPrev,
      required VoidCallback onNext}) {
    return AppBar(
      titleSpacing: 0,
      backgroundColor: Colors.black,
      centerTitle: false,
      title: Text(
        widget.category,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      ),
      actions: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left, color: Colors.white),
              onPressed: isPrev ? onPrev : null,
            ),
            Text(
              CategoryDetailsUtils.getPeriodLabel(
                  _currentPeriod, _currentStartDate, _currentEndDate),
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right, color: Colors.white),
              onPressed: isNext ? onNext : null,
            ),
          ],
        ),
      ],
    );
  }

  Widget sectionTitle(String title) {
    return Column(
      children: [
        Text(title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
      ],
    );
  }
}
