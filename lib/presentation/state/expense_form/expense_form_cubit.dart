import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../application/use_cases/add_expense_usecase.dart';
import '../../../application/use_cases/delete_expense_usecase.dart';
import '../../../application/use_cases/update_expense_usecase.dart';
import '../../../domain/entities/expense.dart';
import '../../../domain/entities/transaction_type.dart';
import 'expense_form_state.dart';

class ExpenseFormCubit extends Cubit<ExpenseFormState> {
  final AddExpenseUseCase addExpenseUseCase;
  final UpdateExpenseUseCase updateExpenseUseCase;
  final DeleteExpenseUseCase deleteExpenseUseCase;

  ExpenseFormCubit({
    required this.addExpenseUseCase,
    required this.updateExpenseUseCase,
    required this.deleteExpenseUseCase,
  }) : super(ExpenseFormInitial());

  Future<void> submitExpense({
    Expense? existingExpense,
    required double amount,
    required String category,
    required DateTime date,
    required TransactionType type,
    bool isRecurring = false,
    RecurringInterval recurringInterval = RecurringInterval.none,
    String? note,
    String? paymentMethod,
  }) async {
    if (amount <= 0) {
      emit(ExpenseFormError('Please enter an amount greater than 0'));
      return;
    }
    if (category.trim().isEmpty) {
      emit(ExpenseFormError('Please select a category'));
      return;
    }
    if (date.isAfter(DateTime.now())) {
      emit(ExpenseFormError('Future transaction dates are not allowed. Please select current or past date.'));
      return;
    }

    emit(ExpenseFormSubmitting());

    try {
      final now = DateTime.now();
      if (existingExpense != null) {
        final updated = existingExpense.copyWith(
          amount: amount,
          category: category,
          date: date,
          type: type,
          isRecurring: isRecurring,
          recurringInterval: recurringInterval,
          note: note,
          paymentMethod: paymentMethod,
          updatedAt: now,
        );
        await updateExpenseUseCase.execute(updated);
      } else {
        final newExpense = Expense(
          id: const Uuid().v4(),
          amount: amount,
          category: category,
          date: date,
          type: type,
          isRecurring: isRecurring,
          recurringInterval: recurringInterval,
          note: note,
          paymentMethod: paymentMethod,
          createdAt: now,
          updatedAt: now,
        );
        await addExpenseUseCase.execute(newExpense);
      }
      emit(ExpenseFormSuccess());
    } catch (e) {
      emit(ExpenseFormError(e.toString()));
    }
  }

  Future<void> deleteExpense(String id) async {
    emit(ExpenseFormSubmitting());
    try {
      await deleteExpenseUseCase.execute(id);
      emit(ExpenseFormSuccess());
    } catch (e) {
      emit(ExpenseFormError(e.toString()));
    }
  }
}
