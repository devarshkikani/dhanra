import 'package:dhanra/core/routing/route_names.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/investment_option.dart';
import 'risk_pie_chart.dart';
import 'risk_bar_chart.dart';
import 'risk_donut_chart.dart';
import 'investment_gemini_service.dart';

class RiskCategoryWidget extends StatelessWidget {
  final RiskLevel riskLevel;
  final List<InvestmentOption> options;
  final double userAmount;

  const RiskCategoryWidget({
    Key? key,
    required this.riskLevel,
    required this.options,
    required this.userAmount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget chart;
    Color color;
    // String riskLabel;
    IconData riskIcon;
    switch (riskLevel) {
      case RiskLevel.high:
        chart = RiskPieChart(
          options: options,
          color: Colors.redAccent,
        );
        color = Colors.redAccent;
        // riskLabel = 'High Risk';
        riskIcon = Icons.warning_amber_rounded;
        break;
      case RiskLevel.medium:
        chart = RiskBarChart(
          options: options,
          color: Colors.amber,
        );
        color = Colors.amber;
        // riskLabel = 'Medium Risk';
        riskIcon = Icons.trending_up_rounded;
        break;
      case RiskLevel.low:
        chart = RiskDonutChart(
          options: options,
          color: Colors.green,
        );
        color = Colors.green;
        // riskLabel = 'Low Risk';
        riskIcon = Icons.verified_user_rounded;
        break;
    }

    // String getRiskDescription() {
    //   switch (riskLevel) {
    //     case RiskLevel.high:
    //       return 'High volatility, high potential returns. Suitable for aggressive investors.';
    //     case RiskLevel.medium:
    //       return 'Balanced risk and return. Suitable for most investors.';
    //     case RiskLevel.low:
    //       return 'Stable, low risk investments. Suitable for conservative investors.';
    //   }
    // }

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 18),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(15),
            border: Border.all(
              color: Colors.white.withAlpha(20),
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: color.withValues(alpha: 0.15),
                  radius: 22,
                  child: Icon(riskIcon, color: color, size: 28),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Available',
                      style: TextStyle(
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      '₹${userAmount.toStringAsFixed(2)}',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: color),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        chart,
        const SizedBox(height: 40),
        ...options.map((option) => Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                title: Text(option.name,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(option.description),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${option.potentialReturn}%',
                      style: TextStyle(
                        color: color,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      height: 2,
                    ),
                    Text(
                      '${option.risk}% risk',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                onTap: () {
                  context.push(AppRoute.investmentDetails.path, extra: {
                    'option': option,
                    'userAmount': userAmount,
                  });
                  // Navigator.of(context).push(
                  //   MaterialPageRoute(
                  //     builder: (_) => InvestmentDetailsScreen(
                  //       option: option,
                  //       userAmount: userAmount,
                  //     ),
                  //   ),
                  // );
                },
              ),
            )),
      ],
    );
  }
}

class InvestmentDetailsScreen extends StatelessWidget {
  final InvestmentOption option;
  final double userAmount;

  const InvestmentDetailsScreen({
    Key? key,
    required this.option,
    required this.userAmount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(option.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(option.description, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            Text('Available to invest: ₹${userAmount.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            const Text('Recent Opportunities:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Expanded(
              child: FutureBuilder<List<String>>(
                future: InvestmentGeminiService.fetchRecentOpportunities(
                    option.name),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Text('Error: \\${snapshot.error}');
                  }
                  final data = snapshot.data ?? [];
                  if (data.isEmpty) {
                    return const Text('No recent opportunities found.');
                  }
                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    itemCount: data.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      return Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          leading: const Icon(Icons.trending_up,
                              color: Colors.blueAccent),
                          title: Text(data[index],
                              style: const TextStyle(fontSize: 15)),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
