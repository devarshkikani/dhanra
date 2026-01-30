import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/investment_option.dart';
import 'dart:math';

class RiskDonutChart extends StatelessWidget {
  final List<InvestmentOption> options;
  final Color color;
  final int? highlightIndex;

  const RiskDonutChart({
    Key? key,
    required this.options,
    required this.color,
    this.highlightIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Find the index to highlight (default: largest value)
    int highlight = highlightIndex ??
        (options.isNotEmpty
            ? options.indexWhere((o) =>
                o.potentialReturn ==
                options.map((e) => e.potentialReturn).reduce(max))
            : 0);
    // Calculate total for percentage
    final total =
        options.fold<double>(0.0, (sum, o) => sum + o.potentialReturn);
    // Calculate the angle for the remaining amount line (after the last section)
    double startAngle = -pi / 2;
    List<double> angles = [];
    for (var o in options) {
      final sweep = (o.potentialReturn / total) * 2 * pi;
      angles.add(startAngle + sweep / 2);
      startAngle += sweep;
    }
    // We'll use the last angle for the remaining line
    // final remainingAngle = angles.isNotEmpty ? angles.last : -pi / 2;

    return SizedBox(
      height: 200,
      width: 200,
      child: Stack(
        children: [
          PieChart(
            PieChartData(
              sections: List.generate(options.length, (i) {
                final isHighlighted = i == highlight;
                final percent =
                    total > 0 ? (options[i].potentialReturn / total * 100) : 0;
                return PieChartSectionData(
                  value: options[i].potentialReturn,
                  color: color.withValues(alpha: 0.7 - i * 0.2),
                  title: '${options[i].name}\n${percent.toStringAsFixed(2)} %',
                  titleStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                  radius: isHighlighted ? 60 : 50,
                  titlePositionPercentageOffset: 1.25,
                );
              }),
              sectionsSpace: 2,
              centerSpaceRadius: 50,
            ),
          ),
        ],
      ),
    );
  }
}

class RemainingLinePainter extends CustomPainter {
  final double remainingAmount;
  final double angle;
  RemainingLinePainter({required this.remainingAmount, required this.angle});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blueAccent
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    final center = Offset(size.width / 2, size.height / 2);
    final length = size.width / 2 - 10;
    final end = Offset(
      center.dx + length * cos(angle),
      center.dy + length * sin(angle),
    );
    canvas.drawLine(center, end, paint);
    // Draw a small circle at the end
    canvas.drawCircle(end, 6, paint..style = PaintingStyle.fill);
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
    textPainter.paint(canvas, end + const Offset(8, -8));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
