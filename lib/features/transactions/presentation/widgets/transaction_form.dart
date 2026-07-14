import 'dart:ui';

import 'package:dhanra/core/constants/category_keyword.dart';
import 'package:dhanra/core/services/ads_manager.dart';
import 'package:dhanra/core/services/local_storage_service.dart';

import 'package:dhanra/features/transactions/bloc/transactions_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:dhanra/features/widgets/app_text_form_field.dart';

class TransactionForm extends StatefulWidget {
  const TransactionForm({
    super.key,
    this.transaction,
  });
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
      _selectedBank = transaction['bank'] ?? 'Cash';
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
      _selectedBank = 'Cash';
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
          const SizedBox(height: 20),
          _buildRedesignedAmountCard(),
          const SizedBox(height: 16),
          _buildRedesignedCategoryCard(categories),
          const SizedBox(height: 16),
          _buildRedesignedDateTimePickerCard(),
          const SizedBox(height: 16),
          _buildRedesignedUpiCard(),
          const SizedBox(height: 16),
          _buildRedesignedNotesCard(),
          _buildSmsInfo(),
          const SizedBox(height: 30),
          _buildRedesignedSaveButton(),
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
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTypePill('Debit', Icons.arrow_downward_rounded, 'Expense',
                    Colors.redAccent),
                _buildTypePill('Credit', Icons.arrow_upward_rounded, 'Income',
                    Colors.green),
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
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white,
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

  Widget _buildRedesignedAmountCard() {
    return AppTextFormField(
      controller: _amountController,
      autofocus: widget.transaction == null,
      labelText: "Amount",
      prefixIcon: Icons.currency_rupee_rounded,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
      ],
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

  Widget _buildRedesignedCategoryCard(List<String> categories) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withAlpha(15), width: 1.5),
      ),
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Category',
                  style: TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    final selected = await _showCategoryModalSheet(categories);
                    if (selected != null) {
                      setState(() {
                        _selectedCategory = selected;
                      });
                    }
                  },
                  child: Row(
                    children: [
                      Text(
                        _selectedCategory ?? 'Select category',
                        style: TextStyle(
                          color: _selectedCategory != null
                              ? Colors.white
                              : Colors.white38,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Colors.white54,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 85,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final cat = categories[index];
                final iconColor = CategoryKeyWord.getIconAndColor(cat);
                final isSelected = cat == _selectedCategory;
                final parsedColor = CategoryKeyWord.parseHexColor(
                    iconColor['color'] ?? '#FFFFFF');

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCategory = cat;
                      });
                    },
                    child: Column(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          height: 52,
                          width: 52,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected
                                ? parsedColor.withAlpha(45)
                                : Colors.white.withAlpha(8),
                            border: Border.all(
                              color: isSelected ? parsedColor : Colors.white12,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            iconColor['icon'] ?? '❓',
                            style: const TextStyle(fontSize: 22),
                          ),
                        ),
                        const SizedBox(height: 6),
                        SizedBox(
                          width: 65,
                          child: Text(
                            cat,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.white54,
                              fontSize: 11,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<String?> _showCategoryModalSheet(List<String> categories) async {
    return showModalBottomSheet<String>(
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
                          ? CategoryKeyWord.parseHexColor(iconColor['color']!)
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
  }

  Widget _buildRedesignedDateTimePickerCard() {
    final dateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );
    return GestureDetector(
      onTap: () => _selectDateTime(context),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(10),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withAlpha(15), width: 1.5),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  color: Theme.of(context).primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Date & Time',
                  style: TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            Text(
              DateFormat('yyyy/MM/dd  HH:mm').format(dateTime),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRedesignedUpiCard() {
    return AppTextFormField(
      controller: _upiIdOrSenderNameController,
      labelText: 'UPI ID / Sender Name',
      prefixIcon: Icons.account_circle_outlined,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter UPI ID or Sender Name';
        }
        return null;
      },
    );
  }

  Widget _buildRedesignedNotesCard() {
    return AppTextFormField(
      controller: _notesController,
      labelText: 'Add a note',
      prefixIcon: Icons.edit_note_rounded,
      maxLines: 2,
    );
  }

  Widget _buildRedesignedSaveButton() {
    final isEditing = widget.transaction != null;
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: _transactionType == 'Credit'
              ? Colors.green
              : Theme.of(context).primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
        ),
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

          // Show pre-loaded Interstitial ad on task completion
          AdsManager.instance.showInterstitial(
            ignoreCooldown: true,
            onAdClosed: () {
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            },
          );
        },
        child: Text(
          isEditing ? 'Update Transaction' : 'Save Transaction',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
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
