import 'package:dhanra/core/routing/route_names.dart';
import 'package:dhanra/core/theme/app_colors.dart';
import 'package:dhanra/core/theme/gradients.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:dhanra/features/transactions/bloc/transactions_bloc.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen>
    with SingleTickerProviderStateMixin {
  String _selectedPeriod = 'Monthly';
  final List<String> _periodOptions = [
    'Weekly',
    'Monthly',
    'Yearly',
    'Custom',
  ];
  DateTimeRange? _customRange;
  DateTime _currentPeriod = DateTime.now();
  DateTime? _activeStartDate;
  DateTime? _activeEndDate;
  late TabController _tabController;
  int _selectedTab = 1; // 0: Income, 1: Expenses

  void _loadTransactionsForCurrentPeriod() {
    DateTime? startDate;
    DateTime? endDate;
    if (_selectedPeriod == 'Weekly') {
      final startOfWeek =
          _currentPeriod.subtract(Duration(days: _currentPeriod.weekday - 1));
      startDate =
          DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
      endDate = startDate.add(const Duration(days: 6));
    } else if (_selectedPeriod == 'Monthly') {
      startDate = DateTime(_currentPeriod.year, _currentPeriod.month, 1);
      endDate = DateTime(_currentPeriod.year, _currentPeriod.month + 1, 0);
    } else if (_selectedPeriod == 'Yearly') {
      startDate = DateTime(_currentPeriod.year, 1, 1);
      endDate = DateTime(_currentPeriod.year, 12, 31);
    } else if (_selectedPeriod == 'Custom' && _customRange != null) {
      startDate = _customRange!.start;
      endDate = _customRange!.end;
    }
    setState(() {
      _activeStartDate = startDate;
      _activeEndDate = endDate;
    });
    if (startDate != null && endDate != null) {
      context
          .read<TransactionsBloc>()
          .add(LoadTransactions(startDate: startDate, endDate: endDate));
    } else {
      context.read<TransactionsBloc>().add(const LoadTransactions());
    }
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

  @override
  void initState() {
    super.initState();
    _currentPeriod = DateTime.now();
    _tabController =
        TabController(length: 2, vsync: this, initialIndex: _selectedTab);
    _tabController.addListener(() {
      if (_tabController.index != _selectedTab) {
        setState(() {
          _selectedTab = _tabController.index;
        });
      }
    });
    _loadTransactionsForCurrentPeriod();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Gradients.gradient(
            top: -MediaQuery.of(context).size.height,
            left: -MediaQuery.of(context).size.width,
            right: 0,
            context: context,
          ),
          Image.asset(
            "assets/images/circle_ui.png",
            opacity: const AlwaysStoppedAnimation(.8),
            fit: BoxFit.cover,
          ),
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(context),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(38),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(20),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      indicator: BoxDecoration(
                        gradient: LinearGradient(
                          colors: _selectedTab == 0
                              ? [
                                  Colors.greenAccent.withAlpha(178),
                                  Colors.green.withAlpha(127)
                                ]
                              : [
                                  Colors.redAccent.withAlpha(178),
                                  Colors.red.withAlpha(127)
                                ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color:
                                (_selectedTab == 0 ? Colors.green : Colors.red)
                                    .withAlpha(45),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      labelColor: Colors.white,
                      // unselectedLabelColor: Colors.white.withAlpha(15),
                      labelStyle: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                      tabs: const [
                        Tab(text: 'Income'),
                        Tab(text: 'Expenses'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 12,
                ),
                Expanded(
                  child: BlocBuilder<TransactionsBloc, TransactionsState>(
                    builder: (context, state) {
                      if (state.status == TransactionsStatus.loading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final type = _selectedTab == 0 ? 'Credit' : 'Debit';
                      final filteredTransactions = state.transactions
                          .where((tx) => tx['type'] == type)
                          .toList();
                      // final total = _calculateTotal(filteredTransactions, type);
                      final categoryData =
                          _calculateCategoryData(filteredTransactions, type);

                      return SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Pie Chart
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: Center(
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      SizedBox(
                                        height: 250,
                                        width: 250,
                                        child: PieChart(
                                          PieChartData(
                                            sections: categoryData.isEmpty
                                                ? [
                                                    PieChartSectionData(
                                                      value: 100,
                                                      color: Colors.white10,
                                                      title: '',
                                                      radius: 60,
                                                    )
                                                  ]
                                                : _buildPieSections(
                                                    categoryData),
                                            centerSpaceRadius: 80,
                                            sectionsSpace: 3,
                                          ),
                                        ),
                                      ),
                                      // Remove the total from here, it's now above
                                      BlocBuilder<TransactionsBloc,
                                          TransactionsState>(
                                        builder: (context, state) {
                                          final type = _selectedTab == 0
                                              ? 'Credit'
                                              : 'Debit';
                                          final filteredTransactions = state
                                              .transactions
                                              .where((tx) => tx['type'] == type)
                                              .toList();
                                          final total = _calculateTotal(
                                              filteredTransactions, type);
                                          final color = type == 'Credit'
                                              ? Colors.greenAccent
                                              : Colors.redAccent;
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                                top: 8, bottom: 8),
                                            child: Column(
                                              children: [
                                                Text(
                                                  _formatCurrency(total),
                                                  style: TextStyle(
                                                    color: color,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 24,
                                                    letterSpacing: 0.2,
                                                    shadows: [
                                                      Shadow(
                                                        color:
                                                            color.withAlpha(45),
                                                        blurRadius: 8,
                                                        offset:
                                                            const Offset(0, 2),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(height: 6),
                                                _buildPeriodDropdown(),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              // Category List
                              ListView.separated(
                                itemCount: categoryData.length,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                separatorBuilder: (_, __) =>
                                    const Divider(color: Colors.white12),
                                itemBuilder: (context, i) {
                                  final cat = categoryData[i];
                                  return GestureDetector(
                                    onTap: () {
                                      context.push(
                                          AppRoute.categoryDetails.path,
                                          extra: {
                                            'category': cat['name'],
                                            'period': _selectedPeriod,
                                            'startDate': _activeStartDate!,
                                            'endDate': _activeEndDate!,
                                            'type': type,
                                          });
                                      // Navigator.of(context).push(
                                      //   MaterialPageRoute(
                                      //     builder: (_) => CategoryDetailsScreen(
                                      //       category: cat['name'],
                                      //       period: _selectedPeriod,
                                      //       startDate: _activeStartDate!,
                                      //       endDate: _activeEndDate!,
                                      //       type: type,
                                      //     ),
                                      //   ),
                                      // );
                                    },
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 12,
                                          height: 12,
                                          decoration: BoxDecoration(
                                            color: cat['color'],
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            cat['name'],
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 16),
                                          ),
                                        ),
                                        Text(
                                          '${cat['percent'].toStringAsFixed(0)}%',
                                          style: const TextStyle(
                                              color: Colors.white70,
                                              fontSize: 15),
                                        ),
                                        const SizedBox(width: 16),
                                        Text(
                                          '\u20B9${cat['amount'].toStringAsFixed(2)}',
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 90),
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
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, color: Colors.white),
            onPressed: _canGoToPreviousPeriod()
                ? () {
                    setState(() {
                      _currentPeriod = _getPreviousPeriod(_currentPeriod);
                    });
                    _loadTransactionsForCurrentPeriod();
                  }
                : null,
          ),
          Expanded(
            child: Center(
              child: Text(
                _getPeriodLabel(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, color: Colors.white),
            onPressed: _canGoToNextPeriod()
                ? () {
                    setState(() {
                      _currentPeriod = _getNextPeriod(_currentPeriod);
                    });
                    _loadTransactionsForCurrentPeriod();
                  }
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodDropdown() {
    return DropdownButton<String>(
      value: _selectedPeriod,
      dropdownColor: const Color(0xFF23243B),
      style: const TextStyle(color: Colors.white, fontSize: 16),
      underline: const SizedBox(),
      padding: EdgeInsets.zero,
      isExpanded: false,
      isDense: true,
      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white),
      items: _periodOptions.map((period) {
        return DropdownMenuItem(
          value: period,
          child: Text(period),
        );
      }).toList(),
      onChanged: (val) async {
        if (val != null) {
          if (val == 'Custom') {
            final picked = await showDateRangePicker(
              context: context,
              firstDate: DateTime(2000),
              lastDate: DateTime.now(),
              initialDateRange: _customRange,
            );
            if (picked != null) {
              setState(() {
                _selectedPeriod = val;
                _customRange = picked;
                _currentPeriod = picked.start;
              });
              _loadTransactionsForCurrentPeriod();
            }
          } else {
            setState(() {
              _selectedPeriod = val;
              _customRange = null;
              _currentPeriod = DateTime.now();
            });
            _loadTransactionsForCurrentPeriod();
          }
        }
      },
    );
  }

  // Widget _buildTotalCard(String label, double amount, Color color) {
  //   return Expanded(
  //     child: Column(
  //       children: [
  //         Text(
  //           label,
  //           style: const TextStyle(color: Colors.white70, fontSize: 15),
  //         ),
  //         const SizedBox(height: 8),
  //         Text(
  //           '\u20B9${amount.toStringAsFixed(2)}',
  //           style: TextStyle(
  //             color: color,
  //             fontSize: 22,
  //             fontWeight: FontWeight.bold,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  double _calculateTotal(List<Map<String, dynamic>> transactions, String type) {
    return transactions
        .where((tx) => tx['type'] == type)
        .map((tx) => double.tryParse(tx['amount'].toString()) ?? 0.0)
        .fold(0.0, (a, b) => a + b);
  }

  List<Map<String, dynamic>> _calculateCategoryData(
      List<Map<String, dynamic>> transactions, type) {
    final Map<String, double> categoryTotals = {};
    double totalExpenses = 0.0;

    for (final tx in transactions) {
      if (tx['type'] == type) {
        final category = tx['category'] ?? 'Other';
        final amount = double.tryParse(tx['amount'].toString()) ?? 0.0;
        categoryTotals[category] = (categoryTotals[category] ?? 0) + amount;
        totalExpenses += amount;
      }
    }
    final List<Color> defaultColors = [
      const Color(0xFF6C63FF),
      const Color(0xFF00BFAE),
      const Color(0xFFFFC542),
      const Color(0xFFFD5E53),
      const Color(0xFF36CFC9),
      const Color(0xFF7D5FFF),
      const Color(0xFF4ECDC4),
      Colors.purple,
      Colors.blueGrey,
      Colors.teal,
    ];
    int colorIdx = 0;
    List<Map<String, dynamic>> result = [];
    categoryTotals.forEach((cat, amt) {
      final percent = totalExpenses > 0 ? (amt / totalExpenses) * 100 : 0;
      Color color = defaultColors[colorIdx % defaultColors.length];
      colorIdx++;
      result.add({
        'name': cat,
        'percent': percent,
        'amount': amt,
        'color': color,
      });
    });
    result.sort((a, b) => b['amount'].compareTo(a['amount']));
    return result;
  }

  List<PieChartSectionData> _buildPieSections(
      List<Map<String, dynamic>> categoryData) {
    return categoryData.map((cat) {
      return PieChartSectionData(
        color: cat['color'],
        value: cat['percent'],
        title: '',
        radius: 60,
      );
    }).toList();
  }

  String _getPeriodLabel() {
    if (_activeStartDate != null && _activeEndDate != null) {
      final sameDay = _activeStartDate!.difference(_activeEndDate!).inDays == 0;
      final sameMonth = _activeStartDate!.month == _activeEndDate!.month &&
          _activeStartDate!.year == _activeEndDate!.year;
      final sameYear = _activeStartDate!.year == _activeEndDate!.year;
      if (sameDay) {
        return DateFormat('d MMM yyyy').format(_activeStartDate!);
      } else if (sameMonth) {
        return '${DateFormat('d').format(_activeStartDate!)} - ${DateFormat('d MMM yyyy').format(_activeEndDate!)}';
      } else if (sameYear) {
        return '${DateFormat('d MMM').format(_activeStartDate!)} - ${DateFormat('d MMM yyyy').format(_activeEndDate!)}';
      } else {
        return '${DateFormat('d MMM yyyy').format(_activeStartDate!)} - ${DateFormat('d MMM yyyy').format(_activeEndDate!)}';
      }
    }
    return '';
  }

  DateTime _getPreviousPeriod(DateTime current) {
    if (_selectedPeriod == 'Weekly') {
      return current.subtract(const Duration(days: 7));
    } else if (_selectedPeriod == 'Monthly') {
      return DateTime(current.year, current.month - 1, 1);
    } else if (_selectedPeriod == 'Yearly') {
      return DateTime(current.year - 1, 1, 1);
    }
    return current;
  }

  DateTime _getNextPeriod(DateTime current) {
    if (_selectedPeriod == 'Weekly') {
      return current.add(const Duration(days: 7));
    } else if (_selectedPeriod == 'Monthly') {
      return DateTime(current.year, current.month + 1, 1);
    } else if (_selectedPeriod == 'Yearly') {
      return DateTime(current.year + 1, 1, 1);
    }
    return current;
  }

  bool _canGoToPreviousPeriod() {
    if (_selectedPeriod == 'Custom') return false;
    // Optionally, add logic to restrict how far back user can go
    return true;
  }

  bool _canGoToNextPeriod() {
    if (_selectedPeriod == 'Custom') return false;
    final now = DateTime.now();
    if (_selectedPeriod == 'Weekly') {
      final startOfWeek =
          _currentPeriod.subtract(Duration(days: _currentPeriod.weekday - 1));
      return startOfWeek.isBefore(now);
    } else if (_selectedPeriod == 'Monthly') {
      return _currentPeriod.year < now.year ||
          (_currentPeriod.year == now.year && _currentPeriod.month < now.month);
    } else if (_selectedPeriod == 'Yearly') {
      return _currentPeriod.year < now.year;
    }
    return false;
  }
}
