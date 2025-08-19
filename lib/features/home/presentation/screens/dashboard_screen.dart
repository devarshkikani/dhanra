import 'package:dhanra/features/transactions/presentation/bloc/transaction_cubit.dart';
import 'package:dhanra/features/transactions/presentation/bloc/transaction_state.dart';
import 'package:dhanra/presentation/widgets/shimmer_loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _selectedMonth = '';

  @override
  void initState() {
    super.initState();
    _selectedMonth = _getCurrentMonth();
  }

  String _getCurrentMonth() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}';
  }

  void _onMonthChanged(String? month) {
    if (month != null) {
      setState(() {
        _selectedMonth = month;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionCubit, TransactionState>(
      builder: (context, state) {
        final isLoading = state.status == TransactionStatus.loading;
        final filteredMessages = state.transactionMessages
            .where((t) => (t['date'] ?? '').contains(_selectedMonth))
            .toList();

        return Scaffold(
          appBar: AppBar(
            title: const Text('Dhanra Dashboard'),
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
          ),
          body: isLoading
              ? _buildShimmerLoading()
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildMonthSelector(),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildSummaryCard(
                              'Total SMS',
                              state.totalSmsCount.toString(),
                              Icons.message,
                              Colors.blue,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildSummaryCard(
                              'Transactions',
                              state.transactionMessages.length.toString(),
                              Icons.swap_horiz,
                              Colors.orange,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildSummaryCard(
                              'Credits',
                              state.creditedMessagesCount.toString(),
                              Icons.trending_up,
                              Colors.green,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildSummaryCard(
                              'Debits',
                              state.debitedMessagesCount.toString(),
                              Icons.trending_down,
                              Colors.red,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildNetAmountCard(
                        state.netAmount,
                        state.totalCreditedAmount,
                        state.totalDebitedAmount,
                      ),
                      const SizedBox(height: 24),
                      _buildTransactionMessagesSection(filteredMessages),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget _buildShimmerLoading() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Month selector shimmer
          const ShimmerCard(height: 50),
          const SizedBox(height: 16),

          // Summary cards shimmer
          const Row(
            children: [
              Expanded(child: ShimmerDashboardCard()),
              SizedBox(width: 12),
              Expanded(child: ShimmerDashboardCard()),
            ],
          ),
          const SizedBox(height: 16),

          const Row(
            children: [
              Expanded(child: ShimmerDashboardCard()),
              SizedBox(width: 12),
              Expanded(child: ShimmerDashboardCard()),
            ],
          ),
          const SizedBox(height: 16),

          // Net amount card shimmer
          const ShimmerDashboardCard(isAmountCard: true),
          const SizedBox(height: 24),

          // Transaction list shimmer
          ShimmerLoadingList(
            itemCount: 5,
            itemBuilder: (context, index) => const ShimmerTransactionItem(),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_today, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButton<String>(
              value: _selectedMonth,
              isExpanded: true,
              underline: const SizedBox(),
              items: _getMonthOptions().map((month) {
                return DropdownMenuItem(
                  value: month,
                  child: Text(_formatMonthDisplay(month)),
                );
              }).toList(),
              onChanged: _onMonthChanged,
            ),
          ),
        ],
      ),
    );
  }

  List<String> _getMonthOptions() {
    final months = <String>[];
    final now = DateTime.now();

    // Add last 6 months
    for (int i = 0; i < 6; i++) {
      final date = DateTime(now.year, now.month - i);
      months.add('${date.year}-${date.month.toString().padLeft(2, '0')}');
    }

    return months;
  }

  String _formatMonthDisplay(String month) {
    final parts = month.split('-');
    final year = parts[0];
    final monthNum = int.parse(parts[1]);
    final monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return '${monthNames[monthNum - 1]} $year';
  }

  Widget _buildSummaryCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNetAmountCard(
    double netAmount,
    double totalCreditedAmount,
    double totalDebitedAmount,
  ) {
    final isPositive = netAmount >= 0;
    final color = isPositive ? Colors.green : Colors.red;
    final icon = isPositive ? Icons.trending_up : Icons.trending_down;

    return Card(
      elevation: 4,
      color: color.shade50,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Icon(
              icon,
              size: 40,
              color: color,
            ),
            const SizedBox(height: 12),
            Text(
              '₹${netAmount.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const Text(
              'Net Amount',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Credit:'),
                Text(
                  '₹${totalCreditedAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Debit:'),
                Text(
                  '₹${totalDebitedAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionMessagesSection(List<Map<String, String>> messages) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Transaction Messages',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        if (messages.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Center(
                child: Text(
                  'No transaction messages found',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final message = messages[index];
              final isCredit = message['type'] == 'Credit';
              final color = isCredit ? Colors.green : Colors.red;
              final icon = isCredit ? Icons.trending_up : Icons.trending_down;

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: color.shade100,
                    child: Icon(
                      icon,
                      color: color.shade700,
                    ),
                  ),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          message['bank'] ?? 'Unknown Bank',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: color.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          message['type'] ?? 'Unknown',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: color.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '₹${message['amount'] ?? 'Unknown'}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      Text(
                        'Date: ${message['date'] ?? 'Unknown'}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    _showMessageDetails(message);
                  },
                ),
              );
            },
          ),
      ],
    );
  }

  void _showMessageDetails(Map<String, String> message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(message['bank'] ?? 'Unknown Bank'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Amount: ₹${message['amount'] ?? 'Unknown'}'),
            const SizedBox(height: 8),
            Text('Type: ${message['type'] ?? 'Unknown'}'),
            const SizedBox(height: 8),
            Text('Date: ${message['date'] ?? 'Unknown'}'),
            const SizedBox(height: 8),
            Text('Sender: ${message['sender'] ?? 'Unknown'}'),
            const SizedBox(height: 16),
            const Text(
              'Message:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(message['body'] ?? 'No message content'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
