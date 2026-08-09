import '../../domain/repositories/expense_repository.dart';

class DeleteExpenseUseCase {
  final ExpenseRepository repository;

  DeleteExpenseUseCase(this.repository);

  Future<void> execute(String id) async {
    if (id.trim().isEmpty) {
      throw ArgumentError('ID cannot be empty');
    }
    await repository.deleteExpense(id);
  }
}
