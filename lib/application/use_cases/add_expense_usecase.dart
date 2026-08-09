import '../../domain/entities/expense.dart';
import '../../domain/repositories/expense_repository.dart';

class AddExpenseUseCase {
  final ExpenseRepository repository;

  AddExpenseUseCase(this.repository);

  Future<void> execute(Expense expense) async {
    if (expense.amount <= 0) {
      throw ArgumentError('Amount must be greater than zero');
    }
    if (expense.category.trim().isEmpty) {
      throw ArgumentError('Category is required');
    }
    await repository.addExpense(expense);
  }
}
