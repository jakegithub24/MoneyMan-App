import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/entities/expense.dart';
import '../../domain/entities/transaction_type.dart';

class ExpenseHiveDatasource {
  static const String boxName = 'expenses_box';
  static const String settingsBoxName = 'settings_box';

  Box<Map>? _box;
  Box? _settingsBox;

  Future<Box<Map>> get box async {
    if (_box != null && _box!.isOpen) {
      return _box!;
    }
    _box = await Hive.openBox<Map>(boxName);
    await _seedInitialDataIfNeeded(_box!);
    return _box!;
  }

  Future<Box> get settingsBox async {
    if (_settingsBox != null && _settingsBox!.isOpen) {
      return _settingsBox!;
    }
    _settingsBox = await Hive.openBox(settingsBoxName);
    return _settingsBox!;
  }

  Future<void> _seedInitialDataIfNeeded(Box<Map> box) async {
    if (box.isNotEmpty) return;

    final now = DateTime.now();
    final sampleExpenses = [
      Expense(
        id: '1',
        amount: 3500.00,
        category: 'Salary',
        type: TransactionType.income,
        date: now.subtract(const Duration(days: 7)),
        note: 'Monthly Salary Paycheck',
        paymentMethod: 'Bank Transfer',
        isRecurring: true,
        recurringInterval: RecurringInterval.monthly,
        createdAt: now.subtract(const Duration(days: 7)),
        updatedAt: now.subtract(const Duration(days: 7)),
      ),
      Expense(
        id: '2',
        amount: 450.00,
        category: 'Freelance',
        type: TransactionType.income,
        date: now.subtract(const Duration(days: 2)),
        note: 'UI Design Contract',
        paymentMethod: 'UPI / Digital Wallet',
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now.subtract(const Duration(days: 2)),
      ),
      Expense(
        id: '3',
        amount: 145.50,
        category: 'Food',
        type: TransactionType.expense,
        date: now.subtract(const Duration(hours: 3)),
        note: 'Supermarket Groceries',
        paymentMethod: 'Credit Card',
        createdAt: now.subtract(const Duration(hours: 3)),
        updatedAt: now.subtract(const Duration(hours: 3)),
      ),
      Expense(
        id: '4',
        amount: 15.00,
        category: 'Transport',
        type: TransactionType.expense,
        date: now.subtract(const Duration(days: 1)),
        note: 'City Metro Pass',
        paymentMethod: 'UPI / Digital Wallet',
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
      Expense(
        id: '5',
        amount: 89.99,
        category: 'Shopping',
        type: TransactionType.expense,
        date: now.subtract(const Duration(days: 3)),
        note: 'Running Shoes Sale',
        paymentMethod: 'Credit Card',
        createdAt: now.subtract(const Duration(days: 3)),
        updatedAt: now.subtract(const Duration(days: 3)),
      ),
      Expense(
        id: '6',
        amount: 120.00,
        category: 'Utilities',
        type: TransactionType.expense,
        date: now.subtract(const Duration(days: 5)),
        note: 'Electricity Bill',
        paymentMethod: 'Bank Transfer',
        isRecurring: true,
        recurringInterval: RecurringInterval.monthly,
        createdAt: now.subtract(const Duration(days: 5)),
        updatedAt: now.subtract(const Duration(days: 5)),
      ),
      Expense(
        id: '7',
        amount: 28.75,
        category: 'Entertainment',
        type: TransactionType.expense,
        date: now.subtract(const Duration(days: 6)),
        note: 'Movie Cinema Tickets',
        paymentMethod: 'Cash',
        createdAt: now.subtract(const Duration(days: 6)),
        updatedAt: now.subtract(const Duration(days: 6)),
      ),
    ];

    for (final exp in sampleExpenses) {
      await box.put(exp.id, exp.toMap());
    }

    // Default monthly budget & currency
    final sBox = await settingsBox;
    await sBox.put('monthly_budget', 1500.0);
    await sBox.put('currency_code', 'INR');
    await sBox.put('currency_symbol', '₹');
  }

  Future<void> addExpense(Expense expense) async {
    final b = await box;
    await b.put(expense.id, expense.toMap());
  }

  Future<void> updateExpense(Expense expense) async {
    final b = await box;
    await b.put(expense.id, expense.toMap());
  }

  Future<void> deleteExpense(String id) async {
    final b = await box;
    await b.delete(id);
  }

  Future<void> deleteAllExpenses() async {
    final b = await box;
    await b.clear();
  }

  Future<List<Expense>> getAllExpenses() async {
    final b = await box;
    final list = <Expense>[];
    for (var i = 0; i < b.length; i++) {
      final val = b.getAt(i);
      if (val != null) {
        try {
          final map = Map<String, dynamic>.from(val);
          list.add(Expense.fromMap(map));
        } catch (_) {}
      }
    }
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  Future<double> getMonthlyBudget() async {
    final sBox = await settingsBox;
    return (sBox.get('monthly_budget', defaultValue: 1500.0) as num).toDouble();
  }

  Future<void> setMonthlyBudget(double budget) async {
    final sBox = await settingsBox;
    await sBox.put('monthly_budget', budget);
  }

  Future<String?> getSecurityPin() async {
    final sBox = await settingsBox;
    return sBox.get('security_pin') as String?;
  }

  Future<void> setSecurityPin(String? pin) async {
    final sBox = await settingsBox;
    if (pin == null) {
      await sBox.delete('security_pin');
    } else {
      await sBox.put('security_pin', pin);
    }
  }

  Future<bool> isSecurityLockEnabled() async {
    final sBox = await settingsBox;
    return sBox.get('security_lock_enabled', defaultValue: false) as bool;
  }

  Future<void> setSecurityLockEnabled(bool enabled) async {
    final sBox = await settingsBox;
    await sBox.put('security_lock_enabled', enabled);
  }

  Future<String> getCurrencyCode() async {
    final sBox = await settingsBox;
    return sBox.get('currency_code', defaultValue: 'INR') as String;
  }

  Future<String> getCurrencySymbol() async {
    final sBox = await settingsBox;
    return sBox.get('currency_symbol', defaultValue: '₹') as String;
  }

  Future<void> setCurrency(String code, String symbol) async {
    final sBox = await settingsBox;
    await sBox.put('currency_code', code);
    await sBox.put('currency_symbol', symbol);
  }

  Future<void> resetDatabase() async {
    final b = await box;
    await b.clear();

    final sBox = await settingsBox;
    await sBox.clear();
    await sBox.put('monthly_budget', 1500.0);
    await sBox.put('currency_code', 'INR');
    await sBox.put('currency_symbol', '₹');
    await sBox.put('security_lock_enabled', false);
  }
}
