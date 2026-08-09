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

class MainNavigationScreen extends StatefulWidget {
  final ExpenseRepository repository;

  const MainNavigationScreen({
    super.key,
    required this.repository,
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  bool _isUnlocked = false;

  @override
  void initState() {
    super.initState();
    _checkAppLock();
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
    }

    final lockEnabled = await widget.repository.isSecurityLockEnabled();
    final pin = await widget.repository.getSecurityPin();

    if (lockEnabled && pin != null && pin.isNotEmpty) {
      if (!mounted) return;
      final success = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => SecurityPinScreen(
            mode: PinMode.unlock,
            savedPin: pin,
          ),
        ),
      );

      if (success == true) {
        if (mounted) {
          setState(() {
            _isUnlocked = true;
          });
        }
      } else {
        _checkAppLock();
      }
    } else {
      if (mounted) {
        setState(() {
          _isUnlocked = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isUnlocked) {
      return const Scaffold(
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
          setState(() {
            _currentIndex = 1;
          });
        },
      ),
      const ExpenseListScreen(),
    ];

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
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
          final dashboardCubit = context.read<DashboardCubit>();
          final listCubit = context.read<ExpenseListCubit>();

          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const ExpenseFormScreen(),
            ),
          );
          if (result == true) {
            dashboardCubit.loadDashboard();
            listCubit.loadExpenses();
          }
        },
        child: const Icon(Icons.add_rounded, size: 28, color: AppTheme.backgroundColor),
      ),
    );
  }
}
