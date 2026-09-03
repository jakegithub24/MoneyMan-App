import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_101/domain/repositories/expense_repository.dart';
import 'package:flutter_application_101/domain/models/expense_summary.dart';
import 'package:flutter_application_101/domain/entities/expense.dart';
import 'package:flutter_application_101/domain/entities/transaction_type.dart';
import 'package:flutter_application_101/presentation/theme/app_theme.dart';
import 'package:flutter_application_101/presentation/screens/settings_screen.dart';
import 'package:flutter_application_101/presentation/state/currency/currency_cubit.dart';
import 'package:flutter_application_101/presentation/state/theme/theme_cubit.dart';

class MockAppearanceExpenseRepository implements ExpenseRepository {
  String _appearanceMode = 'device';
  String _username = 'Alex';
  double _budget = 2000.0;
  bool _lockEnabled = false;
  bool _biometricEnabled = true;
  bool _hapticEnabled = true;
  bool _drmEnabled = false;

  @override
  Future<String> getAppearanceMode() async => _appearanceMode;

  @override
  Future<void> setAppearanceMode(String mode) async {
    _appearanceMode = mode;
  }

  @override
  Future<String?> getUserName() async => _username;

  @override
  Future<void> setUserName(String name) async {
    _username = name;
  }

  @override
  Future<double> getMonthlyBudget() async => _budget;

  @override
  Future<void> setMonthlyBudget(double budget) async {
    _budget = budget;
  }

  @override
  Future<bool> isSecurityLockEnabled() async => _lockEnabled;

  @override
  Future<void> setSecurityLockEnabled(bool enabled) async {
    _lockEnabled = enabled;
  }

  @override
  Future<bool> isBiometricLockEnabled() async => _biometricEnabled;

  @override
  Future<void> setBiometricLockEnabled(bool enabled) async {
    _biometricEnabled = enabled;
  }

  @override
  Future<bool> isHapticFeedbackEnabled() async => _hapticEnabled;

  @override
  Future<void> setHapticFeedbackEnabled(bool enabled) async {
    _hapticEnabled = enabled;
  }

  @override
  Future<bool> isDrmProtectionEnabled() async => _drmEnabled;

  @override
  Future<void> setDrmProtectionEnabled(bool enabled) async {
    _drmEnabled = enabled;
  }

  @override
  Future<String> getCurrencyCode() async => 'INR';

  @override
  Future<String> getCurrencySymbol() async => '₹';

  @override
  Future<void> setCurrency(String code, String symbol) async {}

  @override
  Future<String?> getSecurityPin() async => null;

  @override
  Future<void> setSecurityPin(String? pin) async {}

  @override
  Future<int> getAutoLockIntervalMinutes() async => 1;

  @override
  Future<void> setAutoLockIntervalMinutes(int minutes) async {}

  @override
  Future<int?> getLastActiveTimestamp() async => null;

  @override
  Future<void> setLastActiveTimestamp(int timestamp) async {}

  @override
  Future<bool> isOnboardingCompleted() async => true;

  @override
  Future<void> setOnboardingCompleted(bool completed) async {}

  @override
  Future<void> addExpense(Expense expense) async {}

  @override
  Future<void> updateExpense(Expense expense) async {}

  @override
  Future<void> deleteExpense(String id) async {}

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
  Future<String> exportToCsv({
    TransactionType? type,
    DateTime? from,
    DateTime? to,
    String? category,
  }) async => '';

  @override
  Future<String> saveCsvToStorage(String csvData, String fileName, {String? targetDirectoryPath}) async => '';

  @override
  Future<int> importFromCsv(String csvData) async => 0;

  @override
  Future<void> resetDatabase() async {}
}

void main() {
  group('Appearance & Theme Tests', () {
    test('AppTheme defines correct palette specifications', () {
      // Light theme: card is white, screen is subtle white (not pure #fff), text is dark
      expect(AppTheme.lightCardBackgroundColor, const Color(0xFFFFFFFF));
      expect(AppTheme.lightBackgroundColor, const Color(0xFFF6F8F6));
      expect(AppTheme.lightTextColor, const Color(0xFF131313));

      // Subtle white constant
      expect(AppTheme.subtleWhite, const Color(0xFFEEE9D9));

      // Dark theme: card is #1F271C, screen is #131313, text is subtle white #EEE9D9
      expect(AppTheme.darkBackgroundColor, const Color(0xFF131313));
      expect(AppTheme.darkCardBackgroundColor, const Color(0xFF1F271C));
      expect(AppTheme.darkTextColor, const Color(0xFFEEE9D9));

      // Light ThemeData and Dark ThemeData properties
      expect(AppTheme.lightTheme.brightness, Brightness.light);
      expect(AppTheme.lightTheme.scaffoldBackgroundColor, AppTheme.lightBackgroundColor);
      expect(AppTheme.lightTheme.cardTheme.color, AppTheme.lightCardBackgroundColor);

      expect(AppTheme.darkTheme.brightness, Brightness.dark);
      expect(AppTheme.darkTheme.scaffoldBackgroundColor, AppTheme.darkBackgroundColor);
      expect(AppTheme.darkTheme.cardTheme.color, AppTheme.darkCardBackgroundColor);
    });

    test('ThemeCubit correctly loads, parses, and sets theme modes', () async {
      final repository = MockAppearanceExpenseRepository();
      final cubit = ThemeCubit(repository);

      await cubit.loadTheme();
      expect(cubit.state, ThemeMode.system);

      await cubit.setThemeMode(ThemeMode.light);
      expect(cubit.state, ThemeMode.light);
      expect(await repository.getAppearanceMode(), 'light');

      await cubit.setThemeMode(ThemeMode.dark);
      expect(cubit.state, ThemeMode.dark);
      expect(await repository.getAppearanceMode(), 'dark');

      await cubit.setThemeMode(ThemeMode.system);
      expect(cubit.state, ThemeMode.system);
      expect(await repository.getAppearanceMode(), 'device');
    });

    testWidgets('SettingsScreen displays Appearance tile and opens selection dialog with Device, Light, Dark', (tester) async {
      final repository = MockAppearanceExpenseRepository();
      final themeCubit = ThemeCubit(repository);
      final currencyCubit = CurrencyCubit(repository);

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<ThemeCubit>.value(value: themeCubit),
            BlocProvider<CurrencyCubit>.value(value: currencyCubit),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.system,
            home: SettingsScreen(
              repository: repository,
              onSettingsUpdated: () {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify Appearance tile exists
      expect(find.text('Appearance'), findsOneWidget);
      expect(find.text('Theme: Device'), findsOneWidget);

      // Tap Appearance tile
      await tester.tap(find.text('Appearance'));
      await tester.pumpAndSettle();

      // Verify Appearance dialog opens with Device, Light, Dark options
      expect(find.text('Device'), findsOneWidget);
      expect(find.text('Match device system setting'), findsOneWidget);
      expect(find.text('Light'), findsOneWidget);
      expect(find.text('Clean light theme'), findsOneWidget);
      expect(find.text('Dark'), findsOneWidget);
      expect(find.text('Classic dark vault theme'), findsOneWidget);

      // Select 'Light'
      await tester.tap(find.text('Light'));
      await tester.pumpAndSettle();

      expect(themeCubit.state, ThemeMode.light);
      expect(await repository.getAppearanceMode(), 'light');
      expect(find.text('Theme: Light'), findsOneWidget);

      // Tap Appearance again and select 'Dark'
      await tester.tap(find.text('Appearance'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Dark'));
      await tester.pumpAndSettle();

      expect(themeCubit.state, ThemeMode.dark);
      expect(await repository.getAppearanceMode(), 'dark');
      expect(find.text('Theme: Dark'), findsOneWidget);
    });
  });
}
