import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/transaction_type.dart';
import '../../domain/repositories/expense_repository.dart';
import '../state/dashboard/dashboard_cubit.dart';
import '../state/dashboard/dashboard_state.dart';
import '../state/expense_list/expense_list_cubit.dart';
import '../theme/app_theme.dart';
import '../widgets/category_pie_chart.dart';
import '../widgets/expense_tile.dart';
import '../widgets/filter_chip_bar.dart';
import '../widgets/summary_card.dart';
import '../utils/app_haptics.dart';
import 'expense_form_screen.dart';
import 'security_pin_screen.dart';
import 'settings_screen.dart';

class DashboardScreen extends StatelessWidget {
  final ExpenseRepository repository;
  final VoidCallback onSeeAllPressed;
  final Function(TransactionType? type)? onNavigateToTransactionsWithFilter;
  final Function? onNavigateToTransactionsWithCategory;

  const DashboardScreen({
    super.key,
    required this.repository,
    required this.onSeeAllPressed,
    this.onNavigateToTransactionsWithFilter,
    this.onNavigateToTransactionsWithCategory,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: AppTheme.cardBackgroundColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.baseHighlightColor, width: 1.5),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  'Logo/MoneyMan-Logo.jpg',
                  width: 30,
                  height: 30,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MoneyMan',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textColor,
                  ),
                ),
                Text(
                  'Income & Expense Tracker',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppTheme.textColor,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.lock_outline_rounded, color: AppTheme.textColor),
            tooltip: 'Lock App',
            onPressed: () async {
              AppHaptics.heavyImpact();
              final pin = await repository.getSecurityPin();
              final lockEnabled = await repository.isSecurityLockEnabled();
              if (!context.mounted) return;
              if (lockEnabled && pin != null && pin.isNotEmpty) {
                final biometricEnabled = await repository.isBiometricLockEnabled();
                if (!context.mounted) return;
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SecurityPinScreen(
                      mode: PinMode.unlock,
                      savedPin: pin,
                      isBiometricEnabled: biometricEnabled,
                    ),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('App lock is disabled. Enable PIN lock in Settings.', style: TextStyle(color: AppTheme.textColor)),
                    backgroundColor: AppTheme.cardBackgroundColor,
                  ),
                );
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.settings_rounded, color: AppTheme.textColor),
            tooltip: 'Settings & Tools',
            onPressed: () async {
              AppHaptics.lightImpact();
              final dashboardCubit = context.read<DashboardCubit>();
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SettingsScreen(
                    repository: repository,
                    onSettingsUpdated: () {
                      dashboardCubit.loadDashboard();
                    },
                  ),
                ),
              );
              dashboardCubit.loadDashboard();
            },
          ),
        ],
      ),
      body: BlocBuilder<DashboardCubit, DashboardState>(
        builder: (context, state) {
          if (state is DashboardLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.baseHighlightColor),
            );
          }

          if (state is DashboardError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline_rounded,
                        color: AppTheme.expenseColor, size: 48),
                    const SizedBox(height: 12),
                    Text(
                      state.message,
                      style: TextStyle(color: AppTheme.textColor),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.baseHighlightColor,
                        foregroundColor: AppTheme.backgroundColor,
                      ),
                      onPressed: () =>
                          context.read<DashboardCubit>().loadDashboard(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is DashboardLoaded) {
            return RefreshIndicator(
              color: AppTheme.baseHighlightColor,
              backgroundColor: AppTheme.cardBackgroundColor,
              onRefresh: () async {
                AppHaptics.mediumImpact();
                await context.read<DashboardCubit>().loadDashboard(filterType: state.filterType);
              },
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 24),
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Greeting & Period Info
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FutureBuilder<String?>(
                          future: repository.getUserName(),
                          builder: (context, snapshot) {
                            final username = (snapshot.data != null && snapshot.data!.trim().isNotEmpty)
                                ? snapshot.data!.trim()
                                : 'User';
                            return Row(
                              children: [
                                Text(
                                  'Hello, ',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textColor,
                                  ),
                                ),
                                Text(
                                  username,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.baseHighlightColor,
                                  ),
                                ),
                                const Text(
                                  '!👋',
                                  style: TextStyle(fontSize: 24),
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Here\'s your financial overview for this period.',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.textColor.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),

                  FilterChipBar(
                    selectedFilter: state.filterType,
                    onFilterSelected: (filter) {
                      context
                          .read<DashboardCubit>()
                          .loadDashboard(filterType: filter);
                    },
                  ),

                  SummaryCard(
                    summary: state.summary,
                    filterType: state.filterType,
                    onIncomeTap: () {
                      if (onNavigateToTransactionsWithFilter != null) {
                        onNavigateToTransactionsWithFilter!(TransactionType.income);
                      } else {
                        onSeeAllPressed();
                      }
                    },
                    onExpenseTap: () {
                      if (onNavigateToTransactionsWithFilter != null) {
                        onNavigateToTransactionsWithFilter!(TransactionType.expense);
                      } else {
                        onSeeAllPressed();
                      }
                    },
                    onActivityTap: () {
                      if (onNavigateToTransactionsWithFilter != null) {
                        onNavigateToTransactionsWithFilter!(null);
                      } else {
                        onSeeAllPressed();
                      }
                    },
                  ),

                  CategoryPieChart(
                    summary: state.summary,
                    allPeriodExpenses: state.allPeriodExpenses,
                    filterType: state.filterType,
                    totalsByCategory: state.summary.totalsByCategory,
                    totalAmount: state.summary.totalExpense,
                    onCategoryTap: (category, [type]) {
                      AppHaptics.lightImpact();
                      if (onNavigateToTransactionsWithCategory != null) {
                        try {
                          (onNavigateToTransactionsWithCategory as dynamic)(category, type);
                        } catch (_) {
                          (onNavigateToTransactionsWithCategory as dynamic)(category);
                        }
                      } else {
                        onSeeAllPressed();
                      }
                    },
                  ),

                  // Quick Action Buttons for Income vs Expense
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.incomeColor,
                              side: const BorderSide(color: AppTheme.incomeColor, width: 1.5),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            icon: const Icon(Icons.add_circle_outline_rounded, size: 20),
                            label: const Text('Add Income',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            onPressed: () async {
                              final dashboardCubit = context.read<DashboardCubit>();
                              final listCubit = context.read<ExpenseListCubit>();
                              final res = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ExpenseFormScreen(
                                    initialType: TransactionType.income,
                                  ),
                                ),
                              );
                              if (res == true) {
                                dashboardCubit.loadDashboard();
                                listCubit.loadExpenses();
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.expenseColor,
                              side: const BorderSide(color: AppTheme.expenseColor, width: 1.5),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            icon: const Icon(Icons.remove_circle_outline_rounded, size: 20),
                            label: const Text('Add Expense',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            onPressed: () async {
                              final dashboardCubit = context.read<DashboardCubit>();
                              final listCubit = context.read<ExpenseListCubit>();
                              final res = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ExpenseFormScreen(
                                    initialType: TransactionType.expense,
                                  ),
                                ),
                              );
                              if (res == true) {
                                dashboardCubit.loadDashboard();
                                listCubit.loadExpenses();
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Recent Activity Header
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recent Activity',
                          style: TextStyle(
                            color: AppTheme.textColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: onSeeAllPressed,
                          child: const Row(
                            children: [
                              Text(
                                'See All',
                                style: TextStyle(
                                  color: AppTheme.baseHighlightColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(width: 4),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: AppTheme.baseHighlightColor,
                                size: 14,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (state.recentExpenses.isEmpty)
                    Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: AppTheme.cardBackgroundColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.receipt_long_rounded,
                            size: 48,
                            color: AppTheme.textColor,
                          ),
                          SizedBox(height: 12),
                          Text(
                            'No transactions found',
                            style: TextStyle(
                              color: AppTheme.textColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Tap + below or quick action above to get started',
                            style: TextStyle(
                              color: AppTheme.textColor,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ...state.recentExpenses.map(
                      (expense) => ExpenseTile(
                        expense: expense,
                        onTap: () async {
                          final dashboardCubit = context.read<DashboardCubit>();
                          final listCubit = context.read<ExpenseListCubit>();
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ExpenseFormScreen(
                                expenseToEdit: expense,
                              ),
                            ),
                          );
                          if (result == true) {
                            dashboardCubit.loadDashboard(filterType: state.filterType);
                            listCubit.loadExpenses();
                          }
                        },
                      ),
                    ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          );
        }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
