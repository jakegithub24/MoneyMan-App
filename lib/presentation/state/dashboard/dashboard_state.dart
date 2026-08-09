import '../../../domain/entities/expense.dart';
import '../../../domain/models/expense_summary.dart';

enum DateFilterType { today, thisWeek, thisMonth, thisYear, all }

abstract class DashboardState {}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final ExpenseSummary summary;
  final List<Expense> recentExpenses;
  final DateFilterType filterType;

  DashboardLoaded({
    required this.summary,
    required this.recentExpenses,
    required this.filterType,
  });
}

class DashboardError extends DashboardState {
  final String message;
  DashboardError(this.message);
}
