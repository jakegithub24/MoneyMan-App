import '../../../domain/entities/expense.dart';

abstract class ExpenseListState {}

class ExpenseListInitial extends ExpenseListState {}

class ExpenseListLoading extends ExpenseListState {}

class ExpenseListLoaded extends ExpenseListState {
  final List<Expense> expenses;
  final String selectedCategory;
  final String searchQuery;
  final DateTime? fromDate;
  final DateTime? toDate;

  ExpenseListLoaded({
    required this.expenses,
    this.selectedCategory = 'All',
    this.searchQuery = '',
    this.fromDate,
    this.toDate,
  });

  ExpenseListLoaded copyWith({
    List<Expense>? expenses,
    String? selectedCategory,
    String? searchQuery,
    DateTime? fromDate,
    DateTime? toDate,
  }) {
    return ExpenseListLoaded(
      expenses: expenses ?? this.expenses,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
      fromDate: fromDate ?? this.fromDate,
      toDate: toDate ?? this.toDate,
    );
  }
}

class ExpenseListError extends ExpenseListState {
  final String message;
  ExpenseListError(this.message);
}
