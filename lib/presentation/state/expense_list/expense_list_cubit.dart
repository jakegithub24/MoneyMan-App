import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../application/use_cases/delete_expense_usecase.dart';
import '../../../application/use_cases/list_expenses_usecase.dart';
import '../../../domain/entities/transaction_type.dart';
import 'expense_list_state.dart';

class ExpenseListCubit extends Cubit<ExpenseListState> {
  final ListExpensesUseCase listExpensesUseCase;
  final DeleteExpenseUseCase deleteExpenseUseCase;

  String _currentCategory = 'All';
  String _currentQuery = '';
  TransactionType? _currentType;
  bool _onlyRecurring = false;
  DateTime? _currentFrom;
  DateTime? _currentTo;

  ExpenseListCubit({
    required this.listExpensesUseCase,
    required this.deleteExpenseUseCase,
  }) : super(ExpenseListInitial());

  Future<void> loadExpenses() async {
    emit(ExpenseListLoading());
    try {
      final list = await listExpensesUseCase.repository.listExpenses(
        category: _currentCategory == 'All' ? null : _currentCategory,
        searchQuery: _currentQuery.isEmpty ? null : _currentQuery,
        type: _currentType,
        onlyRecurring: _onlyRecurring,
        from: _currentFrom,
        to: _currentTo,
      );
      emit(ExpenseListLoaded(
        expenses: list,
        selectedCategory: _currentCategory,
        searchQuery: _currentQuery,
        selectedType: _currentType,
        onlyRecurring: _onlyRecurring,
        fromDate: _currentFrom,
        toDate: _currentTo,
      ));
    } catch (e) {
      emit(ExpenseListError(e.toString()));
    }
  }

  void setCategory(String category) {
    _currentCategory = category;
    loadExpenses();
  }

  void filterByCategory(String category, {TransactionType? type}) {
    _currentCategory = category;
    _currentQuery = '';
    _currentType = type;
    _onlyRecurring = false;
    _currentFrom = null;
    _currentTo = null;
    loadExpenses();
  }

  void setSearchQuery(String query) {
    _currentQuery = query;
    loadExpenses();
  }

  void setTypeAndRecurringFilter(TransactionType? type, bool onlyRecurring) {
    _currentType = type;
    _onlyRecurring = onlyRecurring;
    loadExpenses();
  }

  void setDateRange(DateTime? from, DateTime? to) {
    _currentFrom = from;
    _currentTo = to;
    loadExpenses();
  }

  void clearFilters() {
    _currentCategory = 'All';
    _currentQuery = '';
    _currentType = null;
    _onlyRecurring = false;
    _currentFrom = null;
    _currentTo = null;
    loadExpenses();
  }

  Future<void> deleteExpense(String id) async {
    try {
      await deleteExpenseUseCase.execute(id);
      loadExpenses();
    } catch (e) {
      emit(ExpenseListError('Failed to delete transaction: ${e.toString()}'));
    }
  }
}
