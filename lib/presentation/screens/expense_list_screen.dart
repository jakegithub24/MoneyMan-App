import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/transaction_type.dart';
import '../constants/categories.dart';
import '../state/category/category_cubit.dart';
import '../state/category/category_state.dart';
import '../state/dashboard/dashboard_cubit.dart';
import '../state/expense_form/expense_form_cubit.dart';
import '../state/expense_list/expense_list_cubit.dart';
import '../state/expense_list/expense_list_state.dart';
import '../theme/app_theme.dart';
import '../utils/app_haptics.dart';
import '../widgets/expense_tile.dart';
import 'expense_form_screen.dart';

class ExpenseListScreen extends StatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  State<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  final TextEditingController _searchController = TextEditingController();
  TransactionType? _selectedTypeFilter;
  bool _onlyRecurringFilter = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final state = context.read<ExpenseListCubit>().state;
    DateTimeRange? initialRange;
    if (state is ExpenseListLoaded && state.fromDate != null && state.toDate != null) {
      initialRange = DateTimeRange(start: state.fromDate!, end: state.toDate!);
    }

    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDateRange: initialRange,
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

    if (picked != null) {
      if (!context.mounted) return;
      context
          .read<ExpenseListCubit>()
          .setDateRange(picked.start, picked.end);
    }
  }

  void _onTypeFilterChanged(TransactionType? type, bool onlyRecurring) {
    AppHaptics.selectionClick();
    setState(() {
      _selectedTypeFilter = type;
      _onlyRecurringFilter = onlyRecurring;
    });

    final listCubit = context.read<ExpenseListCubit>();
    listCubit.setTypeAndRecurringFilter(type, onlyRecurring);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        title: const Text(
          'Transactions',
          style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textColor),
        ),
        actions: [
          BlocBuilder<ExpenseListCubit, ExpenseListState>(
            builder: (context, state) {
              final hasActiveDateFilter =
                  state is ExpenseListLoaded && (state.fromDate != null || state.toDate != null);
              return IconButton(
                icon: Icon(
                  Icons.date_range_rounded,
                  color: hasActiveDateFilter ? AppTheme.baseHighlightColor : AppTheme.textColor,
                ),
                tooltip: 'Filter by date range',
                onPressed: () => _selectDateRange(context),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search & Filter controls bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              children: [
                BlocBuilder<ExpenseListCubit, ExpenseListState>(
                  builder: (context, listState) {
                    final selectedTypeFilter = listState is ExpenseListLoaded ? listState.selectedType : _selectedTypeFilter;
                    final onlyRecurringFilter = listState is ExpenseListLoaded ? listState.onlyRecurring : _onlyRecurringFilter;

                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildTypeTab(
                            label: 'All',
                            isSelected: selectedTypeFilter == null && !onlyRecurringFilter,
                            onTap: () => _onTypeFilterChanged(null, false),
                          ),
                          const SizedBox(width: 8),
                          _buildTypeTab(
                            label: 'Expenses',
                            isSelected: selectedTypeFilter == TransactionType.expense && !onlyRecurringFilter,
                            onTap: () => _onTypeFilterChanged(TransactionType.expense, false),
                          ),
                          const SizedBox(width: 8),
                          _buildTypeTab(
                            label: 'Income',
                            isSelected: selectedTypeFilter == TransactionType.income && !onlyRecurringFilter,
                            onTap: () => _onTypeFilterChanged(TransactionType.income, false),
                          ),
                          const SizedBox(width: 8),
                          _buildTypeTab(
                            label: 'Recurring',
                            isSelected: onlyRecurringFilter,
                            onTap: () => _onTypeFilterChanged(null, true),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),

                // Search Field
                TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    context.read<ExpenseListCubit>().setSearchQuery(val);
                  },
                  style: const TextStyle(color: AppTheme.textColor),
                  decoration: InputDecoration(
                    hintText: 'Search note, merchant, category, amount...',
                    prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.textColor),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, color: AppTheme.textColor),
                            onPressed: () {
                              _searchController.clear();
                              context.read<ExpenseListCubit>().setSearchQuery('');
                            },
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 10),

                // Category Filter Pills & Active Date Chip
                BlocBuilder<ExpenseListCubit, ExpenseListState>(
                  builder: (context, state) {
                    final selectedCat =
                        state is ExpenseListLoaded ? state.selectedCategory : 'All';
                    final fromDate = state is ExpenseListLoaded ? state.fromDate : null;
                    final toDate = state is ExpenseListLoaded ? state.toDate : null;

                    return BlocBuilder<CategoryCubit, CategoryState>(
                      builder: (context, catState) {
                        final availableCategoryNames = catState is CategoryLoaded
                            ? catState.categories.map((c) => c.name).toList()
                            : AppCategories.allCategories.map((c) => c.name).toList();

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  _buildCategoryFilterChip(context, 'All', selectedCat),
                                  ...availableCategoryNames.map(
                                    (name) => _buildCategoryFilterChip(context, name, selectedCat),
                                  ),
                                ],
                              ),
                            ),
                            if (fromDate != null && toDate != null) ...[
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Container(
                                    padding:
                                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppTheme.baseHighlightColor.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: AppTheme.baseHighlightColor.withValues(alpha: 0.5),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.calendar_today_rounded,
                                          size: 12,
                                          color: AppTheme.baseHighlightColor,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          '${DateFormat.MMMd().format(fromDate)} - ${DateFormat.MMMd().format(toDate)}',
                                          style: const TextStyle(
                                            color: AppTheme.baseHighlightColor,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        GestureDetector(
                                          onTap: () {
                                            context
                                                .read<ExpenseListCubit>()
                                                .setDateRange(null, null);
                                          },
                                          child: const Icon(
                                            Icons.close_rounded,
                                            size: 14,
                                            color: AppTheme.baseHighlightColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),

          // Expenses List View
          Expanded(
            child: BlocBuilder<ExpenseListCubit, ExpenseListState>(
              builder: (context, state) {
                if (state is ExpenseListLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppTheme.baseHighlightColor),
                  );
                }

                if (state is ExpenseListError) {
                  return Center(
                    child: Text(
                      state.message,
                      style: const TextStyle(color: AppTheme.expenseColor),
                    ),
                  );
                }

                if (state is ExpenseListLoaded) {
                  if (state.expenses.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.search_off_rounded,
                              size: 56,
                              color: AppTheme.textColor,
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'No transactions found',
                              style: TextStyle(
                                color: AppTheme.textColor,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Try adjusting your search query or filters',
                              style: TextStyle(color: AppTheme.textColor, fontSize: 14),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.baseHighlightColor,
                                foregroundColor: AppTheme.backgroundColor,
                              ),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _selectedTypeFilter = null;
                                  _onlyRecurringFilter = false;
                                });
                                context.read<ExpenseListCubit>().clearFilters();
                              },
                              child: const Text('Reset Filters'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    color: AppTheme.baseHighlightColor,
                    backgroundColor: AppTheme.cardBackgroundColor,
                    onRefresh: () async {
                      AppHaptics.mediumImpact();
                      await context.read<ExpenseListCubit>().loadExpenses();
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.only(bottom: 80),
                      itemCount: state.expenses.length,
                      itemBuilder: (context, index) {
                        final expense = state.expenses[index];
                        return Dismissible(
                          key: Key(expense.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20.0),
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppTheme.expenseColor,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.delete_outline_rounded,
                              color: AppTheme.textColor,
                              size: 28,
                            ),
                          ),
                          confirmDismiss: (direction) async {
                            return await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                backgroundColor: AppTheme.cardBackgroundColor,
                                title: const Text('Delete Record?', style: TextStyle(color: AppTheme.textColor)),
                                content: const Text(
                                  'Are you sure you want to remove this transaction?',
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
                          },
                          onDismissed: (direction) async {
                            AppHaptics.heavyImpact();
                            final formCubit = context.read<ExpenseFormCubit>();
                            final listCubit = context.read<ExpenseListCubit>();
                            final dashboardCubit = context.read<DashboardCubit>();
                            final messenger = ScaffoldMessenger.of(context);

                            final deletedExpense = expense;
                            await formCubit.deleteExpenseUseCase.execute(expense.id);

                            listCubit.loadExpenses();
                            dashboardCubit.loadDashboard();

                            messenger.showSnackBar(
                              SnackBar(
                                content: Text('${deletedExpense.category} record deleted', style: const TextStyle(color: AppTheme.textColor)),
                                backgroundColor: AppTheme.cardBackgroundColor,
                                duration: const Duration(seconds: 4),
                                action: SnackBarAction(
                                  label: 'UNDO',
                                  textColor: AppTheme.baseHighlightColor,
                                  onPressed: () async {
                                    await formCubit.addExpenseUseCase.execute(deletedExpense);
                                    listCubit.loadExpenses();
                                    dashboardCubit.loadDashboard();
                                  },
                                ),
                              ),
                            );
                          },
                          child: ExpenseTile(
                            expense: expense,
                            onTap: () async {
                              AppHaptics.lightImpact();
                              final listCubit = context.read<ExpenseListCubit>();
                              final dashboardCubit = context.read<DashboardCubit>();

                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ExpenseFormScreen(
                                    expenseToEdit: expense,
                                  ),
                                ),
                              );
                              if (result == true) {
                                listCubit.loadExpenses();
                                dashboardCubit.loadDashboard();
                              }
                            },
                          ),
                        );
                      },
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeTab({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: AppTheme.baseHighlightColor,
      backgroundColor: AppTheme.cardBackgroundColor,
      side: BorderSide(
        color: isSelected ? AppTheme.baseHighlightColor : AppTheme.textColor.withValues(alpha: 0.3),
      ),
      labelStyle: TextStyle(
        color: isSelected ? AppTheme.backgroundColor : AppTheme.textColor,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 13,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
    );
  }

  Widget _buildCategoryFilterChip(
      BuildContext context, String categoryName, String selectedCategory) {
    final isSelected = selectedCategory == categoryName;

    return Padding(
      padding: const EdgeInsets.only(right: 6.0),
      child: FilterChip(
        label: Text(categoryName),
        selected: isSelected,
        onSelected: (_) {
          context.read<ExpenseListCubit>().setCategory(categoryName);
        },
        selectedColor: AppTheme.baseHighlightColor,
        backgroundColor: AppTheme.cardBackgroundColor,
        checkmarkColor: AppTheme.backgroundColor,
        side: BorderSide(
          color: isSelected ? AppTheme.baseHighlightColor : AppTheme.textColor.withValues(alpha: 0.3),
        ),
        labelStyle: TextStyle(
          color: isSelected ? AppTheme.backgroundColor : AppTheme.textColor,
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }
}
