abstract class ExpenseFormState {}

class ExpenseFormInitial extends ExpenseFormState {}

class ExpenseFormSubmitting extends ExpenseFormState {}

class ExpenseFormSuccess extends ExpenseFormState {}

class ExpenseFormError extends ExpenseFormState {
  final String message;
  ExpenseFormError(this.message);
}
