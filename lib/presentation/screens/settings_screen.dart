import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/expense_repository.dart';
import '../state/category/category_cubit.dart';
import '../state/currency/currency_cubit.dart';
import '../state/currency/currency_state.dart';
import '../state/dashboard/dashboard_cubit.dart';
import '../state/expense_list/expense_list_cubit.dart';
import '../state/theme/theme_cubit.dart';
import '../theme/app_theme.dart';
import '../utils/app_haptics.dart';
import '../utils/currency_formatter.dart';
import '../utils/storage_permission_helper.dart';
import '../widgets/export_data_dialog.dart';
import '../widgets/import_data_dialog.dart';
import 'categories_screen.dart';
import 'main_navigation_screen.dart';
import 'onboarding_screen.dart';
import 'security_pin_screen.dart';
import 'security_settings_screen.dart';

class SettingsScreen extends StatefulWidget {
  final ExpenseRepository repository;
  final VoidCallback onSettingsUpdated;

  const SettingsScreen({
    super.key,
    required this.repository,
    required this.onSettingsUpdated,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _currentUsername = 'User';
  double _currentBudget = 0.0;
  bool _isLockEnabled = false;
  bool _isBiometricEnabled = true;
  bool _isHapticEnabled = true;
  String _appearanceMode = 'device';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final username = await widget.repository.getUserName();
    final budget = await widget.repository.getMonthlyBudget();
    final lockEnabled = await widget.repository.isSecurityLockEnabled();
    final biometricEnabled = await widget.repository.isBiometricLockEnabled();
    final hapticEnabled = await widget.repository.isHapticFeedbackEnabled();
    final appearance = await widget.repository.getAppearanceMode();
    AppHaptics.isEnabled = hapticEnabled;
    setState(() {
      _currentUsername = (username != null && username.trim().isNotEmpty) ? username.trim() : 'User';
      _currentBudget = budget;
      _isLockEnabled = lockEnabled;
      _isBiometricEnabled = biometricEnabled;
      _isHapticEnabled = hapticEnabled;
      _appearanceMode = appearance;
    });
  }

  Future<void> _toggleHapticFeedback(bool enabled) async {
    await widget.repository.setHapticFeedbackEnabled(enabled);
    AppHaptics.isEnabled = enabled;
    if (enabled) {
      AppHaptics.lightImpact();
    }
    await _loadSettings();
  }

  String _getAppearanceLabel(String mode) {
    switch (mode.toLowerCase()) {
      case 'light':
        return 'Light';
      case 'dark':
        return 'Dark';
      case 'device':
      default:
        return 'Device';
    }
  }

  Future<void> _selectAppearanceDialog() async {
    final themeCubit = context.read<ThemeCubit>();
    final currentMode = ThemeCubit.parseThemeMode(_appearanceMode);

    final selected = await showDialog<ThemeMode>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardBackgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.baseHighlightColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.palette_rounded, color: AppTheme.baseHighlightColor, size: 22),
            ),
            const SizedBox(width: 12),
            Text(
              'Appearance',
              style: TextStyle(
                color: AppTheme.textColor,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildAppearanceOption(
              ctx,
              mode: ThemeMode.system,
              title: 'Device',
              subtitle: 'Match device system setting',
              icon: Icons.phone_android_rounded,
              isSelected: currentMode == ThemeMode.system,
            ),
            const SizedBox(height: 8),
            _buildAppearanceOption(
              ctx,
              mode: ThemeMode.light,
              title: 'Light',
              subtitle: 'Clean light theme',
              icon: Icons.light_mode_rounded,
              isSelected: currentMode == ThemeMode.light,
            ),
            const SizedBox(height: 8),
            _buildAppearanceOption(
              ctx,
              mode: ThemeMode.dark,
              title: 'Dark',
              subtitle: 'Classic dark vault theme',
              icon: Icons.dark_mode_rounded,
              isSelected: currentMode == ThemeMode.dark,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Close', style: TextStyle(color: AppTheme.textColor)),
          ),
        ],
      ),
    );

    if (selected != null) {
      AppHaptics.selectionClick();
      await themeCubit.setThemeMode(selected);
      await _loadSettings();
      widget.onSettingsUpdated();
    }
  }

  Widget _buildAppearanceOption(
    BuildContext dialogCtx, {
    required ThemeMode mode,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.pop(dialogCtx, mode),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.baseHighlightColor.withValues(alpha: 0.15)
                : AppTheme.backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? AppTheme.baseHighlightColor
                  : AppTheme.textColor.withValues(alpha: 0.15),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected ? AppTheme.baseHighlightColor : AppTheme.textColor,
                size: 24,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: isSelected ? AppTheme.baseHighlightColor : AppTheme.textColor,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: AppTheme.textColor.withValues(alpha: 0.7),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                const Icon(Icons.check_circle_rounded, color: AppTheme.baseHighlightColor, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _updateUsernameDialog() async {
    final controller = TextEditingController(text: _currentUsername);
    String? errorText;

    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppTheme.cardBackgroundColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Update Username', style: TextStyle(color: AppTheme.textColor, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enter username (A-Z, a-z, 0-9, _, max 10 chars):',
                style: TextStyle(color: AppTheme.textColor, fontSize: 13),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                maxLength: 10,
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9_]'))],
                style: TextStyle(color: AppTheme.textColor, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.person_outline_rounded, color: AppTheme.baseHighlightColor),
                  hintText: 'e.g. Alex_99',
                  errorText: errorText,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel', style: TextStyle(color: AppTheme.textColor)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.baseHighlightColor,
                foregroundColor: AppTheme.backgroundColor,
              ),
              onPressed: () {
                final name = controller.text.trim();
                if (name.isEmpty) {
                  setDialogState(() {
                    errorText = 'Name cannot be empty';
                  });
                  return;
                }
                if (RegExp(r'^[_0-9]').hasMatch(name)) {
                  setDialogState(() {
                    errorText = 'Username must not start with number or underscore';
                  });
                  return;
                }
                final validPattern = RegExp(r'^[a-zA-Z][a-zA-Z0-9_]{0,9}$');
                if (!validPattern.hasMatch(name)) {
                  if (name.length > 10) {
                    setDialogState(() {
                      errorText = 'Name cannot exceed 10 characters';
                    });
                  } else {
                    setDialogState(() {
                      errorText = 'Only letters, numbers, and underscores allowed';
                    });
                  }
                  return;
                }
                Navigator.pop(ctx, name);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );

    if (result != null && result.isNotEmpty) {
      await widget.repository.setUserName(result);
      await _loadSettings();
      widget.onSettingsUpdated();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Username updated to "$result"', style: TextStyle(color: AppTheme.textColor)),
            backgroundColor: AppTheme.cardBackgroundColor,
          ),
        );
      }
    }
  }

  Future<void> _setBudgetDialog() async {
    final currencySymbol = context.read<CurrencyCubit>().state.currency.symbol;
    final controller = TextEditingController(text: _currentBudget.toStringAsFixed(0));
    final result = await showDialog<double>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardBackgroundColor,
        title: Text('Set Monthly Budget', style: TextStyle(color: AppTheme.textColor)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter your target monthly spending limit:',
              style: TextStyle(color: AppTheme.textColor, fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: TextStyle(color: AppTheme.textColor, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    currencySymbol,
                    style: const TextStyle(
                      color: AppTheme.baseHighlightColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
                hintText: 'e.g. 1500',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: AppTheme.textColor)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.baseHighlightColor,
              foregroundColor: AppTheme.backgroundColor,
            ),
            onPressed: () {
              final val = double.tryParse(controller.text.trim());
              if (val != null && val >= 0) {
                Navigator.pop(ctx, val);
              }
            },
            child: const Text('Save Budget'),
          ),
        ],
      ),
    );

    if (result != null) {
      await widget.repository.setMonthlyBudget(result);
      await _loadSettings();
      widget.onSettingsUpdated();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        title: Text(
          'Settings & Tools',
          style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textColor),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile Section
          _buildSectionHeader('USER PROFILE'),
          Card(
            color: AppTheme.cardBackgroundColor,
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.baseHighlightColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.person_outline_rounded, color: AppTheme.baseHighlightColor),
              ),
              title: Text(
                'Update Username',
                style: TextStyle(color: AppTheme.textColor, fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                'Current: $_currentUsername',
                style: TextStyle(color: AppTheme.textColor, fontSize: 12),
              ),
              trailing: Icon(Icons.chevron_right_rounded, color: AppTheme.textColor),
              onTap: _updateUsernameDialog,
            ),
          ),
          const SizedBox(height: 24),

          // Preferences Section
          _buildSectionHeader('PREFERENCES'),
          Card(
            color: AppTheme.cardBackgroundColor,
            child: Column(
              children: [
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.baseHighlightColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.palette_rounded, color: AppTheme.baseHighlightColor),
                  ),
                  title: Text(
                    'Appearance',
                    style: TextStyle(color: AppTheme.textColor, fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    'Theme: ${_getAppearanceLabel(_appearanceMode)}',
                    style: TextStyle(color: AppTheme.textColor, fontSize: 12),
                  ),
                  trailing: Icon(Icons.chevron_right_rounded, color: AppTheme.textColor),
                  onTap: () {
                    AppHaptics.lightImpact();
                    _selectAppearanceDialog();
                  },
                ),
                Divider(color: AppTheme.backgroundColor, height: 1),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.baseHighlightColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.category_rounded, color: AppTheme.baseHighlightColor),
                  ),
                  title: Text(
                    'Manage Categories',
                    style: TextStyle(color: AppTheme.textColor, fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    'Create or delete income and expense categories',
                    style: TextStyle(color: AppTheme.textColor, fontSize: 12),
                  ),
                  trailing: Icon(Icons.chevron_right_rounded, color: AppTheme.textColor),
                  onTap: () {
                    AppHaptics.lightImpact();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CategoriesScreen()),
                    );
                  },
                ),
                Divider(color: AppTheme.backgroundColor, height: 1),
                SwitchListTile(
                  secondary: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.popHighlightColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.vibration_rounded, color: AppTheme.popHighlightColor),
                  ),
                  title: Text(
                    'Haptic Feedback',
                    style: TextStyle(color: AppTheme.textColor, fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    'Vibrate on button taps, keypad entry, & actions',
                    style: TextStyle(color: AppTheme.textColor, fontSize: 12),
                  ),
                  value: _isHapticEnabled,
                  activeThumbColor: AppTheme.baseHighlightColor,
                  onChanged: _toggleHapticFeedback,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Budget Section
          _buildSectionHeader('FINANCIAL GOALS'),
          BlocBuilder<CurrencyCubit, CurrencyState>(
            builder: (context, currState) {
              final symbol = currState.currency.symbol;
              return Card(
                color: AppTheme.cardBackgroundColor,
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.incomeColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.account_balance_wallet_rounded,
                        color: AppTheme.incomeColor),
                  ),
                  title: Text(
                    'Monthly Target Budget',
                    style: TextStyle(color: AppTheme.textColor, fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    'Current: ${CurrencyFormatter.formatAmount(_currentBudget, currencyCode: currState.currency.code, symbolOverride: symbol)}',
                    style: TextStyle(color: AppTheme.textColor),
                  ),
                  trailing: Icon(Icons.chevron_right_rounded, color: AppTheme.textColor),
                  onTap: () {
                    AppHaptics.lightImpact();
                    _setBudgetDialog();
                  },
                ),
              );
            },
          ),
          const SizedBox(height: 24),

          // Security Section
          _buildSectionHeader('SECURITY & PRIVACY'),
          Card(
            color: AppTheme.cardBackgroundColor,
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.incomeColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.shield_rounded, color: AppTheme.incomeColor),
              ),
              title: Text(
                'Security & Privacy',
                style: TextStyle(color: AppTheme.textColor, fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                _isLockEnabled
                    ? 'PIN Lock: Enabled • ${_isBiometricEnabled ? "Biometrics: On" : "Biometrics: Off"}'
                    : 'PIN Lock: Disabled',
                style: TextStyle(color: AppTheme.textColor, fontSize: 12),
              ),
              trailing: Icon(Icons.chevron_right_rounded, color: AppTheme.textColor),
              onTap: () async {
                AppHaptics.lightImpact();
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SecuritySettingsScreen(
                      repository: widget.repository,
                      onSettingsUpdated: () {
                        _loadSettings();
                        widget.onSettingsUpdated();
                      },
                    ),
                  ),
                );
                await _loadSettings();
                widget.onSettingsUpdated();
              },
            ),
          ),
          const SizedBox(height: 24),

          // Export & Import Section
          _buildSectionHeader('DATA MANAGEMENT'),
          Card(
            color: AppTheme.cardBackgroundColor,
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.popHighlightColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.file_upload_rounded, color: AppTheme.popHighlightColor),
              ),
              title: Text(
                'Export CSV Data',
                style: TextStyle(color: AppTheme.textColor, fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                'Export Income, Expenses, or Both for Day, Week, Year',
                style: TextStyle(color: AppTheme.textColor, fontSize: 12),
              ),
              trailing: Icon(Icons.chevron_right_rounded, color: AppTheme.textColor),
              onTap: () async {
                AppHaptics.lightImpact();
                final granted = await StoragePermissionHelper.requestStoragePermission(
                  context,
                  showRationale: true,
                );
                if (!granted) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Storage permission is required to export CSV data.',
                          style: TextStyle(color: AppTheme.textColor),
                        ),
                        backgroundColor: AppTheme.expenseColor,
                      ),
                    );
                  }
                  return;
                }
                if (!context.mounted) return;
                showDialog(
                  context: context,
                  builder: (_) => ExportDataDialog(repository: widget.repository),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Card(
            color: AppTheme.cardBackgroundColor,
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.baseHighlightColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.file_download_rounded, color: AppTheme.baseHighlightColor),
              ),
              title: Text(
                'Import CSV Data',
                style: TextStyle(color: AppTheme.textColor, fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                'Import MoneyMan generated .csv file to restore transactions',
                style: TextStyle(color: AppTheme.textColor, fontSize: 12),
              ),
              trailing: Icon(Icons.chevron_right_rounded, color: AppTheme.textColor),
              onTap: () async {
                AppHaptics.lightImpact();
                final granted = await StoragePermissionHelper.requestStoragePermission(
                  context,
                  showRationale: true,
                );
                if (!granted) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Storage permission is required to import CSV data.',
                          style: TextStyle(color: AppTheme.textColor),
                        ),
                        backgroundColor: AppTheme.expenseColor,
                      ),
                    );
                  }
                  return;
                }
                if (!context.mounted) return;
                showDialog(
                  context: context,
                  builder: (_) => ImportDataDialog(repository: widget.repository),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('RESET APP DATA'),
          Card(
            color: AppTheme.cardBackgroundColor,
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.expenseColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.restart_alt_rounded, color: AppTheme.expenseColor),
              ),
              title: const Text(
                'Reset Database & Start Fresh',
                style: TextStyle(color: AppTheme.expenseColor, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                'Wipe all app data, custom categories, and start from scratch',
                style: TextStyle(color: AppTheme.textColor, fontSize: 12),
              ),
              onTap: () async {
                AppHaptics.heavyImpact();
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: AppTheme.cardBackgroundColor,
                    title: const Text(
                      'Reset Database?',
                      style: TextStyle(color: AppTheme.expenseColor, fontWeight: FontWeight.bold),
                    ),
                    content: Text(
                      'Are you sure you want to reset all app database and start from scratch? All transaction history and settings will be wiped.',
                      style: TextStyle(color: AppTheme.textColor, fontSize: 14),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: Text('Cancel', style: TextStyle(color: AppTheme.textColor)),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.expenseColor,
                          foregroundColor: AppTheme.textColor,
                        ),
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Reset All'),
                      ),
                    ],
                  ),
                );

                if (confirm != true || !context.mounted) return;

                final lockEnabled = await widget.repository.isSecurityLockEnabled();
                final pin = await widget.repository.getSecurityPin();
                if (!context.mounted) return;

                if (lockEnabled && pin != null && pin.isNotEmpty) {
                  final unlocked = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SecurityPinScreen(
                        mode: PinMode.unlock,
                        savedPin: pin,
                      ),
                    ),
                  );
                  if (unlocked != true) return;
                }

                if (!context.mounted) return;
                await widget.repository.resetDatabase();
                if (context.mounted) {
                  await context.read<CategoryCubit>().resetCategories();
                  if (context.mounted) {
                    context.read<DashboardCubit>().loadDashboard();
                    context.read<ExpenseListCubit>().loadExpenses();
                    context.read<CurrencyCubit>().loadCurrency();
                    widget.onSettingsUpdated();

                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (_) => OnboardingScreen(
                          repository: widget.repository,
                          onCompleted: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MainNavigationScreen(repository: widget.repository),
                              ),
                            );
                          },
                        ),
                      ),
                      (route) => false,
                    );
                  }
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: AppTheme.baseHighlightColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
