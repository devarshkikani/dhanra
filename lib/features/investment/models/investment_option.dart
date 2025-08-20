enum RiskLevel { high, medium, low }

class InvestmentOption {
  final String name;
  final String description;
  final double potentialReturn; // as percentage
  final double risk; // as percentage
  final RiskLevel riskLevel;

  InvestmentOption({
    required this.name,
    required this.description,
    required this.potentialReturn,
    required this.risk,
    required this.riskLevel,
  });
}
