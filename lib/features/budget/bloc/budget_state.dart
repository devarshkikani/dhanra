part of 'budget_bloc.dart';

abstract class BudgetState extends Equatable {
  const BudgetState();

  @override
  List<Object?> get props => [];
}

class BudgetInitial extends BudgetState {}

class BudgetLoading extends BudgetState {}

class BudgetLoaded extends BudgetState {
  final Budget? budget;
  final Map<String, double> spentPerCategory;
  final double totalSpent;
  final String month;
  final List<Map<String, dynamic>> transactions;

  const BudgetLoaded({
    this.budget,
    required this.spentPerCategory,
    required this.totalSpent,
    required this.month,
    required this.transactions,
  });

  @override
  List<Object?> get props => [budget, spentPerCategory, totalSpent, month, transactions];
}

class BudgetError extends BudgetState {
  final String message;
  const BudgetError(this.message);

  @override
  List<Object?> get props => [message];
}
