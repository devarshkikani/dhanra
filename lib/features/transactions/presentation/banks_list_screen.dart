import 'package:dhanra/core/services/local_storage_service.dart';
import 'package:dhanra/core/theme/gradients.dart';
import 'package:dhanra/core/utils/get_bank_image.dart';
import 'package:dhanra/features/transactions/presentation/bank_transactions_screen.dart';
import 'package:flutter/material.dart';
import 'package:dhanra/core/services/sms_parser_service.dart';

class BanksListScreen extends StatelessWidget {
  const BanksListScreen({super.key, required this.banks});

  final List<String> banks;

  @override
  Widget build(BuildContext context) {
    final uniqueBanks = <String>{...banks}
      ..removeWhere((b) => b.trim().isEmpty);
    uniqueBanks.add('Cash');
    final sorted = uniqueBanks.toList()..sort();

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
            title: const Text('Select Bank'),
          ),
          body: _BanksBody(banks: sorted),
        ),
      ],
    );
  }
}

class _BanksBody extends StatelessWidget {
  const _BanksBody({required this.banks});
  final List<String> banks;

  List<Map<String, dynamic>> _buildAccountSummaries() {
    final storage = LocalStorageService();
    final parser = SmsParserService.instance;

    final allMonths = storage.getAvailableMonths();
    final List<Map<String, dynamic>> allTime = [];
    for (final m in allMonths) {
      allTime.addAll(storage.getMonthlyData(m));
    }
    final summaries = parser.generateAccountSummaries(allTime);
    return summaries;
  }

  @override
  Widget build(BuildContext context) {
    final summaries = _buildAccountSummaries();

    // Filter to selected banks list preserving order
    final filtered = summaries
        .where((a) => banks.contains(a['bank']))
        .toList(growable: false);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView.separated(
        itemCount: filtered.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final account = filtered[index];
          final bank = account['bank'] ?? 'Unknown Bank';
          final lastFourDigits = account['lastFourDigits'] ?? '';
          final totalReceived = account['totalReceived'] ?? 0.0;
          final totalSpent = account['totalSpent'] ?? 0.0;
          final transactionCount = account['transactionCount'] ?? 0;
          final hasBalanceSms = account['hasBalanceSms'] ?? false;

          final imagePath = GetBankImage.getBankImagePath(bank);

          return GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => BankTransactionsScreen(
                    bank: bank,
                    banks: banks,
                  ),
                ),
              );
            },
            child: Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(10),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: Colors.white.withAlpha(20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: GetBankImage.isCashBank(bank)
                            ? const Icon(
                                Icons.account_balance_wallet,
                                size: 26,
                                color: Colors.black,
                              )
                            : (imagePath == null
                                ? const Icon(
                                    Icons.account_balance,
                                    size: 26,
                                    color: Colors.black,
                                  )
                                : Image.asset(
                                    imagePath,
                                    height: 30,
                                    width: 30,
                                    fit: BoxFit.cover,
                                  )),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              bank,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (lastFourDigits.isNotEmpty)
                              Text(
                                '****$lastFourDigits',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Row(
                                children: [
                                  Text(
                                    'Received',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  SizedBox(width: 2),
                                ],
                              ),
                              if (hasBalanceSms) ...[
                                const SizedBox(width: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 4, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withAlpha(50),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'LIVE',
                                    style: TextStyle(
                                      fontSize: 8,
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          Text(
                            '₹${(totalReceived as double).toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'Spent',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            '₹${(totalSpent as double).toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$transactionCount transactions',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
