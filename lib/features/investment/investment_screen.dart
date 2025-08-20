import 'package:dhanra/core/theme/gradients.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'models/investment_option.dart';
import 'data/investment_options_data.dart';
import 'widgets/risk_category_widget.dart';
import 'package:dhanra/features/transactions/bloc/transactions_bloc.dart';
// import 'package:dhanra/features/transactions/bloc/transactions_state.dart';

class InvestmentScreen extends StatefulWidget {
  const InvestmentScreen({Key? key}) : super(key: key);

  @override
  State<InvestmentScreen> createState() => _InvestmentScreenState();
}

class _InvestmentScreenState extends State<InvestmentScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTab = 0;
  final String _sortBy = 'Return';

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: 3, vsync: this, initialIndex: _selectedTab);
    _tabController.addListener(() {
      if (_tabController.index != _selectedTab) {
        setState(() {
          _selectedTab = _tabController.index;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<InvestmentOption> getFilteredOptions(RiskLevel riskLevel) {
    var options =
        investmentOptions.where((o) => o.riskLevel == riskLevel).toList();

    if (_sortBy == 'Return') {
      options.sort((a, b) => b.potentialReturn.compareTo(a.potentialReturn));
    } else if (_sortBy == 'Risk') {
      options.sort((a, b) => a.risk.compareTo(b.risk));
    }
    return options;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionsBloc, TransactionsState>(
      builder: (context, state) {
        final income = state.transactions
            .where((tx) => tx['type'] == 'Credit')
            .fold<double>(
                0.0, (sum, tx) => sum + (num.parse(tx['amount'] ?? 0.0)));
        final expenses = state.transactions
            .where((tx) => tx['type'] == 'Debit')
            .fold<double>(
                0.0, (sum, tx) => sum + (num.parse(tx['amount'] ?? 0.0)));
        final userAmount = income - expenses;
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
              // appBar: PreferredSize(
              //   preferredSize: const Size.fromHeight(70),
              //   child: Container(
              //     margin: const EdgeInsets.all(12),
              //     decoration: BoxDecoration(
              //       color: Colors.white.withOpacity(0.15),
              //       borderRadius: BorderRadius.circular(18),
              //       boxShadow: [
              //         BoxShadow(
              //           color: Colors.black.withAlpha(30),
              //           blurRadius: 12,
              //           offset: const Offset(0, 4),
              //         ),
              //       ],
              //     ),
              //     child: SafeArea(
              //       child: Row(
              //         mainAxisAlignment: MainAxisAlignment.center,
              //         children: [
              //           const Icon(Icons.account_balance_wallet_rounded,
              //               size: 28, color: Colors.blueAccent),
              //           const SizedBox(width: 12),
              //           Column(
              //             mainAxisAlignment: MainAxisAlignment.center,
              //             crossAxisAlignment: CrossAxisAlignment.start,
              //             children: [
              //               const Text('Available',
              //                   style:
              //                       TextStyle(fontSize: 13, color: Colors.black54)),
              //               Text(
              //                 '₹${userAmount.toStringAsFixed(2)}',
              //                 style: TextStyle(
              //                   color: userAmount.isNegative
              //                       ? Colors.red
              //                       : Colors.green,
              //                   fontWeight: FontWeight.bold,
              //                   fontSize: 24,
              //                   letterSpacing: 1.2,
              //                 ),
              //               ),
              //             ],
              //           ),
              //         ],
              //       ),
              //     ),
              //   ),
              // ),
              body: SafeArea(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
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
                                      Colors.redAccent.withAlpha(178),
                                      Colors.red.withAlpha(127)
                                    ]
                                  : _selectedTab == 1
                                      ? [
                                          Colors.amberAccent.withAlpha(178),
                                          Colors.amber.withAlpha(127)
                                        ]
                                      : [
                                          Colors.greenAccent.withAlpha(178),
                                          Colors.green.withAlpha(127)
                                        ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: (_selectedTab == 0
                                        ? Colors.red
                                        : _selectedTab == 1
                                            ? Colors.amber
                                            : Colors.green)
                                    .withAlpha(45),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          labelColor: Colors.white,
                          labelStyle: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                          tabs: const [
                            Tab(text: 'High'),
                            Tab(text: 'Medium'),
                            Tab(text: 'Low'),
                          ],
                          onTap: (index) {
                            setState(() {
                              _selectedTab = index;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          RiskCategoryWidget(
                            riskLevel: RiskLevel.high,
                            options: getFilteredOptions(RiskLevel.high),
                            userAmount: userAmount,
                          ),
                          RiskCategoryWidget(
                            riskLevel: RiskLevel.medium,
                            options: getFilteredOptions(RiskLevel.medium),
                            userAmount: userAmount,
                          ),
                          RiskCategoryWidget(
                            riskLevel: RiskLevel.low,
                            options: getFilteredOptions(RiskLevel.low),
                            userAmount: userAmount,
                          ),
                        ],
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
}
