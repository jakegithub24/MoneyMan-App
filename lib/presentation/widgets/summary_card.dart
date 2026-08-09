import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/models/expense_summary.dart';
import '../state/currency/currency_cubit.dart';
import '../state/currency/currency_state.dart';
import '../state/dashboard/dashboard_state.dart';
import '../theme/app_theme.dart';

class SummaryCard extends StatelessWidget {
  final ExpenseSummary summary;
  final DateFilterType filterType;
  final VoidCallback? onSetBudgetTap;

  const SummaryCard({
    super.key,
    required this.summary,
    required this.filterType,
    this.onSetBudgetTap,
  });

  @override
  Widget build(BuildContext context) {
    final progress = summary.budgetProgress;
    final isOverBudget = summary.monthlyBudget > 0 && summary.totalExpense > summary.monthlyBudget;
    final isNearBudget = summary.monthlyBudget > 0 && progress >= 0.8 && !isOverBudget;

    return BlocBuilder<CurrencyCubit, CurrencyState>(
      builder: (context, currState) {
        final symbol = currState.currency.symbol;

        return Column(
          children: [
            // Top 4 Metric Cards Grid (Using colors.txt palette)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Column(
                children: [
                  Row(
                    children: [
                      // Income Metric Card
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.cardBackgroundColor,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppTheme.textColor.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: AppTheme.incomeColor.withValues(alpha: 0.25),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.arrow_downward_rounded,
                                      color: AppTheme.incomeColor,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Income',
                                    style: TextStyle(
                                      color: AppTheme.textColor.withValues(alpha: 0.8),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                '+$symbol${summary.totalIncome.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: AppTheme.incomeColor,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Expense Metric Card
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.cardBackgroundColor,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppTheme.textColor.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: AppTheme.expenseColor.withValues(alpha: 0.25),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.arrow_upward_rounded,
                                      color: AppTheme.expenseColor,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Expense',
                                    style: TextStyle(
                                      color: AppTheme.textColor.withValues(alpha: 0.8),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                '-$symbol${summary.totalExpense.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: AppTheme.expenseColor,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      // Net Balance Card
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.cardBackgroundColor,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppTheme.textColor.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: AppTheme.baseHighlightColor.withValues(alpha: 0.25),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.savings_rounded,
                                      color: AppTheme.baseHighlightColor,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Net Balance',
                                    style: TextStyle(
                                      color: AppTheme.textColor.withValues(alpha: 0.8),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                '${summary.netBalance >= 0 ? '+' : '-'}$symbol${summary.netBalance.abs().toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: summary.netBalance >= 0 ? AppTheme.incomeColor : AppTheme.expenseColor,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Transactions Count Card
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.cardBackgroundColor,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppTheme.textColor.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: AppTheme.popHighlightColor.withValues(alpha: 0.25),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.receipt_long_rounded,
                                      color: AppTheme.popHighlightColor,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Activity',
                                    style: TextStyle(
                                      color: AppTheme.textColor.withValues(alpha: 0.8),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                '${summary.totalCount} records',
                                style: const TextStyle(
                                  color: AppTheme.textColor,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Monthly Budget Progress Bar Card (colors.txt palette)
            if (summary.monthlyBudget > 0) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.cardBackgroundColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isOverBudget
                          ? AppTheme.expenseColor
                          : isNearBudget
                              ? AppTheme.popHighlightColor
                              : AppTheme.textColor.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                isOverBudget
                                    ? Icons.warning_amber_rounded
                                    : isNearBudget
                                        ? Icons.info_outline_rounded
                                        : Icons.account_balance_wallet_rounded,
                                size: 18,
                                color: isOverBudget
                                    ? AppTheme.expenseColor
                                    : isNearBudget
                                        ? AppTheme.popHighlightColor
                                        : AppTheme.baseHighlightColor,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                isOverBudget
                                    ? 'Budget Exceeded!'
                                    : isNearBudget
                                        ? 'Near Budget Limit'
                                        : 'Monthly Budget Limit',
                                style: TextStyle(
                                  color: isOverBudget
                                      ? AppTheme.expenseColor
                                      : isNearBudget
                                          ? AppTheme.popHighlightColor
                                          : AppTheme.textColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          InkWell(
                            onTap: onSetBudgetTap,
                            child: Text(
                              '$symbol${summary.totalExpense.toStringAsFixed(0)} / $symbol${summary.monthlyBudget.toStringAsFixed(0)}',
                              style: TextStyle(
                                color: AppTheme.textColor.withValues(alpha: 0.8),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 8,
                          backgroundColor: AppTheme.backgroundColor,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isOverBudget
                                ? AppTheme.expenseColor
                                : isNearBudget
                                    ? AppTheme.popHighlightColor
                                    : AppTheme.baseHighlightColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
