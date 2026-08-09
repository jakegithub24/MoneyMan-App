import '../entities/expense.dart';

class ExpenseSummary {
  final double totalIncome;
  final double totalExpense;
  final double netBalance;
  final Map<String, double> totalsByCategory;
  final int totalCount;
  final double averageAmount;
  final double monthlyBudget;

  const ExpenseSummary({
    required this.totalIncome,
    required this.totalExpense,
    required this.netBalance,
    required this.totalsByCategory,
    this.totalCount = 0,
    this.averageAmount = 0.0,
    this.monthlyBudget = 0.0,
  });

  // Backward compatibility getter for total expense
  double get total => totalExpense;

  double get budgetProgress =>
      monthlyBudget > 0 ? (totalExpense / monthlyBudget).clamp(0.0, 1.0) : 0.0;

  double get remainingBudget => monthlyBudget > 0 ? monthlyBudget - totalExpense : 0.0;

  factory ExpenseSummary.fromExpenses(List<Expense> list, {double monthlyBudget = 0.0}) {
    double totalIncome = 0.0;
    double totalExpense = 0.0;
    final Map<String, double> totalsByCategory = {};

    for (final e in list) {
      if (e.isIncome) {
        totalIncome += e.amount;
      } else {
        totalExpense += e.amount;
        totalsByCategory[e.category] = (totalsByCategory[e.category] ?? 0.0) + e.amount;
      }
    }

    final netBalance = totalIncome - totalExpense;
    final totalCount = list.length;
    final averageAmount = totalCount > 0 ? (totalExpense / totalCount) : 0.0;

    return ExpenseSummary(
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      netBalance: netBalance,
      totalsByCategory: totalsByCategory,
      totalCount: totalCount,
      averageAmount: averageAmount,
      monthlyBudget: monthlyBudget,
    );
  }

  factory ExpenseSummary.empty() {
    return const ExpenseSummary(
      totalIncome: 0.0,
      totalExpense: 0.0,
      netBalance: 0.0,
      totalsByCategory: {},
      totalCount: 0,
      averageAmount: 0.0,
      monthlyBudget: 0.0,
    );
  }
}
