import 'package:dhanra/core/constants/category_keyword.dart';
import 'package:dhanra/core/utils/date_formatter.dart';
import 'package:dhanra/features/transactions/bloc/transactions_bloc.dart';
import 'package:dhanra/features/transactions/presentation/add_edit_transaction_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TransactionList extends StatelessWidget {
  const TransactionList({
    super.key,
    required this.transactions,
    required this.banks,
    required this.lastDate,
    required this.startDate,
  });

  final List<Map<String, dynamic>> transactions;
  final List<String> banks;
  final DateTime? startDate;
  final DateTime? lastDate;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: transactions.length,
      physics: const BouncingScrollPhysics(),
      separatorBuilder: (_, __) => const Divider(
        color: Colors.white12,
        height: 0,
        indent: 0,
        thickness: 1,
      ),
      itemBuilder: (context, i) {
        final tx = transactions[i];
        final isCredit = tx['type'] == 'Credit';
        final color = isCredit ? Colors.green : Colors.red;
        final iconAndColor =
            CategoryKeyWord.getIconAndColor(tx['category'] ?? '');
        final txColor =
            CategoryKeyWord.parseHexColor(iconAndColor['color'] ?? '#2196F3');
        // final txIcon = iconAndColor['icon'] ?? '';
        String formattedDate = DateFormatter.formatDate(tx['date']);
        String date =
            formattedDate == 'Invalid date format' ? 'Unknown' : formattedDate;
        return InkWell(
          onTap: () {
            Navigator.of(context)
                .push(
              MaterialPageRoute(
                builder: (_) => AddEditTransactionScreen(
                  banks: banks,
                  transaction: tx,
                ),
              ),
            )
                .then((_) {
              context.read<TransactionsBloc>().add(
                    LoadTransactions(
                      startDate: startDate,
                      endDate: lastDate,
                    ),
                  );
            });
          },
          child: Container(
            // margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.symmetric(vertical: 8),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tx['upiIdOrSenderName'] ?? 'Unknown',
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
                          const Icon(Icons.calendar_today_outlined,
                              size: 12, color: Colors.white54),
                          Text('  $date',
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.white54)),
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
    );
  }
}
