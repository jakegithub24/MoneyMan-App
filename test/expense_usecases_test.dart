import 'package:flutter_application_101/application/use_cases/add_expense_usecase.dart';
import 'package:flutter_application_101/application/use_cases/delete_expense_usecase.dart';
import 'package:flutter_application_101/application/use_cases/get_summary_usecase.dart';
import 'package:flutter_application_101/application/use_cases/update_expense_usecase.dart';
import 'package:flutter_application_101/domain/entities/expense.dart';
import 'package:flutter_application_101/domain/entities/transaction_type.dart';
import 'package:flutter_application_101/domain/models/expense_summary.dart';
import 'package:flutter_application_101/domain/repositories/expense_repository.dart';
import 'package:flutter_application_101/presentation/state/expense_form/expense_form_cubit.dart';
import 'package:flutter_application_101/presentation/state/expense_form/expense_form_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

class InMemoryExpenseRepository implements ExpenseRepository {
  final List<Expense> _expenses = [];

  @override
  Future<void> addExpense(Expense expense) async {
    _expenses.removeWhere((e) => e.id == expense.id);
    _expenses.add(expense);
  }

  @override
  Future<void> updateExpense(Expense expense) async {
    final index = _expenses.indexWhere((e) => e.id == expense.id);
    if (index != -1) {
      _expenses[index] = expense;
    }
  }

  @override
  Future<void> deleteExpense(String id) async {
    _expenses.removeWhere((e) => e.id == id);
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
      if (type != null && e.type != type) return false;
      if (onlyRecurring == true && !e.isRecurring) return false;
      if (category != null && category.isNotEmpty && category != 'All') {
        if (e.category.toLowerCase() != category.toLowerCase()) return false;
      }
      if (from != null && e.date.isBefore(from)) return false;
      if (to != null && e.date.isAfter(to)) return false;
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final q = searchQuery.toLowerCase();
        final matchNote = (e.note ?? '').toLowerCase().contains(q);
        final matchCat = e.category.toLowerCase().contains(q);
        if (!matchNote && !matchCat) return false;
      }
      return true;
    }).toList();
  }

  @override
  Future<ExpenseSummary> getSummary({
    DateTime? from,
    DateTime? to,
    String? category,
  }) async {
    final list = await listExpenses(from: from, to: to, category: category);
    return ExpenseSummary.fromExpenses(list, monthlyBudget: _budget);
  }

  double _budget = 0.0;

  @override
  Future<double> getMonthlyBudget() async => _budget;

  @override
  Future<void> setMonthlyBudget(double budget) async {
    _budget = budget;
  }

  String? _securityPin;
  bool _lockEnabled = false;

  @override
  Future<String?> getSecurityPin() async => _securityPin;

  @override
  Future<void> setSecurityPin(String? pin) async => _securityPin = pin;

  bool _biometricLockEnabled = true;

  @override
  Future<bool> isSecurityLockEnabled() async => _lockEnabled;

  @override
  Future<void> setSecurityLockEnabled(bool enabled) async => _lockEnabled = enabled;

  @override
  Future<bool> isBiometricLockEnabled() async => _biometricLockEnabled;

  @override
  Future<void> setBiometricLockEnabled(bool enabled) async => _biometricLockEnabled = enabled;

  int _autoLockIntervalMinutes = 1;
  int? _lastActiveTimestamp;

  @override
  Future<int> getAutoLockIntervalMinutes() async => _autoLockIntervalMinutes;

  @override
  Future<void> setAutoLockIntervalMinutes(int minutes) async => _autoLockIntervalMinutes = minutes;

  @override
  Future<int?> getLastActiveTimestamp() async => _lastActiveTimestamp;

  @override
  Future<void> setLastActiveTimestamp(int timestamp) async => _lastActiveTimestamp = timestamp;

  String _currencyCode = 'INR';
  String _currencySymbol = '₹';

  @override
  Future<String> getCurrencyCode() async => _currencyCode;

  @override
  Future<String> getCurrencySymbol() async => _currencySymbol;

  @override
  Future<void> setCurrency(String code, String symbol) async {
    _currencyCode = code;
    _currencySymbol = symbol;
  }

  String? _userName;
  bool _onboardingCompleted = false;

  @override
  Future<String?> getUserName() async => _userName;

  @override
  Future<void> setUserName(String name) async => _userName = name;

  @override
  Future<bool> isOnboardingCompleted() async => _onboardingCompleted;

  @override
  Future<void> setOnboardingCompleted(bool completed) async => _onboardingCompleted = completed;

  @override
  Future<String> exportToCsv({
    TransactionType? type,
    DateTime? from,
    DateTime? to,
    String? category,
  }) async {
    final list = await listExpenses(type: type, from: from, to: to, category: category);
    final buffer = StringBuffer();
    buffer.writeln('ID,Type,Category,Amount,Date,Note,PaymentMethod,IsRecurring,RecurringInterval');
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
    for (final e in list) {
      buffer.writeln(
        '"${e.id}","${e.type.displayName}","${e.category}",${e.amount.toStringAsFixed(2)},"${dateFormat.format(e.date)}","${e.note ?? ''}","${e.paymentMethod ?? ''}",${e.isRecurring},"${e.recurringInterval.displayName}"',
      );
    }
    return buffer.toString();
  }

  @override
  Future<String> saveCsvToStorage(
    String csvData,
    String fileName, {
    String? targetDirectoryPath,
  }) async {
    final dir = targetDirectoryPath ?? '/tmp';
    return '$dir/$fileName';
  }

  @override
  Future<int> importFromCsv(String csvData) async {
    const invalidMsg = 'Invalid CSV, please upload CSV file Generated by MoneyMan app.';
    final lines = csvData.split(RegExp(r'\r?\n')).where((l) => l.trim().isNotEmpty).toList();
    if (lines.isEmpty) throw const FormatException(invalidMsg);

    final header = lines.first.split(',').map((s) => s.replaceAll('"', '').trim().toLowerCase()).toList();
    if (header.length < 9 || header[0] != 'id' || header[1] != 'type' || header[3] != 'amount') {
      throw const FormatException(invalidMsg);
    }

    int imported = 0;
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');

    for (var i = 1; i < lines.length; i++) {
      final parts = lines[i].split(',').map((s) => s.replaceAll('"', '').trim()).toList();
      if (parts.length < 9) throw const FormatException(invalidMsg);

      final id = parts[0];
      final rawType = parts[1].toLowerCase();
      if (rawType != 'expense' && rawType != 'income') throw const FormatException(invalidMsg);
      final type = rawType == 'income' ? TransactionType.income : TransactionType.expense;

      final category = parts[2];
      final amount = double.tryParse(parts[3]);
      if (amount == null || amount <= 0) throw const FormatException(invalidMsg);

      final rawDate = parts[4];
      final date = dateFormat.parseStrict(rawDate);
      final note = parts[5].isNotEmpty ? parts[5] : null;
      final paymentMethod = parts[6].isNotEmpty ? parts[6] : null;
      final isRecurring = parts[7].toLowerCase() == 'true';

      final now = DateTime.now();
      _expenses.add(Expense(
        id: id,
        amount: amount,
        category: category,
        date: date,
        type: type,
        isRecurring: isRecurring,
        recurringInterval: RecurringInterval.none,
        note: note,
        paymentMethod: paymentMethod,
        createdAt: now,
        updatedAt: now,
      ));
      imported++;
    }
    return imported;
  }

  @override
  Future<void> resetDatabase() async {
    _expenses.clear();
    _budget = 0.0;
    _currencyCode = 'INR';
    _currencySymbol = '₹';
    _securityPin = null;
    _lockEnabled = false;
    _autoLockIntervalMinutes = 1;
    _lastActiveTimestamp = null;
    _userName = null;
    _onboardingCompleted = false;
  }
}

void main() {
  group('MoneyMan Feature Tests', () {
    late InMemoryExpenseRepository repository;
    late AddExpenseUseCase addExpenseUseCase;
    late GetSummaryUseCase getSummaryUseCase;

    setUp(() {
      repository = InMemoryExpenseRepository();
      addExpenseUseCase = AddExpenseUseCase(repository);
      getSummaryUseCase = GetSummaryUseCase(repository);
    });

    test('Add Income and Expense calculates net balance correctly', () async {
      final now = DateTime.now();
      await addExpenseUseCase.execute(Expense(
        id: '1',
        amount: 2000.0,
        category: 'Salary',
        type: TransactionType.income,
        date: now,
        createdAt: now,
        updatedAt: now,
      ));
      await addExpenseUseCase.execute(Expense(
        id: '2',
        amount: 500.0,
        category: 'Food',
        type: TransactionType.expense,
        date: now,
        createdAt: now,
        updatedAt: now,
      ));

      final summary = await getSummaryUseCase.execute();
      expect(summary.totalIncome, equals(2000.0));
      expect(summary.totalExpense, equals(500.0));
      expect(summary.netBalance, equals(1500.0));
    });

    test('Budget limit setting and remaining budget computation', () async {
      await repository.setMonthlyBudget(1000.0);
      final now = DateTime.now();
      await addExpenseUseCase.execute(Expense(
        id: '1',
        amount: 300.0,
        category: 'Shopping',
        type: TransactionType.expense,
        date: now,
        createdAt: now,
        updatedAt: now,
      ));

      final summary = await getSummaryUseCase.execute();
      expect(summary.monthlyBudget, equals(1000.0));
    });

    test('Filter list by Income vs Expense vs Recurring', () async {
      final now = DateTime.now();
      await repository.addExpense(Expense(
        id: '1',
        amount: 100.0,
        category: 'Salary',
        type: TransactionType.income,
        isRecurring: true,
        date: now,
        createdAt: now,
        updatedAt: now,
      ));
      await repository.addExpense(Expense(
        id: '2',
        amount: 50.0,
        category: 'Food',
        type: TransactionType.expense,
        date: now,
        createdAt: now,
        updatedAt: now,
      ));

      final incomeOnly = await repository.listExpenses(type: TransactionType.income);
      expect(incomeOnly.length, equals(1));
      expect(incomeOnly.first.category, equals('Salary'));

      final recurringOnly = await repository.listExpenses(onlyRecurring: true);
      expect(recurringOnly.length, equals(1));
      expect(recurringOnly.first.id, equals('1'));
    });

    test('Filtered CSV export generation and file saving to storage', () async {
      final now = DateTime.now();
      await addExpenseUseCase.execute(Expense(
        id: '10',
        amount: 3000.0,
        category: 'Salary',
        type: TransactionType.income,
        date: now,
        createdAt: now,
        updatedAt: now,
      ));
      await addExpenseUseCase.execute(Expense(
        id: '11',
        amount: 150.0,
        category: 'Food',
        type: TransactionType.expense,
        date: now,
        createdAt: now,
        updatedAt: now,
      ));

      final incomeCsv = await repository.exportToCsv(type: TransactionType.income);
      expect(incomeCsv.contains('Salary'), isTrue);
      expect(incomeCsv.contains('Food'), isFalse);

      final filePath = await repository.saveCsvToStorage(incomeCsv, 'test_export.csv');
      expect(filePath, equals('/tmp/test_export.csv'));
    });

    test('PIN Security Lock setup and verification', () async {
      expect(await repository.isSecurityLockEnabled(), isFalse);
      await repository.setSecurityPin('1234');
      await repository.setSecurityLockEnabled(true);

      expect(await repository.isSecurityLockEnabled(), isTrue);
      expect(await repository.getSecurityPin(), equals('1234'));
    });

    test('CSV Import loads valid MoneyMan CSV data', () async {
      final validCsv = 'ID,Type,Category,Amount,Date,Note,PaymentMethod,IsRecurring,RecurringInterval\n'
          '"imp_1","Expense","Food",120.00,"2026-08-09 10:00:00","Dinner","Cash",false,"None"';

      final count = await repository.importFromCsv(validCsv);
      expect(count, equals(1));

      final list = await repository.listExpenses();
      expect(list.length, equals(1));
      expect(list.first.category, equals('Food'));
      expect(list.first.amount, equals(120.00));
    });

    test('CSV Import rejects invalid format with MoneyMan alert message', () async {
      final invalidCsv = 'Date,Description,Amount\n2026-08-09,Food,120.00';

      expect(
        () async => await repository.importFromCsv(invalidCsv),
        throwsA(isA<FormatException>().having(
          (e) => e.message,
          'message',
          equals('Invalid CSV, please upload CSV file Generated by MoneyMan app.'),
        )),
      );
    });

    test('Reset Database wipes all transaction data and resets settings to initial state', () async {
      final now = DateTime.now();
      await repository.addExpense(Expense(
        id: '99',
        amount: 500.0,
        category: 'Food',
        type: TransactionType.expense,
        date: now,
        createdAt: now,
        updatedAt: now,
      ));
      await repository.setUserName('Alex');
      await repository.setCurrency('USD', '\$');
      await repository.setMonthlyBudget(5000);
      await repository.setSecurityPin('9999');
      await repository.setSecurityLockEnabled(true);
      await repository.setOnboardingCompleted(true);

      await repository.resetDatabase();

      final list = await repository.listExpenses();
      expect(list, isEmpty);
      expect(await repository.getUserName(), isNull);
      expect(await repository.getMonthlyBudget(), equals(0.0));
      expect(await repository.getCurrencyCode(), equals('INR'));
      expect(await repository.getCurrencySymbol(), equals('₹'));
      expect(await repository.isSecurityLockEnabled(), isFalse);
      expect(await repository.getSecurityPin(), isNull);
      expect(await repository.isOnboardingCompleted(), isFalse);
    });

    test('User onboarding and username setting workflow', () async {
      expect(await repository.isOnboardingCompleted(), isFalse);
      expect(await repository.getUserName(), isNull);

      await repository.setUserName('Alex');
      await repository.setOnboardingCompleted(true);

      expect(await repository.isOnboardingCompleted(), isTrue);
      expect(await repository.getUserName(), equals('Alex'));

      // Database reset clears onboarding state & username
      await repository.resetDatabase();
      expect(await repository.isOnboardingCompleted(), isFalse);
      expect(await repository.getUserName(), isNull);
    });

    test('Future transaction date logging is disabled and rejected', () async {
      final futureDate = DateTime.now().add(const Duration(days: 5));
      final cubit = ExpenseFormCubit(
        addExpenseUseCase: addExpenseUseCase,
        updateExpenseUseCase: UpdateExpenseUseCase(repository),
        deleteExpenseUseCase: DeleteExpenseUseCase(repository),
      );

      await cubit.submitExpense(
        amount: 100.0,
        category: 'Food',
        date: futureDate,
        type: TransactionType.expense,
      );

      expect(cubit.state, isA<ExpenseFormError>());
      final errorState = cubit.state as ExpenseFormError;
      expect(errorState.message, contains('Future transaction dates are not allowed'));
    });
  });
}
