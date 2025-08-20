import 'dart:ui';

import 'package:dhanra/core/constants/category_keyword.dart';
// import 'package:dhanra/core/theme/app_colors.dart';
import 'package:dhanra/core/theme/gradients.dart';
import 'package:dhanra/core/utils/date_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/transactions_bloc.dart';
import 'package:intl/intl.dart';
import './add_edit_transaction_screen.dart';

class AllTransactionsScreen extends StatefulWidget {
  const AllTransactionsScreen({super.key, required this.banks});
  final List<String> banks;

  @override
  State<AllTransactionsScreen> createState() => _AllTransactionsScreenState();
}

class _AllTransactionsScreenState extends State<AllTransactionsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionsBloc>().add(const LoadTransactions());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topLeft,
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
          appBar: AppBar(
            scrolledUnderElevation: 0.0,
            title: const Text(
              'All Transactions',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: BlocBuilder<TransactionsBloc, TransactionsState>(
            builder: (context, state) {
              return state.status == TransactionsStatus.loading
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                      children: [
                        Expanded(
                          child: Stack(
                            children: [
                              SingleChildScrollView(
                                physics: const BouncingScrollPhysics(),
                                child: Column(
                                  children: [
                                    const SizedBox(
                                      height: 100,
                                    ),
                                    _buildMonthlySummary(state),
                                    _buildTransactionsList(context, state),
                                  ],
                                ),
                              ),
                              _buildMonthSelector(context, state),
                            ],
                          ),
                        ),
                      ],
                    );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMonthSelector(BuildContext context, TransactionsState state) {
    final months = state.availableMonths;
    // final currentIndex = months.indexOf(state.currentMonth);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(15),
              border: Border.all(
                color: Colors.white.withAlpha(20),
              ),
            ),
            child: Row(
              children: [
                // IconButton(
                //   icon: const Icon(Icons.chevron_left, color: Colors.white),
                //   onPressed: currentIndex > 0
                //       ? () {
                //           final newMonth = months[currentIndex - 1];
                //           final newMonthDate = DateFormat('yyyy-MM').parse(newMonth);
                //           context
                //               .read<TransactionsBloc>()
                //               .add(ChangeMonth(newMonthDate));
                //         }
                //       : null,
                // ),
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: months.length,
                      reverse: true,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, i) {
                        final m = months[i];
                        final isSelected = m == state.currentMonth;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeInOut,
                          decoration: BoxDecoration(
                            color:
                                isSelected ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(18),
                            onTap: () {
                              if (!isSelected) {
                                final newMonthDate =
                                    DateFormat('yyyy-MM').parse(m);
                                context
                                    .read<TransactionsBloc>()
                                    .add(ChangeMonth(newMonthDate));
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              child: Text(
                                _formatMonth(m),
                                style: TextStyle(
                                  color: isSelected
                                      ? const Color(0xFF23242B)
                                      : Colors.white,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                // IconButton(
                //   icon: const Icon(Icons.chevron_right, color: Colors.white),
                //   onPressed: currentIndex < months.length - 1
                //       ? () {
                //           final newMonth = months[currentIndex + 1];
                //           final newMonthDate = DateFormat('yyyy-MM').parse(newMonth);
                //           context
                //               .read<TransactionsBloc>()
                //               .add(ChangeMonth(newMonthDate));
                //         }
                //       : null,
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMonthlySummary(TransactionsState state) {
    final isPositive = state.netAmount >= 0;
    final color = isPositive ? Colors.green : Colors.red;
    final icon = isPositive ? Icons.trending_up : Icons.trending_down;
    return Stack(
      children: [
        Align(
          alignment: Alignment.topRight,
          child: Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: RotationTransition(
              turns: const AlwaysStoppedAnimation(90 / 120),
              child: Opacity(
                opacity: .9,
                child: Image.asset(
                  "assets/images/borderr.png",
                  height: 100,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(10),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withAlpha(20),
            ),
          ),
          child: Column(
            children: [
              // Text(
              //   _formatMonth(state.currentMonth),
              //   style: const TextStyle(
              //     fontSize: 18,
              //     fontWeight: FontWeight.bold,
              //     color: Colors.white,
              //   ),
              // ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Total Balance',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Icon(
                        icon,
                        color: color,
                      ),
                    ],
                  ),
                  Text(
                    '₹${state.netAmount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          RotationTransition(
                            turns: AlwaysStoppedAnimation(90 / 360),
                            child: Icon(Icons.arrow_outward_rounded),
                          ),
                          Text(
                            'Income',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '₹${state.totalCreditedAmount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.arrow_outward_rounded),
                          Text(
                            'Spends',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '₹${state.totalDebitedAmount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceAround,
              //   children: [
              //     _buildSummaryCard(
              //       'Credits',
              //       state.creditedCount.toString(),
              //       '₹${state.totalCreditedAmount.toStringAsFixed(2)}',
              //       Colors.green,
              //     ),
              //     _buildSummaryCard(
              //       'Debits',
              //       state.debitedCount.toString(),
              //       '₹${state.totalDebitedAmount.toStringAsFixed(2)}',
              //       Colors.red,
              //     ),
              //     _buildSummaryCard(
              //       'Net',
              //       state.transactions.length.toString(),
              //       '₹${state.netAmount.toStringAsFixed(2)}',
              //       state.netAmount >= 0 ? Colors.green : Colors.red,
              //     ),
              //   ],
              // ),
            ],
          ),
        ),
      ],
    );
  }

  // Widget _buildSummaryCard(
  Widget _buildTransactionsList(BuildContext context, TransactionsState state) {
    if (state.transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.receipt_long,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              'No transactions found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'for ${_formatMonth(state.currentMonth)}',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      // padding: const EdgeInsets.all(16),
      itemCount: state.transactions.length,
      padding: const EdgeInsets.only(top: 30),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final transaction = state.transactions[index];
        final isCredit = transaction['type'] == 'Credit';
        final color = isCredit ? Colors.green : Colors.red;
        String formattedDate = DateFormatter.formatDate(transaction['date']);
        String date =
            formattedDate == 'Invalid date format' ? 'Unknown' : formattedDate;
        // final icon = isCredit ? Icons.trending_up : Icons.trending_down;

        return InkWell(
          onTap: () {
            final bloc = context.read<TransactionsBloc>();
            Navigator.of(context)
                .push(
              MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: context.read<TransactionsBloc>(),
                  child: AddEditTransactionScreen(
                    banks: widget.banks,
                    transaction: transaction,
                  ),
                ),
              ),
            )
                .then((_) {
              if (mounted) {
                List data = bloc.state.currentMonth.split("-");
                bloc.add(ChangeMonth(
                    DateTime(int.parse(data.first), int.parse(data.last))));
              }
            });
          },
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            // decoration: BoxDecoration(
            //   color: Colors.white.withAlpha(10),
            //   borderRadius: BorderRadius.circular(15),
            //   border: Border.all(
            //     color: Colors.white.withAlpha(20),
            //   ),
            // ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    // color: color.withAlpha(30),
                    color: transaction['category'] != null
                        ? CategoryKeyWord.parseHexColor(
                                CategoryKeyWord.getIconAndColor(
                                        transaction['category'])['color'] ??
                                    '')
                            .withAlpha(30)
                        : null,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    transaction['category'] != null
                        ? CategoryKeyWord.getIconAndColor(
                                transaction['category'])['icon'] ??
                            ''
                        : "",
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction['upiIdOrSenderName'] ?? 'Unknown',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      // const SizedBox(height: 4),
                      // Text(
                      //   transaction['bank'] ?? 'Unknown Bank',
                      //   style: const TextStyle(
                      //     fontSize: 12,
                      //     color: Colors.grey,
                      //   ),
                      // ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_outlined,
                            size: 12,
                          ),
                          Text(
                            '  $date',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      '₹${transaction['amount'] ?? 'Unknown'}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    // const SizedBox(height: 4),
                    // Text(
                    //   transaction['type'] ?? 'Unknown',
                    //   style: TextStyle(
                    //     fontSize: 12,
                    //     color: color,
                    //     fontWeight: FontWeight.w500,
                    //   ),
                    // ),
                  ],
                ),
                // IconButton(
                //   icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                //   onPressed: () {
                //     _showDeleteConfirmationDialog(context, transaction);
                //   },
                // ),
              ],
            ),
          ),
        );
      },
    );
  }

  // void _showDeleteConfirmationDialog(
  String _formatMonth(String monthKey) {
    try {
      final parts = monthKey.split('-');
      if (parts.length == 2) {
        final year = parts[0];
        final month = int.parse(parts[1]);
        final date = DateTime(int.parse(year), month);
        return DateFormat('MMMM yyyy').format(date);
      }
    } catch (e) {
      // Handle parsing errors
    }
    return monthKey;
  }
}
