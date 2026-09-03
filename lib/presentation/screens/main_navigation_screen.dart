import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/expense_repository.dart';
import '../state/dashboard/dashboard_cubit.dart';
import '../state/expense_list/expense_list_cubit.dart';
import '../theme/app_theme.dart';
import 'dashboard_screen.dart';
import 'expense_form_screen.dart';
import 'expense_list_screen.dart';
import 'onboarding_screen.dart';
import 'security_pin_screen.dart';
import '../utils/activity_tracker.dart';
import '../utils/app_haptics.dart';

class MainNavigationScreen extends StatefulWidget {
  final ExpenseRepository repository;

  const MainNavigationScreen({
    super.key,
    required this.repository,
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> with WidgetsBindingObserver {
  int _currentIndex = 0;
  bool _isUnlocked = false;
  DateTime? _lastPausedTime;
  Timer? _inactivityTimer;
  bool _isLockDialogOpen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkAppLock();
    _startInactivityChecker();
  }

  @override
  void dispose() {
    _inactivityTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _onUserActivity() {
    ActivityTracker.recordActivity();
  }

  void _startInactivityChecker() {
    _inactivityTimer?.cancel();
    _inactivityTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      _checkInactivityAutoLock();
    });
  }

  Future<void> _checkInactivityAutoLock() async {
    if (!_isUnlocked || _isLockDialogOpen) return;

    final lockEnabled = await widget.repository.isSecurityLockEnabled();
    final pin = await widget.repository.getSecurityPin();
    if (!lockEnabled || pin == null || pin.isEmpty) return;

    final intervalMinutes = await widget.repository.getAutoLockIntervalMinutes();
    final elapsed = DateTime.now().difference(ActivityTracker.lastUserActivityTime);

    if (elapsed >= Duration(minutes: intervalMinutes)) {
      final biometricEnabled = await widget.repository.isBiometricLockEnabled();
      _isLockDialogOpen = true;
      if (!mounted) return;
      final success = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => SecurityPinScreen(
            mode: PinMode.unlock,
            savedPin: pin,
            isBiometricEnabled: biometricEnabled,
          ),
        ),
      );
      _isLockDialogOpen = false;
      if (success == true) {
        ActivityTracker.recordActivity();
      } else {
        _checkInactivityAutoLock();
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _lastPausedTime = DateTime.now();
      widget.repository.setLastActiveTimestamp(_lastPausedTime!.millisecondsSinceEpoch);
    } else if (state == AppLifecycleState.resumed) {
      _checkAutoLockOnResume();
    }
  }

  Future<void> _checkAutoLockOnResume() async {
    final lockEnabled = await widget.repository.isSecurityLockEnabled();
    final pin = await widget.repository.getSecurityPin();
    if (!lockEnabled || pin == null || pin.isEmpty) return;

    final intervalMinutes = await widget.repository.getAutoLockIntervalMinutes();
    final lastTimestamp = await widget.repository.getLastActiveTimestamp();

    final lastTime = _lastPausedTime ?? (lastTimestamp != null ? DateTime.fromMillisecondsSinceEpoch(lastTimestamp) : null);
    if (lastTime != null) {
      final elapsed = DateTime.now().difference(lastTime);
      if (elapsed >= Duration(minutes: intervalMinutes)) {
        final biometricEnabled = await widget.repository.isBiometricLockEnabled();
        if (!mounted || _isLockDialogOpen) return;
        _isLockDialogOpen = true;
        final success = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (_) => SecurityPinScreen(
              mode: PinMode.unlock,
              savedPin: pin,
              isBiometricEnabled: biometricEnabled,
            ),
          ),
        );
        _isLockDialogOpen = false;
        if (success == true) {
          ActivityTracker.recordActivity();
        } else {
          _checkAutoLockOnResume();
        }
      }
    }
  }

  Future<void> _checkAppLock() async {
    final onboardingCompleted = await widget.repository.isOnboardingCompleted();
    if (!onboardingCompleted) {
      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OnboardingScreen(
            repository: widget.repository,
            onCompleted: () {
              Navigator.pop(context);
            },
          ),
        ),
      );
      if (mounted) {
        context.read<DashboardCubit>().loadDashboard();
        context.read<ExpenseListCubit>().loadExpenses();
      }
    }

    final lockEnabled = await widget.repository.isSecurityLockEnabled();
    final pin = await widget.repository.getSecurityPin();

    if (lockEnabled && pin != null && pin.isNotEmpty) {
      final biometricEnabled = await widget.repository.isBiometricLockEnabled();
      if (!mounted) return;
      _isLockDialogOpen = true;
      final success = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => SecurityPinScreen(
            mode: PinMode.unlock,
            savedPin: pin,
            isBiometricEnabled: biometricEnabled,
          ),
        ),
      );
      _isLockDialogOpen = false;

      if (success == true) {
        if (mounted) {
          setState(() {
            _isUnlocked = true;
          });
          ActivityTracker.recordActivity();
        }
      } else {
        _checkAppLock();
      }
    } else {
      if (mounted) {
        setState(() {
          _isUnlocked = true;
        });
        ActivityTracker.recordActivity();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isUnlocked) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: Center(
          child: CircularProgressIndicator(color: AppTheme.baseHighlightColor),
        ),
      );
    }

    final screens = [
      DashboardScreen(
        repository: widget.repository,
        onSeeAllPressed: () {
          context.read<ExpenseListCubit>().setTypeAndRecurringFilter(null, false);
          setState(() {
            _currentIndex = 1;
          });
        },
        onNavigateToTransactionsWithFilter: (type) {
          context.read<ExpenseListCubit>().setTypeAndRecurringFilter(type, false);
          setState(() {
            _currentIndex = 1;
          });
        },
        onNavigateToTransactionsWithCategory: (category, [type]) {
          context.read<ExpenseListCubit>().filterByCategory(category, type: type);
          setState(() {
            _currentIndex = 1;
          });
        },
      ),
      const ExpenseListScreen(),
    ];

    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _onUserActivity(),
      onPointerMove: (_) => _onUserActivity(),
      onPointerUp: (_) => _onUserActivity(),
      child: PopScope(
        canPop: _currentIndex == 0,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          if (_currentIndex != 0) {
            _onUserActivity();
            AppHaptics.lightImpact();
            setState(() {
              _currentIndex = 0;
            });
          }
        },
        child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          switchInCurve: Curves.easeInOut,
          switchOutCurve: Curves.easeInOut,
          child: KeyedSubtree(
            key: ValueKey<int>(_currentIndex),
            child: screens[_currentIndex],
          ),
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: AppTheme.cardBackgroundColor,
            border: Border(
              top: BorderSide(
                color: AppTheme.textColor.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            backgroundColor: AppTheme.cardBackgroundColor,
            selectedItemColor: AppTheme.baseHighlightColor,
            unselectedItemColor: AppTheme.textColor.withValues(alpha: 0.6),
            elevation: 0,
            onTap: (index) {
              _onUserActivity();
              AppHaptics.selectionClick();
              setState(() {
                _currentIndex = index;
              });
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard_rounded),
                label: 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.receipt_long_rounded),
                label: 'Transactions',
              ),
            ],
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: FloatingActionButton(
          backgroundColor: AppTheme.baseHighlightColor,
          foregroundColor: AppTheme.backgroundColor,
          onPressed: () async {
            _onUserActivity();
            final dashboardCubit = context.read<DashboardCubit>();
            final listCubit = context.read<ExpenseListCubit>();

            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ExpenseFormScreen(),
              ),
            );
            _onUserActivity();
            if (result == true) {
              dashboardCubit.loadDashboard();
              listCubit.loadExpenses();
            }
          },
          child: Icon(Icons.add_rounded, size: 28, color: AppTheme.backgroundColor),
        ),
      ),
    ),
  );
}
}
