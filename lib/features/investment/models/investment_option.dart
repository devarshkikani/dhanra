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

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'potentialReturn': potentialReturn,
      'risk': risk,
      'riskLevel': riskLevel.index,
    };
  }

  factory InvestmentOption.fromMap(Map<String, dynamic> map) {
    return InvestmentOption(
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      potentialReturn: (map['potentialReturn'] ?? 0.0).toDouble(),
      risk: (map['risk'] ?? 0.0).toDouble(),
      riskLevel: RiskLevel.values[map['riskLevel'] ?? 2],
    );
  }
}
