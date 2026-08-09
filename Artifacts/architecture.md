## High-level architecture (layered)
**Presentation (UI)**
- Screens (pages) + Widgets
- Form inputs, lists, empty states
- Uses a state manager (Bloc/Cubit, Riverpod, or Provider)

**Application (Use Cases / Controllers)**
- `AddExpense`
- `UpdateExpense`
- `DeleteExpense`
- `ListExpenses`
- `GetSummary` (totals, totals by category, date-range filters)

**Domain (Models + Contracts)**
- `Expense` entity (pure Dart)
- Repositories + query contracts

**Data (Persistence)**
- Local database implementation (e.g., **Hive** or **Drift/SQLite**)
- DTO mapping (if using Drift) and query methods

**External dependencies**
- Date/currency formatting utilities
- (Optional later) CSV export

This keeps UI thin and makes persistence replaceable.

---

## Suggested screen flow
1. **Home / Dashboard**
   - Summary widgets (total this month, by category)
   - Quick “Add” FAB

2. **Expenses List**
   - Filter bar (category + date range)
   - Search (optional)
   - List rows (tap → edit)

3. **Expense Form (Add/Edit)**
   - Amount, category, date, note (optional), payment method (optional)
   - Validate → submit → back

4. **(Optional) Settings / Categories**
   - Only if you add user-defined categories

---

## Data model (domain)
```dart
class Expense {
  final String id; // uuid
  final double amount;
  final String category; // e.g. "Food"
  final DateTime date;
  final String? note; // merchant/description
  final String? paymentMethod; // "Cash" | "Card" | ...
  final DateTime createdAt;
  final DateTime updatedAt;

  Expense({
    required this.id,
    required this.amount,
    required this.category,
    required this.date,
    this.note,
    this.paymentMethod,
    required this.createdAt,
    required this.updatedAt,
  });
}
```

Keep it simple: category as `String` works great for an MVP.

---

## Repository contract (domain layer)
```dart
abstract class ExpenseRepository {
  Future<void> addExpense(Expense expense);
  Future<void> updateExpense(Expense expense);
  Future<void> deleteExpense(String id);

  Future<List<Expense>> listExpenses({
    DateTime? from,
    DateTime? to,
    String? category,
  });

  Future<ExpenseSummary> getSummary({
    DateTime? from,
    DateTime? to,
    String? category,
  });
}

class ExpenseSummary {
  final double total;
  final Map<String, double> totalsByCategory; // category -> sum
  const ExpenseSummary({
    required this.total,
    required this.totalsByCategory,
  });
}
```

---

## Use cases (application layer)
You can implement them as simple classes that orchestrate repository calls.

Example:
- `AddExpenseUseCase` → validates/normalizes then calls `repository.addExpense`
- `ListExpensesUseCase` → forwards filters
- `GetSummaryUseCase` → computes via repository (preferred) or sums in app layer

For MVP, you can keep this small:
- `ExpenseController` (or Cubit) that calls repository methods directly
- But if you want “proper” layering, use the use case classes.

---

## Persistence layer choice (recommended)
### Option A (easiest): Hive (no SQL)
- Store `Expense` as Hive objects/boxes
- Implement repository methods:
  - `add/update/delete`
  - `listExpenses` = iterate + filter in Dart (fine for small data)
  - `getSummary` = iterate + sum (fine for MVP)

### Option B (clean querying): Drift (SQLite)
- Better for large histories
- Category totals and date filtering happen in SQL
- More setup, but very robust

If you want to vibe-code fastest: **Hive**.

---

## State management structure (what you wire up)
Pick one approach; here’s a common Bloc/Cubit style mapping.

### Controllers / Cubits
- `DashboardCubit`
  - state: summary for current filter range
  - loads summary on init
- `ExpenseListCubit`
  - state: list + active filters + loading/error
  - `loadExpenses()` when filters change
- `ExpenseFormCubit` (or just local form state)
  - state: current form values + validation errors
  - on submit: calls `addExpense` or `updateExpense`

### State objects
Keep states explicit:
- loading
- loaded (data)
- error (message)

---

## Error handling + validation (simple rules)
- Amount: required, parsed as number, must be `> 0`
- Date: required (default today)
- Category: required (dropdown)
- On persistence failure: show a snackbar and keep the form open

---

## Dependency injection (wiring)
Create a small composition root:
- instantiate repository implementation (Hive/Drift)
- instantiate controllers/use cases with repository
- provide to widget tree

This ensures:
- UI never touches DB directly
- you can swap persistence later

---

## File / folder organization (example)
- `lib/domain/`
  - `entities/expense.dart`
  - `repositories/expense_repository.dart`
  - `models/expense_summary.dart`
- `lib/application/`
  - `use_cases/add_expense.dart` (optional)
  - `use_cases/list_expenses.dart` (optional)
  - `use_cases/get_summary.dart` (optional)
- `lib/data/`
  - `repositories/expense_repository_impl.dart`
  - `datasources/` (Hive box wrapper or Drift DAO)
- `lib/presentation/`
  - `screens/dashboard_screen.dart`
  - `screens/expense_list_screen.dart`
  - `screens/expense_form_screen.dart`
  - `state/dashboard_cubit.dart`
  - `state/expense_list_cubit.dart`
  - `state/expense_form_cubit.dart` (optional)
  - `widgets/expense_tile.dart`

---
