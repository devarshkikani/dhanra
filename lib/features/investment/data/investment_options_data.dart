import '../models/investment_option.dart';

final List<InvestmentOption> investmentOptions = [
  // High Risk
  InvestmentOption(
    name: 'Cryptocurrency',
    description: 'Invest in Bitcoin, Ethereum, etc.',
    potentialReturn: 60,
    risk: 80,
    riskLevel: RiskLevel.high,
  ),
  InvestmentOption(
    name: 'Tech Startups',
    description: 'Crowdfunding or angel investing.',
    potentialReturn: 40,
    risk: 70,
    riskLevel: RiskLevel.high,
  ),
  InvestmentOption(
    name: 'Leveraged ETFs',
    description: 'Funds amplifying market movements.',
    potentialReturn: 30,
    risk: 60,
    riskLevel: RiskLevel.high,
  ),
  // Medium Risk
  InvestmentOption(
    name: 'Index Funds',
    description: 'Broad market exposure (e.g., S&P 500).',
    potentialReturn: 10,
    risk: 20,
    riskLevel: RiskLevel.medium,
  ),
  InvestmentOption(
    name: 'REITs',
    description: 'Real Estate Investment Trusts.',
    potentialReturn: 8,
    risk: 18,
    riskLevel: RiskLevel.medium,
  ),
  InvestmentOption(
    name: 'Balanced Mutual Funds',
    description: 'Mix of stocks and bonds.',
    potentialReturn: 7,
    risk: 15,
    riskLevel: RiskLevel.medium,
  ),
  // Low Risk
  InvestmentOption(
    name: 'Government Bonds',
    description: 'Sovereign or treasury bonds.',
    potentialReturn: 5,
    risk: 5,
    riskLevel: RiskLevel.low,
  ),
  InvestmentOption(
    name: 'Fixed Deposits',
    description: 'Bank FDs with fixed interest.',
    potentialReturn: 4,
    risk: 3,
    riskLevel: RiskLevel.low,
  ),
  InvestmentOption(
    name: 'Savings Account',
    description: 'High-yield savings.',
    potentialReturn: 3,
    risk: 1,
    riskLevel: RiskLevel.low,
  ),
];
