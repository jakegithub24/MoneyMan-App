import '../../domain/entities/expense.dart';
import '../../domain/repositories/expense_repository.dart';

class ListExpensesUseCase {
  final ExpenseRepository repository;

  ListExpensesUseCase(this.repository);

  Future<List<Expense>> execute({
    DateTime? from,
    DateTime? to,
    String? category,
    String? searchQuery,
  }) async {
    return await repository.listExpenses(
      from: from,
      to: to,
      category: category,
      searchQuery: searchQuery,
    );
  }
}
