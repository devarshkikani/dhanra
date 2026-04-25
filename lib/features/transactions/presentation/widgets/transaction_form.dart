import 'dart:ui';

import 'package:dhanra/core/constants/category_keyword.dart';
import 'package:dhanra/core/services/local_storage_service.dart';
import 'package:dhanra/core/utils/get_bank_image.dart';
import 'package:dhanra/features/transactions/bloc/transactions_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class TransactionForm extends StatefulWidget {
  const TransactionForm({
    super.key,
    required this.banks,
    this.transaction,
  });
  final List<String> banks;
  final Map<String, dynamic>? transaction;

  @override
  TransactionFormState createState() => TransactionFormState();
}

class TransactionFormState extends State<TransactionForm> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  final _upiIdOrSenderNameController = TextEditingController();

  String _transactionType = 'Debit';
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String? _selectedBank;
  String? _selectedCategory;
  String? _previousCategory;

  @override
  void initState() {
    super.initState();
    if (widget.transaction != null) {
      final transaction = widget.transaction!;
      _transactionType = transaction['type'] ?? 'Debit';
      _amountController.text = transaction['amount']?.toString() ?? '';
      if (transaction['id'] != null) {
        _notesController.text = '';
      } else {
        _notesController.text = transaction['body'] ?? '';
      }
      _upiIdOrSenderNameController.text =
          transaction['upiIdOrSenderName'] ?? '';
      _selectedBank = transaction['bank'] ??
          (widget.banks.isNotEmpty ? widget.banks.first : null);
      _selectedCategory = transaction['category'];
      _previousCategory = _selectedCategory; // Track the original category
      try {
        final dateTime =
            DateTime.fromMillisecondsSinceEpoch(int.parse(transaction['date']));
        _selectedDate = dateTime;
        _selectedTime = TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
      } catch (e) {
        _selectedDate = DateTime.now();
        _selectedTime = TimeOfDay.now();
      }
    } else {
      _selectedBank = widget.banks.isNotEmpty ? widget.banks.first : null;
      _notesController.text = '';
      _upiIdOrSenderNameController.text = '';
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    _upiIdOrSenderNameController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      if (!context.mounted) return;
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: _selectedTime,
      );
      if (pickedTime != null) {
        if (!mounted) return;
        setState(() {
          _selectedDate = pickedDate;
          _selectedTime = pickedTime;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories =
        CategoryKeyWord.upiKeywordCategoryMapping.values.toSet().toList();

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildTransactionTypeSelector(),
          const SizedBox(height: 16),
          _buildAmountField(),
          const SizedBox(height: 16),
          _buildUpiIdOrSenderNameField(),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildBankDropdown(widget.banks)),
              const SizedBox(width: 12),
              Expanded(child: _buildCategoryDropdown(categories)),
            ],
          ),
          const SizedBox(height: 16),
          _buildDateTimePicker(),
          const SizedBox(height: 16),
          _buildNotesField(),
          _buildSmsInfo(),
          const SizedBox(height: 16),
          _buildSaveButton(),
        ],
      ),
    );
  }

  Widget _buildTransactionTypeSelector() {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(15),
              border: Border.all(
                color: Colors.white.withAlpha(20),
              ),
            ),
            padding: const EdgeInsets.all(4),
            child: Row(
              // mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTypePill('Debit', Icons.arrow_downward_rounded, 'Expense',
                    Colors.redAccent),
                _buildTypePill('Credit', Icons.arrow_upward_rounded, 'Income',
                    Colors.greenAccent),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypePill(String type, IconData icon, String label, Color color) {
    final isSelected = _transactionType == type;
    return Expanded(
      child: Container(
        // duration: const Duration(milliseconds: 200),
        // curve: Curves.easeInOut,,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: isSelected ? color.withAlpha(15) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: isSelected ? color : Colors.transparent, width: 2),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            setState(() {
              _transactionType = type;
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon(icon,
                //     color: isSelected ? color : Colors.white54, size: 20),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? color : Colors.white70,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _coolInputDecoration({
    required String label,
    IconData? icon,
    Color? accentColor,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(
        color: Colors.white70,
        fontWeight: FontWeight.bold,
        fontSize: 16,
        letterSpacing: 0.2,
      ),
      prefixIcon: icon != null ? Icon(icon, color: Colors.white54) : null,
      filled: true,
      fillColor: Colors.white.withAlpha(10),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.white.withAlpha(12), width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide:
            BorderSide(color: accentColor ?? Colors.blueAccent, width: 2.2),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      // Glassmorphic shadow
      // (use a Container with BoxShadow for more effect if desired)
    );
  }

  Widget _buildAmountField() {
    return TextFormField(
      controller: _amountController,
      autofocus: widget.transaction == null,
      decoration: _coolInputDecoration(
        label: 'Amount',
        icon: Icons.currency_rupee_rounded,
        accentColor: Colors.amberAccent,
      ),
      textInputAction: TextInputAction.next,
      style: const TextStyle(
          color: Colors.white, fontWeight: FontWeight.w600, fontSize: 18),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter an amount';
        }
        if (double.tryParse(value) == null) {
          return 'Please enter a valid number';
        }
        return null;
      },
    );
  }

  Widget _buildUpiIdOrSenderNameField() {
    return TextFormField(
      controller: _upiIdOrSenderNameController,
      decoration: _coolInputDecoration(
        label: 'UPI ID / Sender Name',
        icon: Icons.account_circle_outlined,
        accentColor: Colors.cyanAccent,
      ),
      style: const TextStyle(
          color: Colors.white, fontWeight: FontWeight.w500, fontSize: 16),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter UPI ID or Sender Name';
        }
        return null;
      },
    );
  }

  Widget _buildBankDropdown(List<String> banks) {
    return GestureDetector(
      onTap: () async {
        final selected = await showModalBottomSheet<String>(
          context: context,
          backgroundColor: Colors.grey[900],
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          builder: (context) {
            return ListView.separated(
              shrinkWrap: true,
              itemCount: banks.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1, color: Colors.white12),
              itemBuilder: (context, i) {
                final bank = banks[i];
                final isSelected = bank == _selectedBank;
                return ListTile(
                  // leading: bank == 'Cash' ||
                  //         GetBankImage.getBankImagePath(bank) == null
                  //     ? const Icon(
                  //         Icons.account_balance_wallet_rounded,
                  //         size: 16,
                  //         color: Colors.white,
                  //       )
                  //     : Image.asset(
                  //         GetBankImage.getBankImagePath(bank) ?? '',
                  //       ),
                  leading: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: GetBankImage.getBankImagePath(bank) == null
                        ? const Icon(
                            Icons.account_balance_wallet,
                            size: 26,
                            color: Colors.black,
                          )
                        : Image.asset(
                            GetBankImage.getBankImagePath(bank) ?? '',
                            height: 30,
                            width: 30,
                            fit: BoxFit.cover,
                          ),
                  ),
                  title:
                      Text(bank, style: const TextStyle(color: Colors.white)),
                  trailing: isSelected
                      ? const Icon(Icons.check, color: Colors.greenAccent)
                      : null,
                  onTap: () => Navigator.of(context).pop(bank),
                  selected: isSelected,
                  selectedTileColor: Colors.white.withAlpha(06),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                );
              },
            );
          },
        );
        if (selected != null) {
          setState(() {
            _selectedBank = selected;
          });
        }
      },
      child: Container(
        height: 100,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(10),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withAlpha(12),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // _selectedBank == null &&
            //         GetBankImage.getBankImagePath(_selectedBank!) == null
            //     ? const Icon(
            //         Icons.account_balance,
            //         size: 16,
            //         color: Colors.white,
            //       )
            //     : _selectedBank == 'Cash'
            //         ? const Icon(
            //             Icons.account_balance,
            //             size: 16,
            //             color: Colors.white,
            //           )
            //         : Image.asset(
            //             GetBankImage.getBankImagePath(_selectedBank!) ?? '',
            //           ),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: _selectedBank == null &&
                      GetBankImage.getBankImagePath(_selectedBank!) == null
                  ? const Icon(
                      Icons.account_balance,
                      size: 26,
                      color: Colors.black,
                    )
                  : GetBankImage.getBankImagePath(_selectedBank!) == null
                      ? const Icon(
                          Icons.account_balance_wallet,
                          size: 26,
                          color: Colors.black,
                        )
                      : Image.asset(
                          GetBankImage.getBankImagePath(_selectedBank!) ?? '',
                          height: 30,
                          width: 30,
                          fit: BoxFit.cover,
                        ),
            ),
            Text(_selectedBank ?? "Please select a bank"),
          ],
        ),
      ),
      // child: AbsorbPointer(
      //   child: TextFormField(
      //     readOnly: true,
      //     decoration: InputDecoration(
      //       labelText: 'Bank / Source',
      //       prefixIcon: const Icon(Icons.account_balance),
      //       filled: true,
      //       fillColor: Colors.white.withAlpha(06),
      // border: OutlineInputBorder(
      //   borderRadius: BorderRadius.circular(12),
      // ),
      //     ),
      //     controller: TextEditingController(text: _selectedBank ?? ''),
      //     validator: (value) =>
      //         (_selectedBank == null || _selectedBank!.isEmpty)
      //             ? 'Please select a bank'
      //             : null,
      //   ),
      // ),
    );
  }

  Widget _buildCategoryDropdown(List<String> categories) {
    final iconAndColor = _selectedCategory != null
        ? CategoryKeyWord.getIconAndColor(_selectedCategory!)
        : null;
    return GestureDetector(
      onTap: () async {
        final selected = await showModalBottomSheet<String>(
          context: context,
          backgroundColor: Colors.grey[900],
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          builder: (context) {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: GridView.builder(
                shrinkWrap: true,
                itemCount: categories.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 18,
                  crossAxisSpacing: 18,
                  childAspectRatio: 1.2,
                ),
                itemBuilder: (context, i) {
                  final cat = categories[i];
                  final iconColor = CategoryKeyWord.getIconAndColor(cat);
                  final isSelected = cat == _selectedCategory;
                  return GestureDetector(
                    onTap: () => Navigator.of(context).pop(cat),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? CategoryKeyWord.parseHexColor(iconColor['color']!)
                                .withAlpha(15)
                            : Colors.white.withAlpha(03),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? CategoryKeyWord.parseHexColor(
                                  iconColor['color']!)
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            iconColor['icon']!,
                            style: TextStyle(
                              fontSize: 24,
                              color: CategoryKeyWord.parseHexColor(
                                  iconColor['color']!),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            cat,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: CategoryKeyWord.parseHexColor(
                                  iconColor['color']!),
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
        if (selected != null) {
          setState(() {
            _selectedCategory = selected;
          });
        }
      },
      child: Container(
        height: 100,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(10),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withAlpha(12),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            iconAndColor != null
                ? Text(
                    iconAndColor['icon']!,
                    style: TextStyle(
                      fontSize: 24,
                      color:
                          CategoryKeyWord.parseHexColor(iconAndColor['color']!),
                    ),
                  )
                : const Icon(Icons.category),
            Text(
              _selectedCategory ?? 'Please select a category',
              textAlign: TextAlign.center,
              style: const TextStyle(
                // color: CategoryKeyWord.parseHexColor(_selectedCategory['color']!),
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
      // child: AbsorbPointer(
      //   child: TextFormField(
      //     readOnly: true,
      //     decoration: InputDecoration(
      //       labelText: 'Category',
      //       prefixIcon: iconAndColor != null
      //           ? Padding(
      //               padding: const EdgeInsets.only(left: 8, right: 8),
      //               child: Row(
      //                 mainAxisSize: MainAxisSize.min,
      //                 children: [
      //                   Text(
      //                     iconAndColor['icon']!,
      //                     style: TextStyle(
      //                       fontSize: 22,
      //                       color: CategoryKeyWord.parseHexColor(
      //                           iconAndColor['color']!),
      //                     ),
      //                   ),
      //                 ],
      //               ),
      //             )
      //           : const Icon(Icons.category),
      //       filled: true,
      //       fillColor: Colors.white.withAlpha(06),
      //       border: OutlineInputBorder(
      //         borderRadius: BorderRadius.circular(12),
      //       ),
      //     ),
      //     controller: TextEditingController(text: _selectedCategory ?? ''),
      //     validator: (value) =>
      //         (_selectedCategory == null || _selectedCategory!.isEmpty)
      //             ? 'Please select a category'
      //             : null,
      //   ),
      // ),
    );
  }

  bool _shouldOfferBulkCategoryUpdate(String selectedCategory) {
    final storage = LocalStorageService();
    final upiIdOrSenderName = _upiIdOrSenderNameController.text.trim();
    final transactionId = widget.transaction?['id']?.toString();

    return storage.isCategoryUnassigned(_previousCategory) &&
        !storage.isCategoryUnassigned(selectedCategory) &&
        upiIdOrSenderName.isNotEmpty &&
        storage.countUnassignedTransactionsByUpiIdAndType(
              upiIdOrSenderName,
              _transactionType,
              excludingTransactionId: transactionId,
            ) >
            0;
  }

  Widget _buildDateTimePicker() {
    final dateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );
    return InkWell(
      onTap: () => _selectDateTime(context),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Date & Time',
          prefixIcon: const Icon(Icons.calendar_today),
          labelStyle: const TextStyle(
            color: Colors.white70,
            fontWeight: FontWeight.bold,
            fontSize: 16,
            letterSpacing: 0.2,
          ),
          // prefixIcon: icon != null ? Icon(icon, color: Colors.white54) : null,
          filled: true,
          fillColor: Colors.white.withAlpha(10),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide:
                BorderSide(color: Colors.white.withAlpha(12), width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide:
                BorderSide(color: Theme.of(context).primaryColor, width: 2.2),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
          floatingLabelBehavior: FloatingLabelBehavior.auto,
        ),
        child: Text(DateFormat('yyyy-MM-dd HH:mm').format(dateTime)),
      ),
    );
  }

  Widget _buildSmsInfo() {
    if (widget.transaction == null || widget.transaction!['body'] == null) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text('SMS Info',
            style:
                TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(06),
            borderRadius: BorderRadius.circular(10),
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            scrollDirection: Axis.vertical,
            child: SelectableText(
              widget.transaction!['body'],
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotesField() {
    return TextFormField(
      controller: _notesController,
      decoration: _coolInputDecoration(
        label: 'Notes',
        icon: Icons.edit_note_rounded,
        accentColor: Theme.of(context).primaryColor,
      ),
      style: const TextStyle(
          color: Colors.white, fontWeight: FontWeight.w500, fontSize: 16),
      maxLines: 2,
      validator: (value) {
        // Notes are optional
        return null;
      },
    );
  }

  Widget _buildSaveButton() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () async {
              if (!_formKey.currentState!.validate()) return;

              final transactionData = _buildTransactionData();
              List<String>? selectedTransactionIds;

              if (_shouldOfferBulkCategoryUpdate(
                _selectedCategory ?? 'Miscellaneous',
              )) {
                selectedTransactionIds =
                    await _showBulkUpdateBottomSheet(transactionData);
                if (!mounted || selectedTransactionIds == null) return;
              }

              final isEditing = widget.transaction != null;
              if (isEditing) {
                context
                    .read<TransactionsBloc>()
                    .add(UpdateTransaction(transactionData));
              } else {
                context
                    .read<TransactionsBloc>()
                    .add(AddTransaction(transactionData));
              }

              if ((selectedTransactionIds ?? const <String>[]).isNotEmpty) {
                context.read<TransactionsBloc>().add(
                      BulkUpdateTransactionsByIds(
                        transactionIds: selectedTransactionIds!,
                        newCategory: _selectedCategory ?? 'Miscellaneous',
                      ),
                    );
              }

              Navigator.of(context).pop();
            },
            child: Text(widget.transaction != null ? 'Update' : 'Save'),
          ),
        ),
      ],
    );
  }

  Map<String, dynamic> _buildTransactionData() {
    final isEditing = widget.transaction != null;
    final transactionId = isEditing
        ? widget.transaction!['id']
        : 'manual_${DateTime.now().millisecondsSinceEpoch}';
    final dateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    return {
      'id': transactionId,
      'amount': _amountController.text,
      'date': dateTime.millisecondsSinceEpoch.toString(),
      'bank': _selectedBank,
      'type': _transactionType,
      'sender': widget.transaction?['sender'] ?? 'MANUAL',
      'body': _notesController.text.isEmpty
          ? widget.transaction != null
              ? widget.transaction!['body']
              : _notesController.text
          : _notesController.text,
      'upiIdOrSenderName': _upiIdOrSenderNameController.text.trim(),
      'category': _selectedCategory ?? 'Miscellaneous',
      'accountNumber': widget.transaction?['accountNumber'] ?? '',
      'lastFourDigits': widget.transaction?['lastFourDigits'] ?? '',
      'balance': widget.transaction?['balance'] ?? '0.0',
    };
  }

  Future<List<String>?> _showBulkUpdateBottomSheet(
    Map<String, dynamic> currentTransaction,
  ) async {
    final storage = LocalStorageService();
    final upiIdOrSenderName =
        currentTransaction['upiIdOrSenderName']?.toString() ?? '';
    final currentTransactionId = currentTransaction['id']?.toString();
    final matchingTransactions = storage
        .findTransactionsByUpiIdAndType(upiIdOrSenderName, _transactionType)
        .where((tx) =>
            tx['id']?.toString() != currentTransactionId &&
            storage.isCategoryUnassigned(tx['category']?.toString()))
        .map((tx) => Map<String, dynamic>.from(tx))
        .toList();

    final currentIndex = matchingTransactions.indexWhere(
      (tx) => tx['id']?.toString() == currentTransactionId,
    );

    if (currentIndex >= 0) {
      matchingTransactions[currentIndex] = {
        ...matchingTransactions[currentIndex],
        ...currentTransaction,
        '_isCurrentTransaction': true,
      };
    } else {
      matchingTransactions.insert(0, {
        ...currentTransaction,
        '_isCurrentTransaction': true,
      });
    }

    if (matchingTransactions.length <= 1) {
      return <String>[];
    }

    final selectedIds = matchingTransactions
        .where((tx) => tx['id']?.toString() != currentTransactionId)
        .map((tx) => tx['id'].toString())
        .toSet();

    return showModalBottomSheet<List<String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final selectedCount = selectedIds.length + 1;
            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.8,
              minChildSize: 0.55,
              maxChildSize: 0.94,
              builder: (context, scrollController) {
                return Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF111418),
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(28)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.35),
                        blurRadius: 24,
                        offset: const Offset(0, -8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      Container(
                        width: 44,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$selectedCount selected',
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Apply Category To Similar Transactions',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Review transactions with the same UPI ID and ${_transactionType == 'Debit' ? 'expense' : 'income'} type. Uncheck any item you do not want to update.',
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 14,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListView.separated(
                          controller: scrollController,
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                          itemCount: matchingTransactions.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final tx = matchingTransactions[index];
                            final txId = tx['id']?.toString() ?? '';
                            final isCurrent =
                                tx['_isCurrentTransaction'] == true;
                            final isSelected =
                                isCurrent || selectedIds.contains(txId);
                            final date = DateTime.fromMillisecondsSinceEpoch(
                              int.tryParse(tx['date']?.toString() ?? '') ??
                                  DateTime.now().millisecondsSinceEpoch,
                            );

                            return InkWell(
                              onTap: isCurrent
                                  ? null
                                  : () {
                                      setModalState(() {
                                        if (selectedIds.contains(txId)) {
                                          selectedIds.remove(txId);
                                        } else {
                                          selectedIds.add(txId);
                                        }
                                      });
                                    },
                              borderRadius: BorderRadius.circular(20),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Theme.of(context)
                                          .primaryColor
                                          .withValues(alpha: 0.14)
                                      : Colors.white.withValues(alpha: 0.05),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isSelected
                                        ? Theme.of(context).primaryColor
                                        : Colors.white12,
                                  ),
                                ),
                                child: ListTile(
                                  dense: true,
                                  visualDensity: const VisualDensity(
                                    horizontal: -2,
                                    vertical: -2,
                                  ),
                                  contentPadding: EdgeInsets.zero,
                                  leading: Checkbox(
                                    value: isSelected,
                                    visualDensity: VisualDensity.compact,
                                    onChanged: isCurrent
                                        ? null
                                        : (_) {
                                            setModalState(() {
                                              if (selectedIds.contains(txId)) {
                                                selectedIds.remove(txId);
                                              } else {
                                                selectedIds.add(txId);
                                              }
                                            });
                                          },
                                  ),
                                  title: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          tx['upiIdOrSenderName']
                                                      ?.toString()
                                                      .trim()
                                                      .isNotEmpty ==
                                                  true
                                              ? tx['upiIdOrSenderName']
                                                  .toString()
                                              : 'Unknown',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      if (isCurrent)
                                        Container(
                                          margin:
                                              const EdgeInsets.only(left: 8),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 3,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white10,
                                            borderRadius:
                                                BorderRadius.circular(99),
                                          ),
                                          child: const Text(
                                            'Current',
                                            style: TextStyle(
                                              color: Colors.white70,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(top: 2),
                                    child: Text(
                                      '${DateFormat('dd MMM yyyy, hh:mm a').format(date)}${(tx['category'] ?? '').toString().isNotEmpty ? '  •  ${tx['category']}' : ''}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Colors.grey[400],
                                        fontSize: 11.5,
                                      ),
                                    ),
                                  ),
                                  trailing: Text(
                                    '₹${tx['amount']}',
                                    style: TextStyle(
                                      color: _transactionType == 'Debit'
                                          ? Colors.redAccent.shade100
                                          : Colors.greenAccent.shade100,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                        child: Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Navigator.of(context).pop(),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.white70,
                                  side: const BorderSide(color: Colors.white24),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: const Text('Cancel'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => Navigator.of(context)
                                    .pop(selectedIds.toList()),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Theme.of(context).primaryColor,
                                  foregroundColor: Colors.white,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: Text('Apply ($selectedCount)'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
