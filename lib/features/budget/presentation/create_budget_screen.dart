import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/budget_bloc.dart';
import '../models/budget_model.dart';

class CreateBudgetScreen extends StatefulWidget {
  final String month;
  final Budget? existingBudget;

  const CreateBudgetScreen({
    super.key,
    required this.month,
    this.existingBudget,
  });

  @override
  State<CreateBudgetScreen> createState() => _CreateBudgetScreenState();
}

class _CreateBudgetScreenState extends State<CreateBudgetScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _totalBudgetController;
  final List<CategoryInput> _categoryInputs = [];

  final List<String> _availableCategories = [
    'Food',
    'Transportation',
    'Shopping',
    'Bills',
    'Entertainment',
    'Others'
  ];

  @override
  void initState() {
    super.initState();
    _totalBudgetController = TextEditingController(
      text: widget.existingBudget?.totalBudget.toStringAsFixed(0) ?? '',
    );

    if (widget.existingBudget != null) {
      for (var cat in widget.existingBudget!.categoryBudgets) {
        _categoryInputs.add(CategoryInput(
          category: cat.category,
          controller: TextEditingController(text: cat.amount.toStringAsFixed(0)),
        ));
      }
    }
  }

  @override
  void dispose() {
    _totalBudgetController.dispose();
    for (var input in _categoryInputs) {
      input.controller.dispose();
    }
    super.dispose();
  }

  void _addCategory() {
    if (_categoryInputs.length < 5) {
      setState(() {
        _categoryInputs.add(CategoryInput(
          category: _availableCategories.firstWhere(
            (cat) => !_categoryInputs.any((input) => input.category == cat),
            orElse: () => 'Others',
          ),
          controller: TextEditingController(),
        ));
      });
    }
  }

  void _removeCategory(int index) {
    setState(() {
      _categoryInputs[index].controller.dispose();
      _categoryInputs.removeAt(index);
    });
  }

  void _saveBudget() {
    if (_formKey.currentState!.validate()) {
      final totalAmount = double.parse(_totalBudgetController.text);
      final categories = _categoryInputs.map((input) {
        return CategoryBudget(
          id: DateTime.now().millisecondsSinceEpoch.toString() + input.category,
          budgetId: widget.existingBudget?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
          category: input.category,
          amount: double.parse(input.controller.text),
        );
      }).toList();

      final budget = Budget(
        id: widget.existingBudget?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        month: widget.month,
        totalBudget: totalAmount,
        categoryBudgets: categories,
      );

      context.read<BudgetBloc>().add(SaveBudgetEvent(budget));
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final monthDisplay = DateFormat('MMMM yyyy').format(DateTime.parse('${widget.month}-01'));

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.existingBudget == null ? 'Set Budget' : 'Edit Budget'),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Monthly Budget for $monthDisplay',
                style: const TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _totalBudgetController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  labelText: 'Total Budget Amount',
                  labelStyle: const TextStyle(color: Colors.white70),
                  prefixText: '₹ ',
                  prefixStyle: const TextStyle(color: Colors.white, fontSize: 24),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.white.withAlpha(20)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter amount';
                  if (double.tryParse(value) == null) return 'Invalid number';
                  return null;
                },
              ),
              const SizedBox(height: 40),
              Row(  
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Category Breakdown',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  if (_categoryInputs.length < 5)
                    TextButton.icon(
                      onPressed: _addCategory,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Category'),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              ..._categoryInputs.asMap().entries.map((entry) {
                final index = entry.key;
                final input = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: DropdownButtonFormField<String>(
                          initialValue: input.category,
                          dropdownColor: Colors.grey.shade900,
                          style: const TextStyle(color: Colors.white, overflow: TextOverflow.visible),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.white.withAlpha(10)),
                            ),
                          ),
                          items: _availableCategories.map((cat) {
                            return DropdownMenuItem(value: cat, child: Text(cat));
                          }).toList(),
                          onChanged: (val) {
                            setState(() => _categoryInputs[index].category = val!);
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          controller: input.controller,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Amount',
                            hintStyle: const TextStyle(color: Colors.white24),
                            prefixText: '₹ ',
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.white.withAlpha(10)),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Required';
                            if (double.tryParse(value) == null) return 'Invalid';
                            return null;
                          },
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
                        onPressed: () => _removeCategory(index),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _saveBudget,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Save Budget', style: TextStyle(color: Colors.white, fontSize: 18)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class CategoryInput {
  String category;
  TextEditingController controller;

  CategoryInput({required this.category, required this.controller});
}
