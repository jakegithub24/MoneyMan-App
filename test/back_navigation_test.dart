import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_101/domain/repositories/expense_repository.dart';
import 'package:flutter_application_101/domain/repositories/category_repository.dart';
import 'package:flutter_application_101/domain/models/expense_summary.dart';
import 'package:flutter_application_101/domain/entities/expense.dart';
import 'package:flutter_application_101/domain/entities/category_item.dart';
import 'package:flutter_application_101/domain/entities/transaction_type.dart';
import 'package:flutter_application_101/application/use_cases/get_summary_usecase.dart';
import 'package:flutter_application_101/application/use_cases/list_expenses_usecase.dart';
import 'package:flutter_application_101/application/use_cases/delete_expense_usecase.dart';
import 'package:flutter_application_101/presentation/state/dashboard/dashboard_cubit.dart';
import 'package:flutter_application_101/presentation/state/expense_list/expense_list_cubit.dart';
import 'package:flutter_application_101/presentation/state/currency/currency_cubit.dart';
import 'package:flutter_application_101/presentation/state/category/category_cubit.dart';
import 'package:flutter_application_101/presentation/screens/main_navigation_screen.dart';

class MockExpenseRepository implements ExpenseRepository {
  @override
  Future<List<Expense>> listExpenses({
    DateTime? from,
    DateTime? to,
    String? category,
    TransactionType? type,
    bool? onlyRecurring,
    String? searchQuery,
  }) async => [];

  @override
  Future<ExpenseSummary> getSummary({
    DateTime? from,
    DateTime? to,
    String? category,
  }) async => ExpenseSummary.empty();

  @override
  Future<void> addExpense(Expense expense) async {}

  @override
  Future<void> deleteExpense(String id) async {}

  @override
  Future<void> updateExpense(Expense expense) async {}

  @override
  Future<double> getMonthlyBudget() async => 0.0;

  @override
  Future<void> setMonthlyBudget(double budget) async {}

  @override
  Future<String?> getSecurityPin() async => null;

  @override
  Future<void> setSecurityPin(String? pin) async {}

  @override
  Future<bool> isSecurityLockEnabled() async => false;

  @override
  Future<void> setSecurityLockEnabled(bool enabled) async {}

  @override
  Future<int> getAutoLockIntervalMinutes() async => 1;

  @override
  Future<void> setAutoLockIntervalMinutes(int minutes) async {}

  @override
  Future<int?> getLastActiveTimestamp() async => null;

  @override
  Future<void> setLastActiveTimestamp(int timestamp) async {}

  @override
  Future<String?> getUserName() async => 'TestUser';

  @override
  Future<void> setUserName(String name) async {}

  @override
  Future<bool> isOnboardingCompleted() async => true;

  @override
  Future<void> setOnboardingCompleted(bool completed) async {}

  @override
  Future<String> getCurrencyCode() async => 'USD';

  @override
  Future<String> getCurrencySymbol() async => '\$';

  @override
  Future<void> setCurrency(String code, String symbol) async {}

  @override
  Future<bool> isBiometricLockEnabled() async => false;

  @override
  Future<void> setBiometricLockEnabled(bool enabled) async {}

  @override
  Future<bool> isHapticFeedbackEnabled() async => true;

  @override
  Future<void> setHapticFeedbackEnabled(bool enabled) async {}

  @override
  Future<String> exportToCsv({
    TransactionType? type,
    DateTime? from,
    DateTime? to,
    String? category,
  }) async => '';

  @override
  Future<int> importFromCsv(String csvData) async => 0;

  @override
  Future<String> saveCsvToStorage(
    String csvData,
    String fileName, {
    String? targetDirectoryPath,
  }) async => '/tmp/$fileName';

  @override
  Future<void> resetDatabase() async {}
}

class MockCategoryRepository implements CategoryRepository {
  @override
  Future<List<CategoryItem>> getCategories({TransactionType? type}) async => [];

  @override
  Future<void> addCategory(CategoryItem category) async {}

  @override
  Future<void> deleteCategory(String id) async {}

  @override
  CategoryItem getCategoryByName(String name) => CategoryItem(
        id: name.toLowerCase(),
        name: name,
        iconCodePoint: Icons.category.codePoint,
        colorValue: 0xFF64748B,
      );

  @override
  Future<void> resetCategories() async {}
}

void main() {
  testWidgets('Back navigation returns to Dashboard from Transactions before quitting', (tester) async {
    final repository = MockExpenseRepository();
    final categoryRepository = MockCategoryRepository();
    final getSummaryUseCase = GetSummaryUseCase(repository);
    final listExpensesUseCase = ListExpensesUseCase(repository);
    final deleteExpenseUseCase = DeleteExpenseUseCase(repository);

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<DashboardCubit>(
            create: (_) => DashboardCubit(
              getSummaryUseCase: getSummaryUseCase,
              listExpensesUseCase: listExpensesUseCase,
            ),
          ),
          BlocProvider<ExpenseListCubit>(
            create: (_) => ExpenseListCubit(
              listExpensesUseCase: listExpensesUseCase,
              deleteExpenseUseCase: deleteExpenseUseCase,
            ),
          ),
          BlocProvider<CurrencyCubit>(
            create: (_) => CurrencyCubit(repository),
          ),
          BlocProvider<CategoryCubit>(
            create: (_) => CategoryCubit(categoryRepository: categoryRepository),
          ),
        ],
        child: MaterialApp(
          home: MainNavigationScreen(repository: repository),
        ),
      ),
    );

    // Pump frames for async _checkAppLock
    for (int i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 20));
    }

    final popScopeFinder = find.byWidgetPredicate((widget) => widget is PopScope);
    expect(popScopeFinder, findsOneWidget);

    final dynamic initialPopScope = tester.widget(popScopeFinder);
    expect(initialPopScope.canPop, isTrue);

    // Tap on Transactions tab in BottomNavigationBar
    final transactionsTab = find.byIcon(Icons.receipt_long_rounded);
    await tester.tap(transactionsTab);
    for (int i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 20));
    }

    // Now we are on Transactions tab -> canPop must be false
    final dynamic transactionsPopScope = tester.widget(popScopeFinder);
    expect(transactionsPopScope.canPop, isFalse);

    // Simulate system back gesture / back button press
    transactionsPopScope.onPopInvokedWithResult(false, null);
    for (int i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 20));
    }

    // After back pressed from Transactions, user is back on Dashboard tab
    final dynamic returnedPopScope = tester.widget(popScopeFinder);
    expect(returnedPopScope.canPop, isTrue);
  });
}
