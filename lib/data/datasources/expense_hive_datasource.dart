import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/entities/expense.dart';

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
    // Fresh init database starts with 0 transactions and default settings
    final sBox = await settingsBox;
    if (!sBox.containsKey('currency_code')) {
      await sBox.put('monthly_budget', 0.0);
      await sBox.put('currency_code', 'INR');
      await sBox.put('currency_symbol', '₹');
      await sBox.put('security_lock_enabled', false);
      await sBox.put('auto_lock_interval_minutes', 1);
      await sBox.put('onboarding_completed', false);
    }
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
    return (sBox.get('monthly_budget', defaultValue: 0.0) as num).toDouble();
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

  Future<bool> isBiometricLockEnabled() async {
    final sBox = await settingsBox;
    return sBox.get('biometric_lock_enabled', defaultValue: true) as bool;
  }

  Future<void> setBiometricLockEnabled(bool enabled) async {
    final sBox = await settingsBox;
    await sBox.put('biometric_lock_enabled', enabled);
  }

  Future<int> getAutoLockIntervalMinutes() async {
    final sBox = await settingsBox;
    return sBox.get('auto_lock_interval_minutes', defaultValue: 1) as int;
  }

  Future<void> setAutoLockIntervalMinutes(int minutes) async {
    final sBox = await settingsBox;
    await sBox.put('auto_lock_interval_minutes', minutes);
  }

  Future<int?> getLastActiveTimestamp() async {
    final sBox = await settingsBox;
    return sBox.get('last_active_timestamp') as int?;
  }

  Future<void> setLastActiveTimestamp(int timestamp) async {
    final sBox = await settingsBox;
    await sBox.put('last_active_timestamp', timestamp);
  }

  Future<bool> isHapticFeedbackEnabled() async {
    final sBox = await settingsBox;
    return sBox.get('haptic_feedback_enabled', defaultValue: true) as bool;
  }

  Future<void> setHapticFeedbackEnabled(bool enabled) async {
    final sBox = await settingsBox;
    await sBox.put('haptic_feedback_enabled', enabled);
  }

  Future<String> getCurrencyCode() async {
    final sBox = await settingsBox;
    final val = sBox.get('currency_code');
    if (val == null || val is! String || val.trim().isEmpty) {
      return 'INR';
    }
    return val.trim();
  }

  Future<String> getCurrencySymbol() async {
    final sBox = await settingsBox;
    final val = sBox.get('currency_symbol');
    if (val == null || val is! String || val.trim().isEmpty) {
      return '₹';
    }
    return val.trim();
  }

  Future<void> setCurrency(String code, String symbol) async {
    final sBox = await settingsBox;
    await sBox.put('currency_code', code);
    await sBox.put('currency_symbol', symbol);
  }

  Future<String?> getUserName() async {
    final sBox = await settingsBox;
    final val = sBox.get('user_name');
    if (val == null || val is! String || val.trim().isEmpty) {
      return null;
    }
    return val.trim();
  }

  Future<void> setUserName(String name) async {
    final sBox = await settingsBox;
    await sBox.put('user_name', name);
  }

  Future<bool> isOnboardingCompleted() async {
    final sBox = await settingsBox;
    return sBox.get('onboarding_completed', defaultValue: false) as bool;
  }

  Future<void> setOnboardingCompleted(bool completed) async {
    final sBox = await settingsBox;
    await sBox.put('onboarding_completed', completed);
  }

  Future<void> resetDatabase() async {
    final b = await box;
    await b.clear();

    final sBox = await settingsBox;
    await sBox.clear();
    await sBox.put('monthly_budget', 0.0);
    await sBox.put('currency_code', 'INR');
    await sBox.put('currency_symbol', '₹');
    await sBox.put('security_lock_enabled', false);
    await sBox.put('biometric_lock_enabled', true);
    await sBox.put('haptic_feedback_enabled', true);
    await sBox.put('auto_lock_interval_minutes', 1);
    await sBox.delete('last_active_timestamp');
    await sBox.put('onboarding_completed', false);
  }
}
