import 'package:dhanra/features/transactions/presentation/bloc/transaction_cubit.dart';
import 'package:dhanra/features/transactions/presentation/bloc/transaction_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
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
      final filteredMessages = state.transactionMessages
          .where((t) => (t['date'] ?? '').contains(_selectedMonth))
          .toList();

      return Scaffold(
        appBar: AppBar(
          title: const Text('Transaction Messages'),
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          actions: [
            PopupMenuButton<String>(
              onSelected: _onMonthChanged,
              itemBuilder: (context) => _getMonthOptions().map((month) {
                return PopupMenuItem(
                  value: month,
                  child: Text(_formatMonthDisplay(month)),
                );
              }).toList(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_formatMonthDisplay(_selectedMonth)),
                    const Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),
            ),
          ],
        ),
        body: filteredMessages.isEmpty
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.message_outlined,
                      size: 64,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No transaction messages found for this month',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: filteredMessages.length,
                itemBuilder: (context, index) {
                  final message = filteredMessages[index];
                  final isCredit = message['type'] == 'Credit';
                  final color = isCredit ? Colors.green : Colors.red;
                  final icon =
                      isCredit ? Icons.trending_up : Icons.trending_down;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ExpansionTile(
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
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
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
                      subtitle: Text(
                        '₹${message['amount'] ?? 'Unknown'}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildDetailRow('Amount',
                                  '₹${message['amount'] ?? 'Unknown'}'),
                              _buildDetailRow(
                                  'Type', message['type'] ?? 'Unknown'),
                              _buildDetailRow(
                                  'Date', message['date'] ?? 'Unknown'),
                              _buildDetailRow(
                                  'Sender', message['sender'] ?? 'Unknown'),
                              const SizedBox(height: 12),
                              const Text(
                                'Message:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(message['body'] ?? 'No message content'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
      );
    });
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
