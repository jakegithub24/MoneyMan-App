import '../../domain/models/expense_summary.dart';
import '../../domain/repositories/expense_repository.dart';

class GetSummaryUseCase {
  final ExpenseRepository repository;

  GetSummaryUseCase(this.repository);

  Future<ExpenseSummary> execute({
    DateTime? from,
    DateTime? to,
    String? category,
  }) async {
    return await repository.getSummary(
      from: from,
      to: to,
      category: category,
    );
  }
}
