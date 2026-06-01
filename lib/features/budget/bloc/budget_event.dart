part of 'budget_bloc.dart';

abstract class BudgetEvent extends Equatable {
  const BudgetEvent();

  @override
  List<Object?> get props => [];
}

class LoadBudget extends BudgetEvent {
  final String month;
  const LoadBudget(this.month);

  @override
  List<Object?> get props => [month];
}

class SaveBudgetEvent extends BudgetEvent {
  final Budget budget;
  const SaveBudgetEvent(this.budget);

  @override
  List<Object?> get props => [budget];
}

class UpdateCategoryBudgetAmount extends BudgetEvent {
  final String category;
  final double amount;
  final String month;

  const UpdateCategoryBudgetAmount({
    required this.category,
    required this.amount,
    required this.month,
  });

  @override
  List<Object?> get props => [category, amount, month];
}
