import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_101/domain/repositories/expense_repository.dart';
import 'package:flutter_application_101/domain/models/expense_summary.dart';
import 'package:flutter_application_101/domain/entities/expense.dart';
import 'package:flutter_application_101/domain/entities/transaction_type.dart';
import 'package:flutter_application_101/presentation/theme/app_theme.dart';
import 'package:flutter_application_101/presentation/screens/security_settings_screen.dart';
import 'package:flutter_application_101/presentation/screens/security_pin_screen.dart';

class MockSecurityExpenseRepository implements ExpenseRepository {
  String? _pin = '1234';
  bool _lockEnabled = true;
  bool _bioEnabled = false;
  int _interval = 1;

  @override
  Future<String?> getSecurityPin() async => _pin;

  @override
  Future<void> setSecurityPin(String? pin) async {
    _pin = pin;
  }

  @override
  Future<bool> isSecurityLockEnabled() async => _lockEnabled;

  @override
  Future<void> setSecurityLockEnabled(bool enabled) async {
    _lockEnabled = enabled;
  }

  @override
  Future<bool> isBiometricLockEnabled() async => _bioEnabled;

  @override
  Future<void> setBiometricLockEnabled(bool enabled) async {
    _bioEnabled = enabled;
  }

  @override
  Future<int> getAutoLockIntervalMinutes() async => _interval;

  @override
  Future<void> setAutoLockIntervalMinutes(int minutes) async {
    _interval = minutes;
  }

  @override
  Future<int?> getLastActiveTimestamp() async => null;

  @override
  Future<void> setLastActiveTimestamp(int timestamp) async {}

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

  bool _drmEnabled = false;

  @override
  Future<bool> isDrmProtectionEnabled() async => _drmEnabled;

  @override
  Future<void> setDrmProtectionEnabled(bool enabled) async {
    _drmEnabled = enabled;
  }

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

  
  String _appearanceMode = 'device';
  @override
  Future<String> getAppearanceMode() async => _appearanceMode;
  @override
  Future<void> setAppearanceMode(String mode) async => _appearanceMode = mode;

  @override
  Future<void> resetDatabase() async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('com.example.flutter_application_101/security'),
      (MethodCall methodCall) async => true,
    );
  });

  testWidgets('SecuritySettingsScreen displays password icon before Change Security PIN with matching theme color', (tester) async {
    final repository = MockSecurityExpenseRepository();

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: SecuritySettingsScreen(
          repository: repository,
          onSettingsUpdated: () {},
        ),
      ),
    );

    // Pump frames to resolve async _loadSettings
    for (int i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 20));
    }

    expect(find.text('Change Security PIN'), findsOneWidget);

    final passwordIconFinder = find.byIcon(Icons.password_rounded);
    expect(passwordIconFinder, findsOneWidget);

    final Icon iconWidget = tester.widget(passwordIconFinder);
    expect(iconWidget.color, equals(AppTheme.baseHighlightColor));
  });

  testWidgets('SecuritySettingsScreen displays lock_clock icon before Auto-Lock Interval', (tester) async {
    final repository = MockSecurityExpenseRepository();

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: SecuritySettingsScreen(
          repository: repository,
          onSettingsUpdated: () {},
        ),
      ),
    );

    // Pump frames to resolve async _loadSettings
    for (int i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 20));
    }

    expect(find.text('Auto-Lock Interval'), findsOneWidget);

    final lockClockIconFinder = find.byIcon(Icons.lock_clock_rounded);
    expect(lockClockIconFinder, findsOneWidget);

    final Icon iconWidget = tester.widget(lockClockIconFinder);
    expect(iconWidget.color, equals(AppTheme.incomeColor));
  });

  testWidgets('DRM Protection can be enabled without PIN and requires PIN to disable', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final repository = MockSecurityExpenseRepository();

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: SecuritySettingsScreen(
          repository: repository,
          onSettingsUpdated: () {},
        ),
      ),
    );

    for (int i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 20));
    }

    // Scroll to DRM Protection toggle
    final drmTitle = find.text('DRM Protection');
    await tester.scrollUntilVisible(drmTitle, 100);
    expect(drmTitle, findsOneWidget);

    // Initially DRM is disabled
    expect(await repository.isDrmProtectionEnabled(), isFalse);

    // Tap DRM Protection tile to ENABLE
    await tester.tap(find.text('DRM Protection'));
    await tester.pumpAndSettle();

    // DRM enabled directly WITHOUT opening PIN screen
    expect(await repository.isDrmProtectionEnabled(), isTrue);

    // Dismiss any SnackBars that might intercept taps
    ScaffoldMessenger.of(tester.element(find.byType(SecuritySettingsScreen))).clearSnackBars();
    await tester.pumpAndSettle();

    // Now tap to DISABLE -> must navigate to SecurityPinScreen (with biometrics disabled)
    await tester.tap(find.text('DRM Protection'));
    await tester.pumpAndSettle();

    expect(find.text('Enter Security PIN'), findsOneWidget);
    expect(find.byType(SecurityPinScreen), findsOneWidget);
  });
}


