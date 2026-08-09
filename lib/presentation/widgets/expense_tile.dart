import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/expense.dart';
import '../constants/categories.dart';
import '../state/category/category_cubit.dart';
import '../state/currency/currency_cubit.dart';
import '../state/currency/currency_state.dart';
import '../theme/app_theme.dart';

class ExpenseTile extends StatelessWidget {
  final Expense expense;
  final VoidCallback? onTap;

  const ExpenseTile({
    super.key,
    required this.expense,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    CategoryItem catInfo;
    try {
      catInfo = context.read<CategoryCubit>().getCategoryByName(expense.category);
    } catch (_) {
      catInfo = AppCategories.getCategoryByName(expense.category);
    }

    final isIncome = expense.isIncome;
    final amountColor = isIncome ? AppTheme.incomeColor : AppTheme.expenseColor;

    return BlocBuilder<CurrencyCubit, CurrencyState>(
      builder: (context, currState) {
        final symbol = currState.currency.symbol;
        final amountPrefix = isIncome ? '+$symbol' : '-$symbol';

        return TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 300),
          tween: Tween<double>(begin: 0.0, end: 1.0),
          curve: Curves.easeOutCubic,
          builder: (context, value, childWidget) {
            return Transform.translate(
              offset: Offset(0, 10 * (1 - value)),
              child: Opacity(
                opacity: value,
                child: childWidget,
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.cardBackgroundColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.textColor.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: onTap,
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Row(
                    children: [
                      // Category Icon Badge
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppTheme.baseHighlightColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          catInfo.icon,
                          color: AppTheme.baseHighlightColor,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      // Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    expense.note != null && expense.note!.isNotEmpty
                                        ? expense.note!
                                        : expense.category,
                                    style: const TextStyle(
                                      color: AppTheme.textColor,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (expense.isRecurring) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppTheme.popHighlightColor.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: AppTheme.popHighlightColor.withValues(alpha: 0.5),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.autorenew_rounded,
                                          size: 10,
                                          color: AppTheme.popHighlightColor,
                                        ),
                                        const SizedBox(width: 2),
                                        Text(
                                          expense.recurringInterval.displayName,
                                          style: const TextStyle(
                                            color: AppTheme.popHighlightColor,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  expense.category,
                                  style: TextStyle(
                                    color: AppTheme.textColor.withValues(alpha: 0.8),
                                    fontSize: 13,
                                  ),
                                ),
                                if (expense.paymentMethod != null &&
                                    expense.paymentMethod!.isNotEmpty) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppTheme.backgroundColor,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      expense.paymentMethod!,
                                      style: const TextStyle(
                                        color: AppTheme.textColor,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Amount & Date
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '$amountPrefix${expense.amount.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: amountColor,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat.MMMd().format(expense.date),
                            style: TextStyle(
                              color: AppTheme.textColor.withValues(alpha: 0.6),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
