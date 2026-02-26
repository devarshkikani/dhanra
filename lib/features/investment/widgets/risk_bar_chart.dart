import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/investment_option.dart';
import 'dart:math';

class RiskBarChart extends StatelessWidget {
  final List<InvestmentOption> options;
  final Color color;

  const RiskBarChart({super.key, required this.options, required this.color});

  @override
  Widget build(BuildContext context) {
    // Find the max value for scaling
    final maxReturn = options.isNotEmpty
        ? options.map((o) => o.potentialReturn).reduce(max)
        : 1.0;
    return SizedBox(
      height: 200,
      width: 220,
      child: Stack(
        children: [
          BarChart(
            BarChartData(
              barGroups: options
                  .asMap()
                  .entries
                  .map((entry) => BarChartGroupData(
                        x: entry.key,
                        barRods: [
                          BarChartRodData(
                            toY: entry.value.potentialReturn,
                            color: color,
                            width: 18,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ],
                        showingTooltipIndicators: [0],
                      ))
                  .toList(),
              titlesData: FlTitlesData(
                leftTitles: const AxisTitles(),
                rightTitles: const AxisTitles(),
                topTitles: const AxisTitles(),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() < options.length) {
                        return Text(
                          options[value.toInt()].name,
                          style: const TextStyle(fontSize: 10),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ),
              gridData: const FlGridData(show: true),
              borderData: FlBorderData(show: false),
              alignment: BarChartAlignment.spaceAround,
              maxY: maxReturn * 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

class RemainingBarLinePainter extends CustomPainter {
  final int barCount;
  final double maxReturn;
  final double remainingAmount;
  RemainingBarLinePainter(
      {required this.barCount,
      required this.maxReturn,
      required this.remainingAmount});

  @override
  void paint(Canvas canvas, Size size) {
    // Draw a vertical line after the last bar
    final paint = Paint()
      ..color = Colors.blueAccent
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    final barWidth = size.width / (barCount + 2);
    final x = barWidth * (barCount + 0.5);
    final yStart = size.height * 0.1;
    final yEnd = size.height * 0.7;
    canvas.drawLine(Offset(x, yStart), Offset(x, yEnd), paint);
    // Draw a small circle at the end
    canvas.drawCircle(Offset(x, yStart), 6, paint..style = PaintingStyle.fill);
    // Draw label
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'Remaining\n₹${remainingAmount.toStringAsFixed(2)}',
        style: const TextStyle(
            color: Colors.blueAccent,
            fontSize: 12,
            fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(canvas, Offset(x + 8, yStart - 8));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
