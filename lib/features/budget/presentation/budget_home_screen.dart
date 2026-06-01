import 'package:dhanra/core/theme/gradients.dart';
import 'package:dhanra/features/stats_screen/presentation/widget/category_details_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/budget_bloc.dart';
import 'widgets/budget_card.dart';
import 'widgets/expense_chart.dart';

class BudgetHomeScreen extends StatefulWidget {
  const BudgetHomeScreen({super.key});

  @override
  State<BudgetHomeScreen> createState() => _BudgetHomeScreenState();
}

class _BudgetHomeScreenState extends State<BudgetHomeScreen> {
  late String _currentMonth;
  late DateTime _currentStartDate;
  late DateTime _currentEndDate;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _currentStartDate = DateTime(now.year, now.month, 1);
    _currentEndDate = DateTime(now.year, now.month + 1, 0);
    _currentMonth = DateFormat('yyyy-MM').format(_currentStartDate);
    context.read<BudgetBloc>().add(LoadBudget(_currentMonth));
  }

  void _navigateMonth(bool isPrevious) {
    final newKey = isPrevious
        ? CategoryDetailsUtils.getPreviousPeriod('Monthly', _currentStartDate)
        : CategoryDetailsUtils.getNextPeriod('Monthly', _currentStartDate);

    final dates = CategoryDetailsUtils.updatePeriodDates(
        'Monthly', newKey, _currentStartDate, _currentEndDate);

    setState(() {
      _currentStartDate = dates.start;
      _currentEndDate = dates.end;
      _currentMonth = DateFormat('yyyy-MM').format(_currentStartDate);
    });

    context.read<BudgetBloc>().add(LoadBudget(_currentMonth));
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Gradients.gradient(
          top: -MediaQuery.of(context).size.height,
          left: -MediaQuery.of(context).size.width,
          right: 0,
          context: context,
        ),
        Image.asset(
          "assets/images/circle_ui.png",
          opacity: const AlwaysStoppedAnimation(.8),
          fit: BoxFit.cover,
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            leading: SizedBox.shrink(),
            centerTitle: false,
            titleSpacing: 0,
            leadingWidth: 20,
            title: Text(
              'Budget Planning',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            backgroundColor: Colors.transparent,
            actions: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left, color: Colors.white),
                    onPressed: CategoryDetailsUtils.canGoToPrevious(
                            'Monthly', _currentStartDate)
                        ? () {
                            _navigateMonth(true);
                          }
                        : null,
                  ),
                  Text(
                    CategoryDetailsUtils.getPeriodLabel(
                        'Monthly', _currentStartDate, _currentEndDate),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right, color: Colors.white),
                    onPressed: CategoryDetailsUtils.canGoToNext(
                            'Monthly', _currentEndDate)
                        ? () {
                            _navigateMonth(false);
                          }
                        : null,
                  ),
                ],
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: BlocBuilder<BudgetBloc, BudgetState>(
            builder: (context, state) {
              if (state is BudgetLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is BudgetLoaded) {
                final budget = state.budget;

                if (budget == null) {
                  return _buildEmptyState();
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BudgetCard(
                        totalBudget: budget.totalBudget,
                        totalSpent: state.totalSpent,
                        month: DateFormat('MMMM yyyy')
                            .format(DateTime.parse('${state.month}-01')),
                      ),
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Spending Analysis',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton(
                            onPressed: () => context.pushNamed(
                              AppRoute.createBudget.name,
                              extra: {
                                'month': _currentMonth,
                                'existingBudget': budget,
                              },
                            ),
                            child: Text(
                              'Edit Budget',
                              style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      ExpenseChart(spentPerCategory: state.spentPerCategory),
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Category Budgets',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ...budget.categoryBudgets.map((cat) => _buildCategoryRow(
                            context,
                            cat.category,
                            cat.amount,
                            state.spentPerCategory[cat.category] ?? 0,
                            state.month,
                          )),
                      const SizedBox(height: 100), // Space for FAB/Bottom bar
                    ],
                  ),
                );
              }

              if (state is BudgetError) {
                return Center(
                    child: Text(state.message,
                        style: const TextStyle(color: Colors.red)));
              }

              return const SizedBox();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.account_balance_wallet_outlined,
              size: 80, color: Colors.white.withAlpha(50)),
          const SizedBox(height: 20),
          const Text(
            'No budget set for this month',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () => context.pushNamed(AppRoute.createBudget.name,
                extra: {'month': _currentMonth}),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Set Monthly Budget',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryRow(BuildContext context, String category, double budget,
      double spent, String month) {
    final progress = budget > 0 ? (spent / budget).clamp(0.0, 1.0) : 0.0;
    final color = progress >= 1.0
        ? Colors.red
        : progress >= 0.8
            ? Colors.orange
            : AppColors.primary;

    return InkWell(
      onTap: () => context.pushNamed(
        AppRoute.categoryBudgetDetail.name,
        extra: {
          'category': category,
          'month': month,
          'budgetAmount': budget,
          'spentAmount': spent,
        },
      ),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(5),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(category,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w500)),
                Text(
                    '₹${spent.toStringAsFixed(0)} / ₹${budget.toStringAsFixed(0)}',
                    style: TextStyle(
                        color: Colors.white.withAlpha(150), fontSize: 12)),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.white.withAlpha(10),
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
