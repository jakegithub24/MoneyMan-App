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
import 'package:flutter_application_101/presentation/state/expense_list/expense_list_state.dart';
import 'package:flutter_application_101/presentation/state/currency/currency_cubit.dart';
import 'package:flutter_application_101/presentation/state/category/category_cubit.dart';
import 'package:flutter_application_101/presentation/screens/main_navigation_screen.dart';
import 'package:flutter_application_101/presentation/screens/expense_list_screen.dart';
import 'package:flutter_application_101/presentation/widgets/category_pie_chart.dart';

class MockPieChartExpenseRepository implements ExpenseRepository {
  final List<Expense> _expenses = [];

  MockPieChartExpenseRepository() {
    final now = DateTime.now();
    _expenses.addAll([
      Expense(
        id: '1',
        amount: 250.0,
        category: 'Food',
        date: now,
        type: TransactionType.expense,
        createdAt: now,
        updatedAt: now,
      ),
      Expense(
        id: '2',
        amount: 150.0,
        category: 'Shopping',
        date: now,
        type: TransactionType.expense,
        createdAt: now,
        updatedAt: now,
      ),
      Expense(
        id: '3',
        amount: 100.0,
        category: 'Bills',
        date: now,
        type: TransactionType.expense,
        createdAt: now,
        updatedAt: now,
      ),
    ]);
  }

  @override
  Future<List<Expense>> listExpenses({
    DateTime? from,
    DateTime? to,
    String? category,
    TransactionType? type,
    bool? onlyRecurring,
    String? searchQuery,
  }) async {
    return _expenses.where((e) {
      if (category != null && category != 'All' && e.category != category) return false;
      if (type != null && e.type != type) return false;
      return true;
    }).toList();
  }

  @override
  Future<ExpenseSummary> getSummary({
    DateTime? from,
    DateTime? to,
    String? category,
  }) async {
    return const ExpenseSummary(
      totalIncome: 1000,
      totalExpense: 500,
      netBalance: 500,
      monthlyExpense: 500,
      monthlyBudget: 1000,
      totalsByCategory: {'Food': 250.0, 'Shopping': 150.0, 'Bills': 100.0},
    );
  }

  @override
  Future<void> addExpense(Expense expense) async {}

  @override
  Future<void> deleteExpense(String id) async {}

  @override
  Future<void> updateExpense(Expense expense) async {}

  @override
  Future<double> getMonthlyBudget() async => 1000.0;

  @override
  Future<void> setMonthlyBudget(double budget) async {}

  @override
  Future<String?> getSecurityPin() async => null;

  @override
  Future<void> setSecurityPin(String? p) async {}

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
  Future<String?> getUserName() async => 'PieUser';

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
  Future<bool> isDrmProtectionEnabled() async => false;

  @override
  Future<void> setDrmProtectionEnabled(bool enabled) async {}

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

  
  String _appearanceMode = 'device';
  @override
  Future<String> getAppearanceMode() async => _appearanceMode;
  @override
  Future<void> setAppearanceMode(String mode) async => _appearanceMode = mode;

  @override
  Future<void> resetDatabase() async {}
}

class MockPieCategoryRepository implements CategoryRepository {
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
  testWidgets('CategoryPieChart invokes onCategoryTap when legend or section is tapped', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final repository = MockPieChartExpenseRepository();
    String? tappedCategory;

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<CurrencyCubit>(create: (_) => CurrencyCubit(repository)),
          BlocProvider<CategoryCubit>(create: (_) => CategoryCubit(categoryRepository: MockPieCategoryRepository())),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: CategoryPieChart(
              totalsByCategory: const {'Food': 250.0, 'Shopping': 150.0},
              totalAmount: 400.0,
              onCategoryTap: (cat) {
                tappedCategory = cat;
              },
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Food'), findsOneWidget);
    await tester.tap(find.text('Food'));
    await tester.pumpAndSettle();

    expect(tappedCategory, equals('Food'));
  });

  testWidgets('Tapping pie chart category navigates to Transactions tab with category pre-selected', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final repository = MockPieChartExpenseRepository();
    final categoryRepository = MockPieCategoryRepository();
    final getSummaryUseCase = GetSummaryUseCase(repository);
    final listExpensesUseCase = ListExpensesUseCase(repository);
    final deleteExpenseUseCase = DeleteExpenseUseCase(repository);

    late ExpenseListCubit expenseListCubit;

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<DashboardCubit>(
            create: (_) => DashboardCubit(
              getSummaryUseCase: getSummaryUseCase,
              listExpensesUseCase: listExpensesUseCase,
            )..loadDashboard(),
          ),
          BlocProvider<ExpenseListCubit>(
            create: (_) {
              expenseListCubit = ExpenseListCubit(
                listExpensesUseCase: listExpensesUseCase,
                deleteExpenseUseCase: deleteExpenseUseCase,
              )..loadExpenses();
              return expenseListCubit;
            },
          ),
          BlocProvider<CurrencyCubit>(
            create: (_) => CurrencyCubit(repository)..loadCurrency(),
          ),
          BlocProvider<CategoryCubit>(
            create: (_) => CategoryCubit(categoryRepository: categoryRepository)..loadCategories(),
          ),
        ],
        child: MaterialApp(
          home: MainNavigationScreen(repository: repository),
        ),
      ),
    );

    // Pump frames to load dashboard and resolve async _checkAppLock
    for (int i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 20));
    }
    await tester.pumpAndSettle();

    // Verify on Dashboard tab initially
    expect(find.text('Spending Breakdown'), findsOneWidget);
    expect(find.text('Food'), findsWidgets);

    // Tap on 'Food' in the pie chart breakdown legend
    final foodFinder = find.text('Food').first;
    await tester.tap(foodFinder);
    await tester.pumpAndSettle();

    // Verify ExpenseListCubit has 'Food' category pre-selected
    final state = expenseListCubit.state;
    expect(state, isA<ExpenseListLoaded>());
    expect((state as ExpenseListLoaded).selectedCategory, equals('Food'));

    // Verify screen has transitioned to Transactions tab
    expect(find.byType(ExpenseListScreen), findsOneWidget);
  });
}
