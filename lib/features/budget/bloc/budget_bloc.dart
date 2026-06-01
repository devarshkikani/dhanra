import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:dhanra/features/transactions/bloc/transactions_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';
import '../../../core/services/local_storage_service.dart';
import '../data/budget_database_helper.dart';
import '../models/budget_model.dart';

part 'budget_event.dart';
part 'budget_state.dart';

class BudgetBloc extends Bloc<BudgetEvent, BudgetState> {
  final BudgetDatabaseHelper _dbHelper = BudgetDatabaseHelper.instance;
  final LocalStorageService _storage = LocalStorageService();
  final TransactionsBloc _transactionsBloc;
  StreamSubscription? _transactionsSubscription;
  String _currentActiveMonth = DateFormat('yyyy-MM').format(DateTime.now());

  BudgetBloc(this._transactionsBloc) : super(BudgetInitial()) {
    on<LoadBudget>(_onLoadBudget);
    on<SaveBudgetEvent>(_onSaveBudget);
    on<UpdateCategoryBudgetAmount>(_onUpdateCategoryBudgetAmount);

    _transactionsSubscription = _transactionsBloc.stream.listen((state) {
      if (state.status == TransactionsStatus.success) {
        add(LoadBudget(_currentActiveMonth));
      }
    });
  }

  @override
  Future<void> close() {
    _transactionsSubscription?.cancel();
    return super.close();
  }

  Future<void> _onLoadBudget(LoadBudget event, Emitter<BudgetState> emit) async {
    _currentActiveMonth = event.month;
    emit(BudgetLoading());
    try {
      final budget = await _dbHelper.getBudgetForMonth(event.month);
      final transactions = _storage.getMonthlyData(event.month);

      final Map<String, double> spentPerCategory = {};
      double totalSpent = 0;

      for (var tx in transactions) {
        final amount = double.tryParse(tx['amount']?.toString() ?? '0') ?? 0;
        final category = tx['category']?.toString() ?? 'Others';
        
        spentPerCategory[category] = (spentPerCategory[category] ?? 0) + amount;
        totalSpent += amount;
      }

      emit(BudgetLoaded(
        budget: budget,
        spentPerCategory: spentPerCategory,
        totalSpent: totalSpent,
        month: event.month,
        transactions: transactions,
      ));
    } catch (e) {
      emit(BudgetError(e.toString()));
    }
  }

  Future<void> _onSaveBudget(SaveBudgetEvent event, Emitter<BudgetState> emit) async {
    try {
      await _dbHelper.saveBudget(event.budget);
      add(LoadBudget(event.budget.month));
    } catch (e) {
      emit(BudgetError(e.toString()));
    }
  }

  Future<void> _onUpdateCategoryBudgetAmount(
    UpdateCategoryBudgetAmount event,
    Emitter<BudgetState> emit,
  ) async {
    try {
      final currentBudget = await _dbHelper.getBudgetForMonth(event.month);
      if (currentBudget != null) {
        final categories = List<CategoryBudget>.from(currentBudget.categoryBudgets);
        final index = categories.indexWhere((c) => c.category == event.category);

        if (index != -1) {
          categories[index] = categories[index].copyWith(amount: event.amount);
        } else {
          categories.add(CategoryBudget(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            budgetId: currentBudget.id,
            category: event.category,
            amount: event.amount,
          ));
        }

        final updatedBudget = currentBudget.copyWith(categoryBudgets: categories);
        await _dbHelper.saveBudget(updatedBudget);
        add(LoadBudget(event.month));
      }
    } catch (e) {
      emit(BudgetError(e.toString()));
    }
  }
}
