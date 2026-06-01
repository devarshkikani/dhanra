import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class ExpenseChart extends StatelessWidget {
  final Map<String, double> spentPerCategory;

  const ExpenseChart({super.key, required this.spentPerCategory});

  @override
  Widget build(BuildContext context) {
    if (spentPerCategory.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(
          child: Text(
            'No data to display',
            style: TextStyle(color: Colors.white54),
          ),
        ),
      );
    }

    final sortedEntries = spentPerCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final List<Color> colors = [
      AppColors.primary,
      Colors.blue,
      Colors.purple,
      Colors.orange,
      Colors.teal,
      Colors.pink,
      Colors.amber,
    ];

    return SizedBox(
      height: 200,
      child: PieChart(
        PieChartData(
          sectionsSpace: 4,
          centerSpaceRadius: 40,
          sections: List.generate(
            sortedEntries.length > 5 ? 5 : sortedEntries.length,
            (i) {
              final entry = sortedEntries[i];
              return PieChartSectionData(
                color: colors[i % colors.length],
                value: entry.value,
                title: '${((entry.value / spentPerCategory.values.reduce((a, b) => a + b)) * 100).toStringAsFixed(0)}%',
                radius: 50,
                titleStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
