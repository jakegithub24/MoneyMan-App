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
import 'package:flutter_application_101/presentation/utils/drm_protection_helper.dart';

class MockDrmExpenseRepository implements ExpenseRepository {
  String? _pin = '5678';
  bool _drmEnabled = false;

  @override
  Future<String?> getSecurityPin() async => _pin;

  @override
  Future<void> setSecurityPin(String? pin) async => _pin = pin;

  @override
  Future<bool> isSecurityLockEnabled() async => true;

  @override
  Future<void> setSecurityLockEnabled(bool enabled) async {}

  @override
  Future<bool> isBiometricLockEnabled() async => true;

  @override
  Future<void> setBiometricLockEnabled(bool enabled) async {}

  @override
  Future<int> getAutoLockIntervalMinutes() async => 1;

  @override
  Future<void> setAutoLockIntervalMinutes(int minutes) async {}

  @override
  Future<int?> getLastActiveTimestamp() async => null;

  @override
  Future<void> setLastActiveTimestamp(int timestamp) async {}

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
  Future<String?> getUserName() async => 'DrmUser';

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

  
  String _appearanceMode = 'device';
  @override
  Future<String> getAppearanceMode() async => _appearanceMode;
  @override
  Future<void> setAppearanceMode(String mode) async => _appearanceMode = mode;

  @override
  Future<void> resetDatabase() async {
    _drmEnabled = false;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final List<MethodCall> securityChannelCalls = [];

  setUp(() {
    securityChannelCalls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('com.example.flutter_application_101/security'),
      (MethodCall methodCall) async {
        securityChannelCalls.add(methodCall);
        return true;
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('com.example.flutter_application_101/security'),
      null,
    );
  });

  test('DrmProtectionHelper invokes setDrmProtection method on native channel', () async {
    await DrmProtectionHelper.setDrmProtection(true);
    expect(securityChannelCalls.length, equals(1));
    expect(securityChannelCalls.first.method, equals('setDrmProtection'));
    expect(securityChannelCalls.first.arguments, equals({'enabled': true}));

    await DrmProtectionHelper.setDrmProtection(false);
    expect(securityChannelCalls.length, equals(2));
    expect(securityChannelCalls.last.method, equals('setDrmProtection'));
    expect(securityChannelCalls.last.arguments, equals({'enabled': false}));
  });

  testWidgets('Enabling DRM protection activates immediately without PIN prompt', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final repository = MockDrmExpenseRepository();

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

    expect(await repository.isDrmProtectionEnabled(), isFalse);

    // Tap to enable
    await tester.tap(find.text('DRM Protection'));
    await tester.pumpAndSettle();

    // Verify DRM enabled without PIN screen
    expect(await repository.isDrmProtectionEnabled(), isTrue);
    expect(find.byType(SecurityPinScreen), findsNothing);
  });

  testWidgets('Disabling DRM protection requires PIN and completes on valid PIN entry', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final repository = MockDrmExpenseRepository();
    // Start with DRM enabled
    await repository.setDrmProtectionEnabled(true);

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

    expect(await repository.isDrmProtectionEnabled(), isTrue);

    // Tap to disable DRM
    await tester.tap(find.text('DRM Protection'));
    await tester.pumpAndSettle();

    // SecurityPinScreen must be pushed with biometrics excluded
    expect(find.byType(SecurityPinScreen), findsOneWidget);
    final pinScreen = tester.widget<SecurityPinScreen>(find.byType(SecurityPinScreen));
    expect(pinScreen.isBiometricEnabled, isFalse);

    // Enter correct PIN ('5678')
    await tester.tap(find.text('5'));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(find.text('6'));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(find.text('7'));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(find.text('8'));
    await tester.pumpAndSettle();

    // PIN matched, PIN screen popped, DRM is now disabled
    expect(find.byType(SecurityPinScreen), findsNothing);
    expect(await repository.isDrmProtectionEnabled(), isFalse);
  });
}
