import 'package:dhanra/core/theme/gradients.dart';
import 'package:dhanra/core/utils/date_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/budget_bloc.dart';

class CategoryDetailScreen extends StatelessWidget {
  final String category;
  final String month;
  final double budgetAmount;
  final double spentAmount;

  const CategoryDetailScreen({
    super.key,
    required this.category,
    required this.month,
    required this.budgetAmount,
    required this.spentAmount,
  });

  @override
  Widget build(BuildContext context) {
    final double remaining = budgetAmount - spentAmount;
    final double progress = budgetAmount > 0 ? (spentAmount / budgetAmount).clamp(0.0, 1.0) : 0.0;
    final Color color = progress >= 1.0 ? Colors.red : progress >= 0.8 ? Colors.orange : AppColors.primary;

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
          appBar: AppBar(
            title: Text('$category Budget', style: const TextStyle(fontWeight: FontWeight.bold)),
            backgroundColor: Colors.transparent,
          ),
          body: BlocBuilder<BudgetBloc, BudgetState>(
            builder: (context, state) {
              List<Map<String, dynamic>> filteredTransactions = [];
              if (state is BudgetLoaded) {
                filteredTransactions = state.transactions.where((tx) {
                  final txCategory = tx['category']?.toString() ?? 'Others';
                  return txCategory == category;
                }).toList();
                
                // Sort by date (newest first)
                filteredTransactions.sort((a, b) => (b['date'] ?? 0).compareTo(a['date'] ?? 0));
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: color.withAlpha(20),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: color.withAlpha(40)),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '₹${remaining.toStringAsFixed(0)}',
                            style: TextStyle(color: color, fontSize: 40, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            remaining >= 0 ? 'Remaining' : 'Overspent',
                            style: TextStyle(color: color.withAlpha(150), fontSize: 16),
                          ),
                          const SizedBox(height: 30),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildStat('Budget', '₹${budgetAmount.toStringAsFixed(0)}'),
                              _buildStat('Spent', '₹${spentAmount.toStringAsFixed(0)}'),
                            ],
                          ),
                          const SizedBox(height: 20),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: progress,
                              backgroundColor: Colors.white.withAlpha(10),
                              valueColor: AlwaysStoppedAnimation<Color>(color),
                              minHeight: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    const Text(
                      'Quick Adjust',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    _buildAdjustButton(context),
                    const SizedBox(height: 40),
                    const Text(
                      'Recent Transactions',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    if (filteredTransactions.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(40),
                          child: Text('No transactions for this category yet.', 
                              style: TextStyle(color: Colors.white54), textAlign: TextAlign.center),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredTransactions.length,
                        itemBuilder: (context, index) {
                          final tx = filteredTransactions[index];
                          final amount = double.tryParse(tx['amount']?.toString() ?? '0') ?? 0;
                          final date = DateFormatter.formatDate(tx['date']);
                          final name = tx['upiIdOrSenderName'] ?? 'Unknown';
                          
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(5),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(name, 
                                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                                          maxLines: 1, overflow: TextOverflow.ellipsis),
                                      Text(date, 
                                          style: TextStyle(color: Colors.white.withAlpha(100), fontSize: 12)),
                                    ],
                                  ),
                                ),
                                Text('₹${amount.toStringAsFixed(0)}', 
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          );
                        },
                      ),
                    const SizedBox(height: 20),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildAdjustButton(BuildContext context) {
    return InkWell(
      onTap: () {
        final controller = TextEditingController(text: budgetAmount.toStringAsFixed(0));
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.grey.shade900,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
          builder: (context) => Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Edit Category Budget', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  autofocus: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'New Amount',
                    labelStyle: TextStyle(color: Colors.white70),
                    prefixText: '₹ ',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final amount = double.tryParse(controller.text) ?? 0;
                      context.read<BudgetBloc>().add(UpdateCategoryBudgetAmount(
                        category: category,
                        amount: amount,
                        month: month,
                      ));
                      Navigator.pop(context);
                      Navigator.pop(context); // Go back to home after edit
                    },
                    child: const Text('Save Changes'),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withAlpha(10)),
        ),
        child: const Row(
          children: [
            Icon(Icons.edit_outlined, color: AppColors.primary),
             SizedBox(width: 12),
            Text('Change Budget Amount', style: TextStyle(color: Colors.white)),
            Spacer(),
            Icon(Icons.chevron_right, color: Colors.white54),
          ],
        ),
      ),
    );
  }
}
