import 'package:dhanra/core/theme/gradients.dart';
import 'package:dhanra/features/transactions/presentation/widgets/transaction_form.dart';
import 'package:flutter/material.dart';

class AddEditTransactionScreen extends StatelessWidget {
  const AddEditTransactionScreen({
    super.key,
    required this.banks,
    this.transaction,
  });
  final List<String> banks;
  final Map<String, dynamic>? transaction;

  @override
  Widget build(BuildContext context) {
    final isEditing = transaction != null;
    return Stack(
      alignment: Alignment.topLeft,
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
            backgroundColor: Colors.transparent,
            scrolledUnderElevation: 0.0,
            title: Text(isEditing ? 'Edit Transaction' : 'Add Transaction'),
          ),
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: TransactionForm(
                banks: banks,
                transaction: transaction,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
