import 'package:flutter/material.dart';
import '../../domain/repositories/expense_repository.dart';
import '../theme/app_theme.dart';
import '../utils/app_haptics.dart';
import 'security_pin_screen.dart';

class SecuritySettingsScreen extends StatefulWidget {
  final ExpenseRepository repository;
  final VoidCallback onSettingsUpdated;

  const SecuritySettingsScreen({
    super.key,
    required this.repository,
    required this.onSettingsUpdated,
  });

  @override
  State<SecuritySettingsScreen> createState() => _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState extends State<SecuritySettingsScreen> {
  bool _isLockEnabled = false;
  bool _isBiometricEnabled = true;
  String? _savedPin;
  int _autoLockIntervalMinutes = 1;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final lockEnabled = await widget.repository.isSecurityLockEnabled();
    final pin = await widget.repository.getSecurityPin();
    final autoLockInterval = await widget.repository.getAutoLockIntervalMinutes();
    final biometricEnabled = await widget.repository.isBiometricLockEnabled();
    setState(() {
      _isLockEnabled = lockEnabled;
      _isBiometricEnabled = biometricEnabled;
      _savedPin = pin;
      _autoLockIntervalMinutes = autoLockInterval;
    });
  }

  String _getAutoLockIntervalLabel(int minutes) {
    switch (minutes) {
      case 1:
        return '1 minute';
      case 5:
        return '5 minutes';
      case 10:
        return '10 minutes';
      case 30:
        return '30 minutes';
      case 60:
        return '1 hour';
      default:
        return '$minutes minutes';
    }
  }

  Future<void> _showAutoLockIntervalDialog() async {
    final lockEnabled = await widget.repository.isSecurityLockEnabled();
    final currentPin = await widget.repository.getSecurityPin();
    if (!mounted) return;
    if (lockEnabled && currentPin != null && currentPin.isNotEmpty) {
      final unlocked = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => SecurityPinScreen(
            mode: PinMode.unlock,
            savedPin: currentPin,
            isBiometricEnabled: false,
          ),
        ),
      );
      if (unlocked != true) return;
    }

    if (!mounted) return;
    final intervals = [
      {'label': '1 minute', 'value': 1},
      {'label': '5 minutes', 'value': 5},
      {'label': '10 minutes', 'value': 10},
      {'label': '30 minutes', 'value': 30},
      {'label': '1 hour', 'value': 60},
    ];

    final selected = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardBackgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Auto-Lock Interval', style: TextStyle(color: AppTheme.textColor, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: intervals.map((item) {
            final value = item['value'] as int;
            final label = item['label'] as String;
            final isSelected = value == _autoLockIntervalMinutes;
            return ListTile(
              title: Text(
                label,
                style: TextStyle(
                  color: isSelected ? AppTheme.baseHighlightColor : AppTheme.textColor,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              trailing: isSelected ? const Icon(Icons.check_rounded, color: AppTheme.baseHighlightColor) : null,
              onTap: () => Navigator.pop(ctx, value),
            );
          }).toList(),
        ),
      ),
    );

    if (selected != null) {
      await widget.repository.setAutoLockIntervalMinutes(selected);
      await _loadSettings();
      widget.onSettingsUpdated();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Auto-lock interval set to ${_getAutoLockIntervalLabel(selected)}', style: const TextStyle(color: AppTheme.textColor)),
            backgroundColor: AppTheme.cardBackgroundColor,
          ),
        );
      }
    }
  }

  Future<void> _toggleSecurityLock(bool enabled) async {
    AppHaptics.mediumImpact();
    if (enabled) {
      final pin = await Navigator.push<String>(
        context,
        MaterialPageRoute(
          builder: (_) => const SecurityPinScreen(mode: PinMode.setup),
        ),
      );
      if (pin != null && pin.isNotEmpty) {
        await widget.repository.setSecurityPin(pin);
        await widget.repository.setSecurityLockEnabled(true);
        await _loadSettings();
        widget.onSettingsUpdated();
        if (mounted) {
          await _showAutoLockIntervalDialog();
        }
      }
    } else {
      final currentPin = await widget.repository.getSecurityPin();
      if (currentPin != null && currentPin.isNotEmpty) {
        if (!mounted) return;
        final unlocked = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (_) => SecurityPinScreen(
              mode: PinMode.unlock,
              savedPin: currentPin,
              isBiometricEnabled: false,
            ),
          ),
        );
        if (unlocked != true) return;
      }

      await widget.repository.setSecurityLockEnabled(false);
      await _loadSettings();
      widget.onSettingsUpdated();
    }
  }

  Future<void> _toggleBiometricLock(bool enabled) async {
    AppHaptics.mediumImpact();
    final currentPin = await widget.repository.getSecurityPin();
    if (currentPin != null && currentPin.isNotEmpty) {
      if (!mounted) return;
      final unlocked = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => SecurityPinScreen(
            mode: PinMode.unlock,
            savedPin: currentPin,
            isBiometricEnabled: false,
          ),
        ),
      );
      if (unlocked != true) return;
    }

    await widget.repository.setBiometricLockEnabled(enabled);
    await _loadSettings();
    widget.onSettingsUpdated();
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8, top: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: AppTheme.baseHighlightColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        title: const Text(
          'Security & Privacy',
          style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textColor),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader('APP LOCK CONFIGURATION'),
          Card(
            color: AppTheme.cardBackgroundColor,
            child: Column(
              children: [
                SwitchListTile(
                  secondary: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.incomeColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.lock_outline_rounded,
                        color: AppTheme.incomeColor),
                  ),
                  title: const Text(
                    'App Security PIN Lock',
                    style: TextStyle(color: AppTheme.textColor, fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text(
                    'Require 4-digit PIN to access app',
                    style: TextStyle(color: AppTheme.textColor, fontSize: 12),
                  ),
                  value: _isLockEnabled,
                  activeThumbColor: AppTheme.baseHighlightColor,
                  onChanged: _toggleSecurityLock,
                ),
                if (_isLockEnabled && _savedPin != null) ...[
                  const Divider(color: AppTheme.backgroundColor, height: 1),
                  SwitchListTile(
                    secondary: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.incomeColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.fingerprint_rounded,
                          color: AppTheme.incomeColor),
                    ),
                    title: const Text(
                      'Biometric / Fingerprint Unlock',
                      style: TextStyle(color: AppTheme.textColor, fontWeight: FontWeight.w600),
                    ),
                    subtitle: const Text(
                      'Use fingerprint verification alongside 4-digit PIN',
                      style: TextStyle(color: AppTheme.textColor, fontSize: 12),
                    ),
                    value: _isBiometricEnabled,
                    activeThumbColor: AppTheme.baseHighlightColor,
                    onChanged: _toggleBiometricLock,
                  ),
                  const Divider(color: AppTheme.backgroundColor, height: 1),
                  ListTile(
                    leading: const SizedBox(width: 40),
                    title: const Text(
                      'Change Security PIN',
                      style: TextStyle(color: AppTheme.baseHighlightColor, fontSize: 14),
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded, color: AppTheme.textColor),
                    onTap: () async {
                      final currentPin = await widget.repository.getSecurityPin();
                      if (!context.mounted) return;
                      if (currentPin != null && currentPin.isNotEmpty) {
                        final unlocked = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SecurityPinScreen(
                              mode: PinMode.unlock,
                              savedPin: currentPin,
                              isBiometricEnabled: false,
                            ),
                          ),
                        );
                        if (unlocked != true) return;
                      }

                      if (!context.mounted) return;
                      final newPin = await Navigator.push<String>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SecurityPinScreen(mode: PinMode.setup),
                        ),
                      );
                      if (newPin != null && newPin.isNotEmpty) {
                        await widget.repository.setSecurityPin(newPin);
                        await _loadSettings();
                        widget.onSettingsUpdated();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('PIN updated successfully', style: TextStyle(color: AppTheme.textColor)),
                              backgroundColor: AppTheme.cardBackgroundColor,
                            ),
                          );
                        }
                      }
                    },
                  ),
                  const Divider(color: AppTheme.backgroundColor, height: 1),
                  ListTile(
                    leading: const SizedBox(width: 40),
                    title: const Text(
                      'Auto-Lock Interval',
                      style: TextStyle(color: AppTheme.textColor, fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      'Lock after inactivity: ${_getAutoLockIntervalLabel(_autoLockIntervalMinutes)}',
                      style: const TextStyle(color: AppTheme.textColor, fontSize: 12),
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded, color: AppTheme.textColor),
                    onTap: _showAutoLockIntervalDialog,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
