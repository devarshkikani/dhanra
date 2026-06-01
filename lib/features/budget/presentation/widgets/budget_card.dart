import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class BudgetCard extends StatelessWidget {
  final double totalBudget;
  final double totalSpent;
  final String month;

  const BudgetCard({
    super.key,
    required this.totalBudget,
    required this.totalSpent,
    required this.month,
  });

  @override
  Widget build(BuildContext context) {
    final double remaining = totalBudget - totalSpent;
    final double progress = totalBudget > 0 ? (totalSpent / totalBudget).clamp(0.0, 1.0) : 0.0;
    final Color progressColor = progress >= 1.0 
        ? Colors.red 
        : progress >= 0.8 
            ? Colors.orange 
            : AppColors.primary;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(10),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withAlpha(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Budget',
                style: TextStyle(
                  color: Colors.white.withAlpha(150),
                  fontSize: 16,
                ),
              ),
              Text(
                month,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '₹${totalBudget.toStringAsFixed(0)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStat('Spent', '₹${totalSpent.toStringAsFixed(0)}', Colors.white),
              _buildStat('Remaining', '₹${remaining.toStringAsFixed(0)}', progressColor),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withAlpha(20),
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              minHeight: 10,
            ),
          ),
          if (progress >= 0.8) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  progress >= 1.0 ? Icons.error_outline : Icons.warning_amber_rounded,
                  color: progressColor,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  progress >= 1.0 ? 'Budget exceeded!' : 'Approaching budget limit (80%+)',
                  style: TextStyle(color: progressColor, fontSize: 12),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value, Color valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withAlpha(150),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
