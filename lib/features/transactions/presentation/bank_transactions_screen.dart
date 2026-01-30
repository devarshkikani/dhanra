import 'dart:ui';

import 'package:dhanra/core/routing/route_names.dart';
import 'package:dhanra/core/services/local_storage_service.dart';
import 'package:dhanra/core/theme/gradients.dart';
import 'package:dhanra/core/utils/date_formatter.dart';
import 'package:dhanra/core/utils/get_bank_image.dart';
import 'package:dhanra/features/transactions/bloc/transactions_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class BankTransactionsScreen extends StatelessWidget {
  const BankTransactionsScreen(
      {super.key, required this.bank, required this.banks});

  final String bank;
  final List<String> banks;

  Map<String, List<Map<String, dynamic>>> _groupByMonth(
      List<Map<String, dynamic>> txs) {
    final Map<String, List<Map<String, dynamic>>> byMonth = {};
    for (final t in txs) {
      final dateStr = '${t['date']}';
      DateTime? date;
      try {
        date = DateTime.fromMillisecondsSinceEpoch(int.parse(dateStr));
      } catch (_) {}
      if (date == null) continue;
      final key = DateFormat('yyyy-MM').format(date);
      byMonth.putIfAbsent(key, () => []).add(t);
    }
    // sort each month's list by date desc
    for (final e in byMonth.entries) {
      e.value.sort((a, b) => '${b['date']}'.compareTo('${a['date']}'));
    }
    // sort months desc
    final sorted = Map.fromEntries(
        byMonth.entries.toList()..sort((a, b) => b.key.compareTo(a.key)));
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    final storage = LocalStorageService();
    final months = storage.getAvailableMonths();
    final List<Map<String, dynamic>> txs = [];
    for (final m in months) {
      txs.addAll(storage.getMonthlyData(m).where((t) => t['bank'] == bank));
    }
    final grouped = _groupByMonth(txs);
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
            backgroundColor: Colors.transparent,
            scrolledUnderElevation: 0.0,
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: GetBankImage.isCashBank(bank)
                      ? const Icon(
                          Icons.account_balance_wallet,
                          size: 22,
                          color: Colors.black,
                        )
                      : (GetBankImage.getBankImagePath(bank) == null
                          ? const Icon(
                              Icons.account_balance,
                              size: 22,
                              color: Colors.black,
                            )
                          : Image.asset(
                              GetBankImage.getBankImagePath(bank) ?? '',
                              height: 24,
                              width: 24,
                              fit: BoxFit.cover,
                            )),
                ),
                const SizedBox(width: 10),
                Text(bank),
              ],
            ),
          ),
          body: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: grouped.length,
            itemBuilder: (context, i) {
              final monthKey = grouped.keys.elementAt(i);
              final monthName = _formatMonth(monthKey);
              final monthTxs = grouped[monthKey]!;
              return _MonthSection(
                title: monthName,
                txs: monthTxs,
                banks: banks,
              );
            },
          ),
        ),
      ],
    );
  }

  String _formatMonth(String key) {
    try {
      final parts = key.split('-');
      final y = int.parse(parts[0]);
      final m = int.parse(parts[1]);
      return DateFormat('MMMM yyyy').format(DateTime(y, m));
    } catch (_) {
      return key;
    }
  }
}

class _MonthSection extends StatelessWidget {
  const _MonthSection(
      {required this.title, required this.txs, required this.banks});
  final String title;
  final List<Map<String, dynamic>> txs;
  final List<String> banks;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withAlpha(20)),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: txs.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final t = txs[index];
                  final isCredit = t['type'] == 'Credit';
                  final color = isCredit ? Colors.green : Colors.red;
                  final date = DateFormatter.formatDate('${t['date']}');
                  return ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    onTap: () {
                      context.push(AppRoute.addEditTransaction.path, extra: {
                        'banks': banks,
                        'transaction': t,
                      }).then((_) {
                        if (context.mounted) {
                          context
                              .read<TransactionsBloc>()
                              .add(const LoadTransactions());
                        }
                      });
                      // Navigator.of(context).push(
                      //   MaterialPageRoute(
                      //     builder: (_) => BlocProvider.value(
                      //       value: context.read<TransactionsBloc>(),
                      //       child: AddEditTransactionScreen(
                      //         banks: banks,
                      //         transaction: t,
                      //       ),
                      //     ),
                      //   ),
                      // );
                    },
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            t['upiIdOrSenderName'] ?? 'Unknown',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        Text(
                          '₹${t['amount'] ?? 'Unknown'}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                    subtitle: Text(
                      date == 'Invalid date format' ? 'Unknown' : date,
                      style: const TextStyle(fontSize: 12),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
