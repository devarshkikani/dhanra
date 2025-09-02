import 'dart:ui';

import 'package:dhanra/features/stats_screen/presentation/widget/category_details_utils.dart';
import 'package:flutter/material.dart';

class SummaryCard extends StatelessWidget {
  const SummaryCard({
    super.key,
    required this.category,
    required this.catColor,
    required this.catIcon,
    required this.stats,
    required this.avg,
    required this.max,
    required this.min,
    required this.total,
  });
  final Color catColor;
  final String catIcon;
  final String category;
  final Stats stats;
  final double total;
  final double min;
  final double max;
  final double avg;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          margin: const EdgeInsets.only(bottom: 18),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                catColor.withAlpha(56),
                Colors.white.withAlpha(10),
                catColor.withAlpha(25),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: catColor.withAlpha(63), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: catColor.withAlpha(45),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [catColor.withAlpha(178), catColor.withAlpha(76)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: catColor.withAlpha(63),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    catIcon,
                    style: const TextStyle(
                        fontSize: 28,
                        color: Colors.white,
                        shadows: [
                          Shadow(blurRadius: 8, color: Colors.black26)
                        ]),
                  ),
                ),
              ),
              const SizedBox(width: 22),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category,
                      style: const TextStyle(
                        // color: catColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.savings,
                            color: Colors.white, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          '₹${total.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _summaryStat('Min', min, catColor),
                        const SizedBox(width: 12),
                        _summaryStat('Max', max, catColor),
                        const SizedBox(width: 12),
                        _summaryStat('Avg', avg, catColor),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summaryStat(String label, double value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                color: color.withAlpha(178),
                fontSize: 11,
                fontWeight: FontWeight.w500)),
        Text('₹${value.toStringAsFixed(2)}',
            style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold)),
      ],
    );
  }
}
