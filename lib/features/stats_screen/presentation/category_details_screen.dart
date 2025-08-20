import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:dhanra/core/constants/category_keyword.dart';
import 'package:dhanra/core/utils/date_formatter.dart';
import 'package:dhanra/features/transactions/presentation/add_edit_transaction_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dhanra/features/transactions/bloc/transactions_bloc.dart';
import 'dart:ui';

import 'package:intl/intl.dart';

class CategoryDetailsScreen extends StatefulWidget {
  final String category;
  final String period; // 'Weekly', 'Monthly', 'Yearly', 'Custom'
  final DateTime startDate;
  final DateTime endDate;
  final String type; // 'Credit' or 'Debit'

  const CategoryDetailsScreen({
    Key? key,
    required this.category,
    required this.period,
    required this.startDate,
    required this.endDate,
    required this.type,
  }) : super(key: key);

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

  bool _canGoToPreviousPeriod() {
    // For now, allow navigation back to reasonable limits
    if (_currentPeriod == 'Weekly') {
      return _currentStartDate.isAfter(DateTime(2020));
    } else if (_currentPeriod == 'Monthly') {
      return _currentStartDate.isAfter(DateTime(2020, 1, 1));
    } else if (_currentPeriod == 'Yearly') {
      return _currentStartDate.year > 2020;
    }
    return true;
  }

  bool _canGoToNextPeriod() {
    // Don't allow going beyond current date
    DateTime now = DateTime.now();
    if (_currentPeriod == 'Weekly') {
      return _currentEndDate.isBefore(now.subtract(const Duration(days: 1)));
    } else if (_currentPeriod == 'Monthly') {
      return _currentEndDate.isBefore(DateTime(now.year, now.month, 1));
    } else if (_currentPeriod == 'Yearly') {
      return _currentEndDate.year < now.year;
    }
    return false;
  }

  String _getPreviousPeriod(String period) {
    if (period == 'Weekly') {
      final previousWeek = _currentStartDate.subtract(const Duration(days: 7));
      return '${previousWeek.year}-${previousWeek.month}-${previousWeek.day}';
    } else if (period == 'Monthly') {
      final previousMonth =
          DateTime(_currentStartDate.year, _currentStartDate.month - 1, 1);
      return '${previousMonth.year}-${previousMonth.month}';
    } else if (period == 'Yearly') {
      return '${_currentStartDate.year - 1}';
    }
    return period;
  }

  String _getNextPeriod(String period) {
    if (period == 'Weekly') {
      final nextWeek = _currentStartDate.add(const Duration(days: 7));
      return '${nextWeek.year}-${nextWeek.month}-${nextWeek.day}';
    } else if (period == 'Monthly') {
      final nextMonth =
          DateTime(_currentStartDate.year, _currentStartDate.month + 1, 1);
      return '${nextMonth.year}-${nextMonth.month}';
    } else if (period == 'Yearly') {
      return '${_currentStartDate.year + 1}';
    }
    return period;
  }

  void _updatePeriodDates(String periodKey) {
    DateTime now = DateTime.now();
    DateTime startDate;
    DateTime endDate;

    if (_currentPeriod == 'Weekly') {
      if (periodKey.contains('-')) {
        final parts = periodKey.split('-');
        startDate = DateTime(
            int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
      } else {
        startDate = DateTime(now.year, now.month, now.day);
      }
      endDate = startDate.add(const Duration(days: 6));
    } else if (_currentPeriod == 'Monthly') {
      if (periodKey.contains('-')) {
        final parts = periodKey.split('-');
        startDate = DateTime(int.parse(parts[0]), int.parse(parts[1]), 1);
        endDate = DateTime(int.parse(parts[0]), int.parse(parts[1]) + 1, 0);
      } else {
        startDate = DateTime(now.year, now.month, 1);
        endDate = DateTime(now.year, now.month + 1, 0);
      }
    } else if (_currentPeriod == 'Yearly') {
      final year = int.parse(periodKey);
      startDate = DateTime(year, 1, 1);
      endDate = DateTime(year, 12, 31);
    } else {
      startDate = _currentStartDate;
      endDate = _currentEndDate;
    }

    setState(() {
      _currentStartDate = startDate;
      _currentEndDate = endDate;
    });
  }

  String _getPeriodLabel() {
    if (_currentPeriod == 'Weekly') {
      final sameMonth = _currentStartDate.month == _currentEndDate.month;
      final sameYear = _currentStartDate.year == _currentEndDate.year;

      if (sameMonth && sameYear) {
        return '${_currentStartDate.day} - ${_currentEndDate.day} ${_monthName(_currentStartDate.month)} ${_currentStartDate.year}';
      } else if (sameYear) {
        return '${_currentStartDate.day} ${_monthName(_currentStartDate.month)} - ${_currentEndDate.day} ${_monthName(_currentEndDate.month)} ${_currentStartDate.year}';
      } else {
        return '${_currentStartDate.day} ${_monthName(_currentStartDate.month)} ${_currentStartDate.year} - ${_currentEndDate.day} ${_monthName(_currentEndDate.month)} ${_currentEndDate.year}';
      }
    } else if (_currentPeriod == 'Monthly') {
      return '${_monthName(_currentStartDate.month)} ${_currentStartDate.year}';
    } else if (_currentPeriod == 'Yearly') {
      return '${_currentStartDate.year}';
    }
    return 'Custom Period';
  }

  String _monthName(int month) {
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month];
  }

  List<_PeriodData> _groupByPeriod(
      List<Map<String, dynamic>> filteredTransactions) {
    final List<_PeriodData> data = [];
    if (_currentPeriod == 'Weekly' || _currentPeriod == 'Custom') {
      for (int i = 0;
          i <= _currentEndDate.difference(_currentStartDate).inDays;
          i++) {
        final day = _currentStartDate.add(Duration(days: i));
        final total = filteredTransactions
            .where((tx) {
              final dateValue = tx['date'];
              DateTime? date;
              if (dateValue is int) {
                date = DateTime.fromMillisecondsSinceEpoch(dateValue);
              } else if (dateValue is String) {
                try {
                  date =
                      DateTime.fromMillisecondsSinceEpoch(int.parse(dateValue));
                } catch (_) {
                  date = null;
                }
              }
              return date != null &&
                  date.year == day.year &&
                  date.month == day.month &&
                  date.day == day.day;
            })
            .map((tx) => double.tryParse(tx['amount'].toString()) ?? 0.0)
            .fold(0.0, (a, b) => a + b);
        data.add(_PeriodData(label: '${day.day}/${day.month}', value: total));
      }
    } else if (_currentPeriod == 'Monthly') {
      DateTime weekStart = _currentStartDate;
      while (weekStart.isBefore(_currentEndDate)) {
        final weekEnd =
            weekStart.add(const Duration(days: 6)).isAfter(_currentEndDate)
                ? _currentEndDate
                : weekStart.add(const Duration(days: 6));
        final total = filteredTransactions
            .where((tx) {
              final dateValue = tx['date'];
              DateTime? date;
              if (dateValue is int) {
                date = DateTime.fromMillisecondsSinceEpoch(dateValue);
              } else if (dateValue is String) {
                try {
                  date =
                      DateTime.fromMillisecondsSinceEpoch(int.parse(dateValue));
                } catch (_) {
                  date = null;
                }
              }
              return date != null &&
                  !date.isBefore(weekStart) &&
                  !date.isAfter(weekEnd);
            })
            .map((tx) => double.tryParse(tx['amount'].toString()) ?? 0.0)
            .fold(0.0, (a, b) => a + b);
        data.add(_PeriodData(
            label: '${weekStart.day}/${weekStart.month}', value: total));
        weekStart = weekEnd.add(const Duration(days: 1));
      }
    } else if (_currentPeriod == 'Yearly') {
      for (int m = 1; m <= 12; m++) {
        final total = filteredTransactions
            .where((tx) {
              final dateValue = tx['date'];
              DateTime? date;
              if (dateValue is int) {
                date = DateTime.fromMillisecondsSinceEpoch(dateValue);
              } else if (dateValue is String) {
                try {
                  date =
                      DateTime.fromMillisecondsSinceEpoch(int.parse(dateValue));
                } catch (_) {
                  date = null;
                }
              }
              return date != null &&
                  date.month == m &&
                  date.year == _currentStartDate.year;
            })
            .map((tx) => double.tryParse(tx['amount'].toString()) ?? 0.0)
            .fold(0.0, (a, b) => a + b);
        data.add(_PeriodData(label: '$m', value: total));
      }
    }
    return data;
  }

  String _formatCurrency(double amount) {
    if (amount >= 10000000) {
      return '₹${(amount / 10000000).toStringAsFixed(2)}Cr';
    } else if (amount >= 100000) {
      return '₹${(amount / 100000).toStringAsFixed(2)}L';
    } else if (amount >= 1000) {
      return '₹${(amount / 1000).toStringAsFixed(2)}K';
    }
    return '₹${amount.toStringAsFixed(0)}';
  }

  String formatIndianCurrency(double value) {
    final formatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '', // You can add ₹ if needed
      decimalDigits: 2,
    );

    return formatter.format(value);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionsBloc, TransactionsState>(
      builder: (context, state) {
        final allTransactions = state.transactions;
        final filteredTransactions = allTransactions.where((tx) {
          if (tx['category'] != widget.category || tx['type'] != widget.type) {
            return false;
          }
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
          return !date.isBefore(_currentStartDate) &&
              !date.isAfter(_currentEndDate);
        }).toList();

        List<String> banks = allTransactions
            .map((tx) => tx['bank'] as String? ?? '')
            .where((b) => b.isNotEmpty)
            .toSet()
            .toList();
        if (!banks.contains('Cash')) banks.add('Cash');

        double total = filteredTransactions.fold(0.0,
            (a, tx) => a + (double.tryParse(tx['amount'].toString()) ?? 0.0));
        double min = filteredTransactions.isEmpty
            ? 0.0
            : filteredTransactions
                .map((tx) => double.tryParse(tx['amount'].toString()) ?? 0.0)
                .reduce((a, b) => a < b ? a : b);
        double max = filteredTransactions.isEmpty
            ? 0.0
            : filteredTransactions
                .map((tx) => double.tryParse(tx['amount'].toString()) ?? 0.0)
                .reduce((a, b) => a > b ? a : b);
        double avg = filteredTransactions.isEmpty
            ? 0.0
            : total / filteredTransactions.length;

        List<_PeriodData> periodData = _groupByPeriod(filteredTransactions);
        double chartMax = periodData.isEmpty
            ? 0.0
            : periodData
                .map((tx) => double.tryParse(tx.value.toString()) ?? 0.0)
                .reduce((a, b) => a > b ? a : b);
        final iconAndColor = CategoryKeyWord.getIconAndColor(widget.category);
        final catColor =
            CategoryKeyWord.parseHexColor(iconAndColor['color'] ?? '#2196F3');
        final catIcon = iconAndColor['icon'] ?? '';
        return Scaffold(
          appBar: AppBar(
            centerTitle: false,
            scrolledUnderElevation: 0.0,
            backgroundColor: Colors.black,
            actions: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left, color: Colors.white),
                      onPressed: _canGoToPreviousPeriod()
                          ? () {
                              final previousPeriod =
                                  _getPreviousPeriod(_currentPeriod);
                              _updatePeriodDates(previousPeriod);
                              context.read<TransactionsBloc>().add(
                                    LoadTransactions(
                                        startDate: _currentStartDate,
                                        endDate: _currentEndDate),
                                  );
                            }
                          : null,
                    ),
                    Center(
                      child: Text(
                        _getPeriodLabel(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    IconButton(
                      icon:
                          const Icon(Icons.chevron_right, color: Colors.white),
                      onPressed: _canGoToNextPeriod()
                          ? () {
                              final nextPeriod = _getNextPeriod(_currentPeriod);
                              _updatePeriodDates(nextPeriod);
                              context.read<TransactionsBloc>().add(
                                    LoadTransactions(
                                        startDate: _currentStartDate,
                                        endDate: _currentEndDate),
                                  );
                            }
                          : null,
                    ),
                  ],
                ),
              ),
            ],
          ),
          backgroundColor: Colors.transparent,
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Summary Card
                ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 18),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            catColor.withAlpha(56),
                            Colors.white.withAlpha(10),
                            catColor.withAlpha(25),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                            color: catColor.withAlpha(63), width: 1.2),
                        boxShadow: [
                          BoxShadow(
                            color: catColor.withAlpha(45),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 54,
                            height: 54,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  catColor.withAlpha(178),
                                  catColor.withAlpha(76)
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: catColor.withAlpha(63),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                catIcon,
                                style: const TextStyle(
                                    fontSize: 28,
                                    color: Colors.white,
                                    shadows: [
                                      Shadow(
                                          blurRadius: 8, color: Colors.black26)
                                    ]),
                              ),
                            ),
                          ),
                          const SizedBox(width: 22),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.category,
                                  style: const TextStyle(
                                    // color: catColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(Icons.savings,
                                        color: Colors.white, size: 18),
                                    const SizedBox(width: 6),
                                    Text(
                                      '₹${total.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    _summaryStat('Min', min, catColor),
                                    const SizedBox(width: 12),
                                    _summaryStat('Max', max, catColor),
                                    const SizedBox(width: 12),
                                    _summaryStat('Avg', avg, catColor),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Chart
                const Text('Trend',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Container(
                  // margin: const EdgeInsets.only(
                  //     top: 8, left: 8, right: 0, bottom: 0),
                  padding: const EdgeInsets.only(top: 8, bottom: 0),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: SizedBox(
                    height: 200,
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: true,
                          drawHorizontalLine: true,
                          horizontalInterval:
                              (chartMax > 0 ? chartMax * 1.2 : 1) / 4,
                          getDrawingHorizontalLine: (value) => const FlLine(
                            color: Colors.white12,
                            strokeWidth: 1,
                          ),
                          getDrawingVerticalLine: (value) => const FlLine(
                            color: Colors.white12,
                            strokeWidth: 1,
                          ),
                        ),
                        titlesData: FlTitlesData(
                          rightTitles: const AxisTitles(),
                          topTitles: const AxisTitles(),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              interval: (chartMax > 0 ? chartMax * 1.2 : 1) / 4,
                              getTitlesWidget: (value, meta) {
                                final maxY = chartMax > 0 ? chartMax * 1.2 : 1;
                                final interval = maxY / 4;
                                if ((value % interval).abs() < 0.01 ||
                                    (value - maxY).abs() < 0.01 ||
                                    value == 0) {
                                  return Text(
                                    _formatCurrency(value),
                                    style: const TextStyle(
                                        color: Colors.white54, fontSize: 10),
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final idx = value.toInt();
                                if (idx < 0 || idx >= periodData.length) {
                                  return const SizedBox();
                                }
                                return Text(
                                  periodData[idx].label,
                                  style: const TextStyle(
                                      color: Colors.white70, fontSize: 10),
                                );
                              },
                              interval: 1,
                              reservedSize: 32,
                            ),
                          ),
                        ),
                        borderData: FlBorderData(
                          show: true,
                          border: Border.all(color: Colors.white12),
                        ),
                        minX: 0,
                        maxX: (periodData.length - 1).toDouble(),
                        minY: 0,
                        maxY: chartMax > 0 ? chartMax * 1.2 : 1,
                        lineTouchData: LineTouchData(
                          enabled: true,
                          touchTooltipData: LineTouchTooltipData(
                            getTooltipItems: (touchedSpots) {
                              return touchedSpots.map((LineBarSpot spot) {
                                return LineTooltipItem(
                                  '₹${formatIndianCurrency(spot.y)}',
                                  const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                );
                              }).toList();
                            },
                          ),
                        ),
                        lineBarsData: [
                          LineChartBarData(
                            isCurved: true,
                            // color: catColor.withAlpha(178),
                            barWidth: 3,
                            gradient: LinearGradient(
                              colors: [
                                catColor.withAlpha(178),
                                catColor.withAlpha(130),
                                catColor.withAlpha(100),
                                catColor.withAlpha(70),

                                // Colors.white.withAlpha(10),
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            spots: [
                              for (int i = 0; i < periodData.length; i++)
                                FlSpot(i.toDouble(), periodData[i].value),
                            ],
                            dotData: FlDotData(
                              show: true,
                              getDotPainter: (spot, percent, bar, index) =>
                                  FlDotCirclePainter(
                                radius: 5,
                                color: Colors.white,
                                strokeWidth: 2,
                                strokeColor: catColor.withAlpha(178),
                              ),
                            ),

                            belowBarData: BarAreaData(
                              show: true,
                              color: catColor.withAlpha(45),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Transactions',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Expanded(
                  child: filteredTransactions.isEmpty
                      ? const Center(
                          child: Text('No transactions found',
                              style: TextStyle(color: Colors.white54)))
                      : ListView.separated(
                          itemCount: filteredTransactions.length,
                          physics: const BouncingScrollPhysics(),
                          separatorBuilder: (_, __) => const Divider(
                            color: Colors.white12,
                            height: 0,
                            indent: 0,
                            thickness: 1,
                          ),
                          itemBuilder: (context, i) {
                            final tx = filteredTransactions[i];
                            final isCredit = tx['type'] == 'Credit';
                            final color = isCredit ? Colors.green : Colors.red;
                            final iconAndColor =
                                CategoryKeyWord.getIconAndColor(
                                    tx['category'] ?? '');
                            final txColor = CategoryKeyWord.parseHexColor(
                                iconAndColor['color'] ?? '#2196F3');
                            // final txIcon = iconAndColor['icon'] ?? '';
                            String formattedDate =
                                DateFormatter.formatDate(tx['date']);
                            String date = formattedDate == 'Invalid date format'
                                ? 'Unknown'
                                : formattedDate;
                            return InkWell(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => AddEditTransactionScreen(
                                      banks: banks,
                                      transaction: tx,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                // margin: const EdgeInsets.symmetric(vertical: 4),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  color: txColor.withAlpha(10),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    // Container(
                                    //   padding: const EdgeInsets.all(10),
                                    //   decoration: BoxDecoration(
                                    //     color: txColor.withAlpha(18),
                                    //     borderRadius: BorderRadius.circular(10),
                                    //   ),
                                    //   child: Text(txIcon,
                                    //       style: const TextStyle(fontSize: 18)),
                                    // ),
                                    // const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            tx['upiIdOrSenderName'] ??
                                                'Unknown',
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 2),
                                          Row(
                                            children: [
                                              const Icon(
                                                  Icons.calendar_today_outlined,
                                                  size: 12,
                                                  color: Colors.white54),
                                              Text('  $date',
                                                  style: const TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.white54)),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          '₹${tx['amount'] ?? 'Unknown'}',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: color,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PeriodData {
  final String label;
  final double value;
  _PeriodData({required this.label, required this.value});
}

Widget _summaryStat(String label, double value, Color color) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label,
          style: TextStyle(
              color: color.withAlpha(178),
              fontSize: 11,
              fontWeight: FontWeight.w500)),
      Text('₹${value.toStringAsFixed(2)}',
          style: const TextStyle(
              color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
    ],
  );
}
