import 'package:equatable/equatable.dart';

class Budget extends Equatable {
  final String id;
  final String month; // yyyy-MM
  final double totalBudget;
  final List<CategoryBudget> categoryBudgets;

  const Budget({
    required this.id,
    required this.month,
    required this.totalBudget,
    this.categoryBudgets = const [],
  });

  Budget copyWith({
    String? id,
    String? month,
    double? totalBudget,
    List<CategoryBudget>? categoryBudgets,
  }) {
    return Budget(
      id: id ?? this.id,
      month: month ?? this.month,
      totalBudget: totalBudget ?? this.totalBudget,
      categoryBudgets: categoryBudgets ?? this.categoryBudgets,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'month': month,
      'totalBudget': totalBudget,
    };
  }

  factory Budget.fromMap(Map<String, dynamic> map, List<CategoryBudget> categories) {
    return Budget(
      id: map['id'] as String,
      month: map['month'] as String,
      totalBudget: (map['totalBudget'] as num).toDouble(),
      categoryBudgets: categories,
    );
  }

  @override
  List<Object?> get props => [id, month, totalBudget, categoryBudgets];
}

class CategoryBudget extends Equatable {
  final String id;
  final String budgetId;
  final String category;
  final double amount;

  const CategoryBudget({
    required this.id,
    required this.budgetId,
    required this.category,
    required this.amount,
  });

  CategoryBudget copyWith({
    String? id,
    String? budgetId,
    String? category,
    double? amount,
  }) {
    return CategoryBudget(
      id: id ?? this.id,
      budgetId: budgetId ?? this.budgetId,
      category: category ?? this.category,
      amount: amount ?? this.amount,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'budgetId': budgetId,
      'category': category,
      'amount': amount,
    };
  }

  factory CategoryBudget.fromMap(Map<String, dynamic> map) {
    return CategoryBudget(
      id: map['id'] as String,
      budgetId: map['budgetId'] as String,
      category: map['category'] as String,
      amount: (map['amount'] as num).toDouble(),
    );
  }

  @override
  List<Object?> get props => [id, budgetId, category, amount];
}
