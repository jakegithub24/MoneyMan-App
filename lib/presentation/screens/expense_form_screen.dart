import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/expense.dart';
import '../../domain/entities/transaction_type.dart';
import '../constants/categories.dart';
import '../state/category/category_cubit.dart';
import '../state/category/category_state.dart';
import '../state/currency/currency_cubit.dart';
import '../state/currency/currency_state.dart';
import '../state/expense_form/expense_form_cubit.dart';
import '../state/expense_form/expense_form_state.dart';
import '../theme/app_theme.dart';
import '../widgets/create_category_dialog.dart';

class ExpenseFormScreen extends StatefulWidget {
  final Expense? expenseToEdit;
  final TransactionType initialType;

  const ExpenseFormScreen({
    super.key,
    this.expenseToEdit,
    this.initialType = TransactionType.expense,
  });

  @override
  State<ExpenseFormScreen> createState() => _ExpenseFormScreenState();
}

class _ExpenseFormScreenState extends State<ExpenseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TransactionType _selectedType;
  late TextEditingController _amountController;
  late TextEditingController _noteController;
  late TextEditingController _merchantController;
  String _selectedCategory = 'Food';
  DateTime _selectedDate = DateTime.now();
  bool _isRecurring = false;
  RecurringInterval _selectedInterval = RecurringInterval.monthly;
  String? _selectedPaymentMethod;

  final List<String> _paymentMethods = [
    'Cash',
    'Credit Card',
    'Debit Card',
    'UPI / Net Banking',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.expenseToEdit != null) {
      final e = widget.expenseToEdit!;
      _selectedType = e.type;
      _amountController = TextEditingController(text: e.amount.toStringAsFixed(2));
      _noteController = TextEditingController(text: e.note ?? '');
      _merchantController = TextEditingController();
      _selectedCategory = e.category;
      _selectedDate = e.date;
      _isRecurring = e.isRecurring;
      _selectedInterval = e.recurringInterval;
      _selectedPaymentMethod = e.paymentMethod;
    } else {
      _selectedType = widget.initialType;
      _amountController = TextEditingController();
      _noteController = TextEditingController();
      _merchantController = TextEditingController();
      _selectedCategory = _selectedType == TransactionType.income ? 'Salary' : 'Food';
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _merchantController.dispose();
    super.dispose();
  }

  void _onTypeChanged(TransactionType newType) {
    if (_selectedType == newType) return;
    setState(() {
      _selectedType = newType;
      if (_selectedType == TransactionType.income) {
        _selectedCategory = 'Salary';
      } else {
        _selectedCategory = 'Food';
      }
    });
  }

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.baseHighlightColor,
              onPrimary: AppTheme.backgroundColor,
              surface: AppTheme.cardBackgroundColor,
              onSurface: AppTheme.textColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null && mounted) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDate),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.dark(
                primary: AppTheme.baseHighlightColor,
                onPrimary: AppTheme.backgroundColor,
                surface: AppTheme.cardBackgroundColor,
                onSurface: AppTheme.textColor,
              ),
            ),
            child: child!,
          );
        },
      );

      if (pickedTime != null) {
        setState(() {
          _selectedDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  void _openCreateCategoryDialog() async {
    final res = await showDialog<bool>(
      context: context,
      builder: (_) => CreateCategoryDialog(initialType: _selectedType),
    );
    if (res == true && mounted) {
      context.read<CategoryCubit>().loadCategories();
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final amount = double.parse(_amountController.text.trim());
      final noteText = _noteController.text.trim();
      final merchantText = _merchantController.text.trim();
      final fullNote = merchantText.isNotEmpty
          ? (noteText.isNotEmpty ? '$noteText (Merchant: $merchantText)' : 'Merchant: $merchantText')
          : (noteText.isNotEmpty ? noteText : null);

      final formCubit = context.read<ExpenseFormCubit>();

      formCubit.submitExpense(
        existingExpense: widget.expenseToEdit,
        amount: amount,
        category: _selectedCategory,
        date: _selectedDate,
        type: _selectedType,
        note: fullNote,
        isRecurring: _isRecurring,
        recurringInterval: _selectedInterval,
        paymentMethod: _selectedPaymentMethod,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.expenseToEdit != null;
    final accentColor = _selectedType == TransactionType.income
        ? AppTheme.incomeColor
        : AppTheme.expenseColor;

    return BlocListener<ExpenseFormCubit, ExpenseFormState>(
      listener: (context, state) {
        if (state is ExpenseFormSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isEditing ? 'Record updated successfully' : 'Record added successfully',
                style: const TextStyle(color: AppTheme.textColor),
              ),
              backgroundColor: AppTheme.cardBackgroundColor,
            ),
          );
          Navigator.pop(context, true);
        } else if (state is ExpenseFormError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message, style: const TextStyle(color: AppTheme.textColor)),
              backgroundColor: AppTheme.expenseColor,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        appBar: AppBar(
          backgroundColor: AppTheme.backgroundColor,
          title: Text(
            isEditing
                ? 'Edit ${_selectedType.displayName}'
                : 'Add ${_selectedType.displayName}',
            style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textColor),
          ),
          actions: [
            if (isEditing)
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.expenseColor),
                tooltip: 'Delete Record',
                onPressed: () async {
                  final formCubit = context.read<ExpenseFormCubit>();
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      backgroundColor: AppTheme.cardBackgroundColor,
                      title: const Text('Delete Transaction?', style: TextStyle(color: AppTheme.textColor)),
                      content: const Text(
                        'Are you sure you want to remove this record?',
                        style: TextStyle(color: AppTheme.textColor),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Cancel', style: TextStyle(color: AppTheme.textColor)),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.expenseColor,
                            foregroundColor: AppTheme.textColor,
                          ),
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    formCubit.deleteExpense(widget.expenseToEdit!.id);
                  }
                },
              ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Transaction Type Segmented Toggle
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppTheme.cardBackgroundColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.textColor.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _onTypeChanged(TransactionType.expense),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _selectedType == TransactionType.expense
                                  ? AppTheme.expenseColor
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.arrow_upward_rounded,
                                  size: 18,
                                  color: _selectedType == TransactionType.expense
                                      ? AppTheme.textColor
                                      : AppTheme.textColor.withValues(alpha: 0.6),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Expense',
                                  style: TextStyle(
                                    color: _selectedType == TransactionType.expense
                                        ? AppTheme.textColor
                                        : AppTheme.textColor.withValues(alpha: 0.6),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _onTypeChanged(TransactionType.income),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _selectedType == TransactionType.income
                                  ? AppTheme.incomeColor
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.arrow_downward_rounded,
                                  size: 18,
                                  color: _selectedType == TransactionType.income
                                      ? AppTheme.textColor
                                      : AppTheme.textColor.withValues(alpha: 0.6),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Income',
                                  style: TextStyle(
                                    color: _selectedType == TransactionType.income
                                        ? AppTheme.textColor
                                        : AppTheme.textColor.withValues(alpha: 0.6),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Amount Field
                BlocBuilder<CurrencyCubit, CurrencyState>(
                  builder: (context, currState) {
                    final symbol = currState.currency.symbol;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Amount ($symbol)',
                          style: const TextStyle(
                            color: AppTheme.textColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _amountController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textColor,
                          ),
                          decoration: InputDecoration(
                            prefixIcon: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Text(
                                symbol,
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: accentColor,
                                ),
                              ),
                            ),
                            prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                            hintText: '0.00',
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Please enter an amount';
                            }
                            final parsed = double.tryParse(val.trim());
                            if (parsed == null || parsed <= 0) {
                              return 'Enter a valid positive number';
                            }
                            return null;
                          },
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Category Selector Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Category',
                      style: TextStyle(
                        color: AppTheme.textColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _openCreateCategoryDialog,
                      icon: const Icon(Icons.add_rounded, size: 16, color: AppTheme.baseHighlightColor),
                      label: const Text(
                        'New Category',
                        style: TextStyle(color: AppTheme.baseHighlightColor, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                BlocBuilder<CategoryCubit, CategoryState>(
                  builder: (context, catState) {
                    final categoriesToDisplay = catState is CategoryLoaded
                        ? (catState.categories.where((c) => c.type == _selectedType).toList())
                        : AppCategories.getCategoriesByType(_selectedType);

                    return Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        ...categoriesToDisplay.map((cat) {
                          final isSelected = _selectedCategory == cat.name;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedCategory = cat.name;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppTheme.baseHighlightColor.withValues(alpha: 0.25)
                                    : AppTheme.cardBackgroundColor,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isSelected ? AppTheme.baseHighlightColor : AppTheme.textColor.withValues(alpha: 0.2),
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    cat.icon,
                                    size: 18,
                                    color: isSelected ? AppTheme.baseHighlightColor : AppTheme.textColor,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    cat.name,
                                    style: TextStyle(
                                      color: isSelected ? AppTheme.baseHighlightColor : AppTheme.textColor,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                        // Quick Add Button Pill
                        GestureDetector(
                          onTap: _openCreateCategoryDialog,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: AppTheme.baseHighlightColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: AppTheme.baseHighlightColor.withValues(alpha: 0.5),
                                width: 1,
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.add_rounded, size: 18, color: AppTheme.baseHighlightColor),
                                SizedBox(width: 6),
                                Text(
                                  'Add Custom',
                                  style: TextStyle(
                                    color: AppTheme.baseHighlightColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Date & Time Picker
                const Text(
                  'Date & Time',
                  style: TextStyle(
                    color: AppTheme.textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: _pickDate,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppTheme.cardBackgroundColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.textColor.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.calendar_today_rounded,
                                color: AppTheme.baseHighlightColor, size: 20),
                            const SizedBox(width: 12),
                            Text(
                              DateFormat('EEE, MMM d, yyyy  •  hh:mm a')
                                  .format(_selectedDate),
                              style: const TextStyle(
                                color: AppTheme.textColor,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const Icon(Icons.edit_rounded,
                            color: AppTheme.textColor, size: 18),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Recurring Transaction Toggle
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.cardBackgroundColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.textColor.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.autorenew_rounded,
                                  color: AppTheme.popHighlightColor, size: 20),
                              SizedBox(width: 12),
                              Text(
                                'Recurring Transaction',
                                style: TextStyle(
                                  color: AppTheme.textColor,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          Switch(
                            value: _isRecurring,
                            activeThumbColor: AppTheme.baseHighlightColor,
                            onChanged: (val) {
                              setState(() {
                                _isRecurring = val;
                              });
                            },
                          ),
                        ],
                      ),
                      if (_isRecurring) ...[
                        const Divider(color: AppTheme.cardBackgroundColor, height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Repeat Interval',
                              style: TextStyle(
                                color: AppTheme.textColor,
                                fontSize: 13,
                              ),
                            ),
                            DropdownButton<RecurringInterval>(
                              value: _selectedInterval,
                              dropdownColor: AppTheme.cardBackgroundColor,
                              style: const TextStyle(
                                color: AppTheme.baseHighlightColor,
                                fontWeight: FontWeight.bold,
                              ),
                              underline: const SizedBox.shrink(),
                              items: RecurringInterval.values.map((interval) {
                                return DropdownMenuItem(
                                  value: interval,
                                  child: Text(interval.displayName),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() {
                                    _selectedInterval = val;
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Optional Note Field
                const Text(
                  'Note (Optional)',
                  style: TextStyle(
                    color: AppTheme.textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _noteController,
                  style: const TextStyle(color: AppTheme.textColor),
                  decoration: const InputDecoration(
                    hintText: 'Add a description or note...',
                    prefixIcon: Icon(Icons.notes_rounded, color: AppTheme.textColor),
                  ),
                ),
                const SizedBox(height: 20),

                // Optional Merchant/Payee Field
                const Text(
                  'Merchant / Payee (Optional)',
                  style: TextStyle(
                    color: AppTheme.textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _merchantController,
                  style: const TextStyle(color: AppTheme.textColor),
                  decoration: const InputDecoration(
                    hintText: 'e.g. Amazon, Starbucks, Landlord',
                    prefixIcon: Icon(Icons.store_rounded, color: AppTheme.textColor),
                  ),
                ),
                const SizedBox(height: 20),

                // Payment Method Selector
                const Text(
                  'Payment Method (Optional)',
                  style: TextStyle(
                    color: AppTheme.textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _selectedPaymentMethod,
                  dropdownColor: AppTheme.cardBackgroundColor,
                  style: const TextStyle(color: AppTheme.textColor, fontWeight: FontWeight.bold),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.credit_card_rounded, color: AppTheme.textColor),
                    hintText: 'Select payment method',
                  ),
                  items: _paymentMethods.map((method) {
                    return DropdownMenuItem(
                      value: method,
                      child: Text(method, style: const TextStyle(color: AppTheme.textColor)),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedPaymentMethod = val;
                    });
                  },
                ),
                const SizedBox(height: 36),

                // Submit Button
                BlocBuilder<ExpenseFormCubit, ExpenseFormState>(
                  builder: (context, state) {
                    final isSubmitting = state is ExpenseFormSubmitting;

                    return SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentColor,
                          foregroundColor: AppTheme.textColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: isSubmitting ? null : _submit,
                        child: isSubmitting
                            ? const CircularProgressIndicator(color: AppTheme.textColor)
                            : Text(
                                isEditing
                                    ? 'Update ${_selectedType.displayName}'
                                    : 'Save ${_selectedType.displayName}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
