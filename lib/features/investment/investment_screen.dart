import 'package:dhanra/core/theme/gradients.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'data/investment_options_data.dart';
import 'models/investment_option.dart';
import 'widgets/risk_category_widget.dart';
import 'package:dhanra/features/transactions/bloc/transactions_bloc.dart';

class InvestmentScreen extends StatefulWidget {
  const InvestmentScreen({Key? key}) : super(key: key);

  @override
  State<InvestmentScreen> createState() => _InvestmentScreenState();
}

class _InvestmentScreenState extends State<InvestmentScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  int _selectedTab = 0;

  // You can later extend this with an enum for better type-safety
  static const String _sortBy = 'Return';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: _selectedTab,
    )..addListener(_handleTabChange);
  }

  void _handleTabChange() {
    if (_tabController.index != _selectedTab) {
      setState(() => _selectedTab = _tabController.index);
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  List<InvestmentOption> _getFilteredOptions(RiskLevel riskLevel) {
    final filtered = investmentOptions
        .where((option) => option.riskLevel == riskLevel)
        .toList();

    switch (_sortBy) {
      case 'Return':
        filtered.sort((a, b) => b.potentialReturn.compareTo(a.potentialReturn));
        break;
      case 'Risk':
        filtered.sort((a, b) => a.risk.compareTo(b.risk));
        break;
    }
    return filtered;
  }

  double _calculateNetAmount(List<Map<String, dynamic>> transactions) {
    final income = transactions
        .where((tx) => tx['type'] == 'Credit')
        .fold<double>(0.0, (sum, tx) => sum + _safeParseAmount(tx['amount']));
    final expenses = transactions
        .where((tx) => tx['type'] == 'Debit')
        .fold<double>(0.0, (sum, tx) => sum + _safeParseAmount(tx['amount']));
    return income - expenses;
  }

  double _safeParseAmount(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  BoxDecoration _tabIndicatorDecoration(int index) {
    final colors = switch (index) {
      0 => [Colors.redAccent.withAlpha(178), Colors.red.withAlpha(127)],
      1 => [Colors.amberAccent.withAlpha(178), Colors.amber.withAlpha(127)],
      _ => [Colors.greenAccent.withAlpha(178), Colors.green.withAlpha(127)],
    };

    final shadowColor = switch (index) {
      0 => Colors.red,
      1 => Colors.amber,
      _ => Colors.green,
    };

    return BoxDecoration(
      gradient: LinearGradient(
        colors: colors,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(14),
      boxShadow: [
        BoxShadow(
          color: shadowColor.withAlpha(45),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionsBloc, TransactionsState>(
      builder: (context, state) {
        final userAmount = _calculateNetAmount(state.transactions);

        return Stack(
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
            Scaffold(
              backgroundColor: Colors.transparent,
              body: SafeArea(
                child: Column(
                  children: [
                    _buildTabBar(context),
                    const SizedBox(height: 12),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: RiskLevel.values.map((riskLevel) {
                          return RiskCategoryWidget(
                            riskLevel: riskLevel,
                            options: _getFilteredOptions(riskLevel),
                            userAmount: userAmount,
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTabBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        width: double.infinity,
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
          indicator: _tabIndicatorDecoration(_selectedTab),
          labelColor: Colors.white,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          tabs: const [
            Tab(text: 'High'),
            Tab(text: 'Medium'),
            Tab(text: 'Low'),
          ],
          onTap: (index) => setState(() => _selectedTab = index),
        ),
      ),
    );
  }
}
