import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_101/domain/entities/expense.dart';
import 'package:flutter_application_101/domain/entities/category_item.dart';
import 'package:flutter_application_101/domain/entities/transaction_type.dart';
import 'package:flutter_application_101/domain/models/expense_summary.dart';
import 'package:flutter_application_101/domain/repositories/category_repository.dart';
import 'package:flutter_application_101/domain/repositories/expense_repository.dart';
import 'package:flutter_application_101/presentation/state/category/category_cubit.dart';
import 'package:flutter_application_101/presentation/state/currency/currency_cubit.dart';
import 'package:flutter_application_101/presentation/state/dashboard/dashboard_state.dart';
import 'package:flutter_application_101/presentation/theme/app_theme.dart';
import 'package:flutter_application_101/presentation/widgets/category_pie_chart.dart';

class MockBreakdownExpenseRepository implements ExpenseRepository {
  @override
  Future<String?> getSecurityPin() async => null;
  @override
  Future<void> setSecurityPin(String? pin) async {}
  @override
  Future<bool> isSecurityLockEnabled() async => false;
  @override
  Future<void> setSecurityLockEnabled(bool enabled) async {}
  @override
  Future<bool> isBiometricLockEnabled() async => false;
  @override
  Future<void> setBiometricLockEnabled(bool enabled) async {}
  @override
  Future<int> getAutoLockIntervalMinutes() async => 5;
  @override
  Future<void> setAutoLockIntervalMinutes(int minutes) async {}
  @override
  Future<int?> getLastActiveTimestamp() async => null;
  @override
  Future<void> setLastActiveTimestamp(int timestamp) async {}
  @override
  Future<bool> isDrmProtectionEnabled() async => false;
  @override
  Future<void> setDrmProtectionEnabled(bool enabled) async {}
  @override
  Future<bool> isHapticFeedbackEnabled() async => true;
  @override
  Future<void> setHapticFeedbackEnabled(bool enabled) async {}
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
  Future<double> getMonthlyBudget() async => 1000.0;
  @override
  Future<void> setMonthlyBudget(double budget) async {}
  @override
  Future<String?> getUserName() async => 'Test';
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

class MockBreakdownCategoryRepository implements CategoryRepository {
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
  TestWidgetsFlutterBinding.ensureInitialized();

  final now = DateTime.now();
  final sampleExpenses = [
    Expense(
      id: '1',
      amount: 5000.0,
      category: 'Salary',
      date: DateTime(now.year, now.month, 1, 10, 0),
      type: TransactionType.income,
      createdAt: now,
      updatedAt: now,
    ),
    Expense(
      id: '2',
      amount: 1500.0,
      category: 'Investments',
      date: DateTime(now.year, now.month, 2, 14, 0),
      type: TransactionType.income,
      createdAt: now,
      updatedAt: now,
    ),
    Expense(
      id: '3',
      amount: 300.0,
      category: 'Food',
      date: DateTime(now.year, now.month, 3, 18, 0),
      type: TransactionType.expense,
      createdAt: now,
      updatedAt: now,
    ),
    Expense(
      id: '4',
      amount: 1200.0,
      category: 'Housing',
      date: DateTime(now.year, now.month, 4, 9, 0),
      type: TransactionType.expense,
      createdAt: now,
      updatedAt: now,
    ),
    Expense(
      id: '5',
      amount: 3000.0,
      category: 'Salary',
      date: DateTime(2018, 6, 1),
      type: TransactionType.income,
      createdAt: now,
      updatedAt: now,
    ),
    Expense(
      id: '6',
      amount: 800.0,
      category: 'Food',
      date: DateTime(2018, 6, 2),
      type: TransactionType.expense,
      createdAt: now,
      updatedAt: now,
    ),
  ];

  final summary = ExpenseSummary.fromExpenses(sampleExpenses);

  Widget createTestWidget({
    DateFilterType filterType = DateFilterType.thisMonth,
    Function? onCategoryTap,
  }) {
    final repository = MockBreakdownExpenseRepository();
    final categoryRepository = MockBreakdownCategoryRepository();

    return MultiBlocProvider(
      providers: [
        BlocProvider<CurrencyCubit>(
          create: (_) => CurrencyCubit(repository)..loadCurrency(),
        ),
        BlocProvider<CategoryCubit>(
          create: (_) => CategoryCubit(categoryRepository: categoryRepository)..loadCategories(),
        ),
      ],
      child: MaterialApp(
        theme: AppTheme.darkTheme,
        home: Scaffold(
          body: SingleChildScrollView(
            child: CategoryPieChart(
              summary: summary,
              allPeriodExpenses: sampleExpenses,
              filterType: filterType,
              totalsByCategory: summary.expenseTotalsByCategory,
              totalAmount: summary.totalExpense,
              onCategoryTap: onCategoryTap,
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('Renders Pie graph initially and toggles between Pie and Line graphs', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // Verify Pie chart view is visible initially
    expect(find.text('Spending Breakdown'), findsOneWidget);
    expect(find.byType(PieChart), findsOneWidget);
    expect(find.byType(LineChart), findsNothing);
    expect(find.text('Pie'), findsOneWidget);
    expect(find.text('Line'), findsOneWidget);

    // Tap on Line toggle
    await tester.tap(find.text('Line'));
    await tester.pumpAndSettle();

    // Verify Line chart view is now rendered
    expect(find.text('Income & Expense Trends'), findsOneWidget);
    expect(find.byType(LineChart), findsOneWidget);
    expect(find.byType(PieChart), findsNothing);

    // Verify Line chart legend contains Income and Expense
    expect(find.text('Income'), findsOneWidget);
    expect(find.text('Expense'), findsOneWidget);

    // Tap back to Pie toggle
    await tester.tap(find.text('Pie'));
    await tester.pumpAndSettle();

    expect(find.text('Spending Breakdown'), findsOneWidget);
    expect(find.byType(PieChart), findsOneWidget);
  });

  testWidgets('Pie chart switches between Expense and Income modes and triggers onCategoryTap with correct type', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    String? tappedCategory;
    TransactionType? tappedType;

    await tester.pumpWidget(createTestWidget(
      onCategoryTap: (String cat, [TransactionType? type]) {
        tappedCategory = cat;
        tappedType = type;
      },
    ));
    await tester.pumpAndSettle();

    // In Expense mode initially
    expect(find.text('Spending Breakdown'), findsOneWidget);
    expect(find.text('Food'), findsOneWidget);
    expect(find.text('Housing'), findsOneWidget);
    expect(find.text('Salary'), findsNothing);

    // Tap on 'Food'
    await tester.tap(find.text('Food'));
    await tester.pumpAndSettle();

    expect(tappedCategory, equals('Food'));
    expect(tappedType, equals(TransactionType.expense));

    // Switch to Income mode
    await tester.tap(find.text('Income'));
    await tester.pumpAndSettle();

    // Now in Income mode
    expect(find.text('Income Breakdown'), findsOneWidget);
    expect(find.text('Salary'), findsOneWidget);
    expect(find.text('Investments'), findsOneWidget);
    expect(find.text('Housing'), findsNothing);

    // Tap on 'Salary'
    await tester.tap(find.text('Salary'));
    await tester.pumpAndSettle();

    expect(tappedCategory, equals('Salary'));
    expect(tappedType, equals(TransactionType.income));
  });

  testWidgets('All Time filter on Line Chart renders 10-year intervals with scrollable set buttons', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(createTestWidget(filterType: DateFilterType.all));
    await tester.pumpAndSettle();

    // Switch to Line chart
    await tester.tap(find.text('Line'));
    await tester.pumpAndSettle();

    expect(find.byType(LineChart), findsOneWidget);
    expect(find.text('10-Year Intervals'), findsOneWidget);

    // Expect Set 1 button
    expect(find.textContaining('Set 1'), findsOneWidget);

    // Tap on Set 1 button
    await tester.tap(find.textContaining('Set 1'));
    await tester.pumpAndSettle();

    expect(find.byType(LineChart), findsOneWidget);
  });
}
