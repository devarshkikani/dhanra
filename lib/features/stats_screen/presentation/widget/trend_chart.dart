import 'package:dhanra/features/stats_screen/presentation/widget/category_details_utils.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TrendChartUI extends StatelessWidget {
  const TrendChartUI({
    super.key,
    required this.catColor,
    required this.chartMax,
    required this.periodData,
  });

  final Color catColor;
  final double chartMax;
  final List<PeriodData> periodData;

  @override
  Widget build(BuildContext context) {
    return Container(
      // margin: const EdgeInsets.only(
      //     top: 8, left: 8, right: 0, bottom: 0),
      padding: const EdgeInsets.only(top: 8, bottom: 0),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
      ),
      child: SizedBox(
        height: 200,
        child: LineChart(
          LineChartData(
            gridData: FlGridData(
              show: true,
              drawVerticalLine: true,
              drawHorizontalLine: true,
              horizontalInterval: (chartMax > 0 ? chartMax * 1.2 : 1) / 4,
              getDrawingHorizontalLine: (value) => const FlLine(
                color: Colors.white12,
                strokeWidth: 1,
              ),
              getDrawingVerticalLine: (value) => const FlLine(
                color: Colors.white12,
                strokeWidth: 1,
              ),
            ),
            titlesData: FlTitlesData(
              rightTitles: const AxisTitles(),
              topTitles: const AxisTitles(),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  interval: (chartMax > 0 ? chartMax * 1.2 : 1) / 4,
                  getTitlesWidget: (value, meta) {
                    final maxY = chartMax > 0 ? chartMax * 1.2 : 1;
                    final interval = maxY / 4;
                    if ((value % interval).abs() < 0.01 ||
                        (value - maxY).abs() < 0.01 ||
                        value == 0) {
                      return Text(
                        _formatCurrency(value),
                        style: const TextStyle(
                            color: Colors.white54, fontSize: 10),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    final idx = value.toInt();
                    if (idx < 0 || idx >= periodData.length) {
                      return const SizedBox();
                    }
                    return Text(
                      periodData[idx].label,
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 10),
                    );
                  },
                  interval: 1,
                  reservedSize: 32,
                ),
              ),
            ),
            borderData: FlBorderData(
              show: true,
              border: Border.all(color: Colors.white12),
            ),
            minX: 0,
            maxX: (periodData.length - 1).toDouble(),
            minY: 0,
            maxY: chartMax > 0 ? chartMax * 1.2 : 1,
            lineTouchData: LineTouchData(
              enabled: true,
              touchTooltipData: LineTouchTooltipData(
                getTooltipItems: (touchedSpots) {
                  return touchedSpots.map((LineBarSpot spot) {
                    return LineTooltipItem(
                      '₹${formatIndianCurrency(spot.y)}',
                      const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    );
                  }).toList();
                },
              ),
            ),
            lineBarsData: [
              LineChartBarData(
                isCurved: true,
                // color: catColor.withAlpha(178),
                barWidth: 3,
                gradient: LinearGradient(
                  colors: [
                    catColor.withAlpha(178),
                    catColor.withAlpha(130),
                    catColor.withAlpha(100),
                    catColor.withAlpha(70),

                    // Colors.white.withAlpha(10),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                spots: [
                  for (int i = 0; i < periodData.length; i++)
                    FlSpot(i.toDouble(), periodData[i].value),
                ],
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, bar, index) =>
                      FlDotCirclePainter(
                    radius: 5,
                    color: Colors.white,
                    strokeWidth: 2,
                    strokeColor: catColor.withAlpha(178),
                  ),
                ),

                belowBarData: BarAreaData(
                  show: true,
                  color: catColor.withAlpha(45),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatCurrency(double amount) {
    if (amount >= 10000000) {
      return '₹${(amount / 10000000).toStringAsFixed(2)}Cr';
    } else if (amount >= 100000) {
      return '₹${(amount / 100000).toStringAsFixed(2)}L';
    } else if (amount >= 1000) {
      return '₹${(amount / 1000).toStringAsFixed(2)}K';
    }
    return '₹${amount.toStringAsFixed(0)}';
  }

  String formatIndianCurrency(double value) {
    final formatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '', // You can add ₹ if needed
      decimalDigits: 2,
    );

    return formatter.format(value);
  }
}
