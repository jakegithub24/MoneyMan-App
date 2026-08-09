import '../../../domain/entities/expense.dart';
import '../../../domain/entities/transaction_type.dart';

abstract class ExpenseListState {}

class ExpenseListInitial extends ExpenseListState {}

class ExpenseListLoading extends ExpenseListState {}

class ExpenseListLoaded extends ExpenseListState {
  final List<Expense> expenses;
  final String selectedCategory;
  final String searchQuery;
  final TransactionType? selectedType;
  final bool onlyRecurring;
  final DateTime? fromDate;
  final DateTime? toDate;

  ExpenseListLoaded({
    required this.expenses,
    this.selectedCategory = 'All',
    this.searchQuery = '',
    this.selectedType,
    this.onlyRecurring = false,
    this.fromDate,
    this.toDate,
  });

  ExpenseListLoaded copyWith({
    List<Expense>? expenses,
    String? selectedCategory,
    String? searchQuery,
    TransactionType? selectedType,
    bool? onlyRecurring,
    DateTime? fromDate,
    DateTime? toDate,
  }) {
    return ExpenseListLoaded(
      expenses: expenses ?? this.expenses,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedType: selectedType ?? this.selectedType,
      onlyRecurring: onlyRecurring ?? this.onlyRecurring,
      fromDate: fromDate ?? this.fromDate,
      toDate: toDate ?? this.toDate,
    );
  }
}

class ExpenseListError extends ExpenseListState {
  final String message;
  ExpenseListError(this.message);
}
