import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'application/use_cases/add_expense_usecase.dart';
import 'application/use_cases/delete_expense_usecase.dart';
import 'application/use_cases/get_summary_usecase.dart';
import 'application/use_cases/list_expenses_usecase.dart';
import 'application/use_cases/update_expense_usecase.dart';
import 'data/repositories/category_repository_impl.dart';
import 'data/repositories/expense_repository_impl.dart';
import 'domain/repositories/category_repository.dart';
import 'domain/repositories/expense_repository.dart';
import 'presentation/screens/main_navigation_screen.dart';
import 'presentation/state/category/category_cubit.dart';
import 'presentation/state/currency/currency_cubit.dart';
import 'presentation/state/dashboard/dashboard_cubit.dart';
import 'presentation/state/expense_form/expense_form_cubit.dart';
import 'presentation/state/expense_list/expense_list_cubit.dart';
import 'presentation/state/theme/theme_cubit.dart';
import 'presentation/theme/app_theme.dart';
import 'presentation/utils/activity_tracker.dart';
import 'presentation/utils/app_haptics.dart';
import 'presentation/utils/drm_protection_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive storage
  await Hive.initFlutter();

  // Composition Root / Dependency Injection Wiring
  final expenseRepository = ExpenseRepositoryImpl();
  final categoryRepository = CategoryRepositoryImpl();

  final addExpenseUseCase = AddExpenseUseCase(expenseRepository);
  final updateExpenseUseCase = UpdateExpenseUseCase(expenseRepository);
  final deleteExpenseUseCase = DeleteExpenseUseCase(expenseRepository);
  final listExpensesUseCase = ListExpensesUseCase(expenseRepository);
  final getSummaryUseCase = GetSummaryUseCase(expenseRepository);

  // Load initial Haptic Feedback preference
  AppHaptics.isEnabled = await expenseRepository.isHapticFeedbackEnabled();

  // Load initial DRM protection preference
  final drmEnabled = await expenseRepository.isDrmProtectionEnabled();
  await DrmProtectionHelper.setDrmProtection(drmEnabled);

  runApp(ExpenseTrackerApp(
    repository: expenseRepository,
    categoryRepository: categoryRepository,
    addExpenseUseCase: addExpenseUseCase,
    updateExpenseUseCase: updateExpenseUseCase,
    deleteExpenseUseCase: deleteExpenseUseCase,
    listExpensesUseCase: listExpensesUseCase,
    getSummaryUseCase: getSummaryUseCase,
  ));
}

class ExpenseTrackerApp extends StatelessWidget {
  final ExpenseRepository repository;
  final CategoryRepository categoryRepository;
  final AddExpenseUseCase addExpenseUseCase;
  final UpdateExpenseUseCase updateExpenseUseCase;
  final DeleteExpenseUseCase deleteExpenseUseCase;
  final ListExpensesUseCase listExpensesUseCase;
  final GetSummaryUseCase getSummaryUseCase;

  const ExpenseTrackerApp({
    super.key,
    required this.repository,
    required this.categoryRepository,
    required this.addExpenseUseCase,
    required this.updateExpenseUseCase,
    required this.deleteExpenseUseCase,
    required this.listExpensesUseCase,
    required this.getSummaryUseCase,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>(
          create: (_) => ThemeCubit(repository)..loadTheme(),
        ),
        BlocProvider<CurrencyCubit>(
          create: (_) => CurrencyCubit(repository)..loadCurrency(),
        ),
        BlocProvider<CategoryCubit>(
          create: (_) => CategoryCubit(
            categoryRepository: categoryRepository,
          )..loadCategories(),
        ),
        BlocProvider<DashboardCubit>(
          create: (_) => DashboardCubit(
            getSummaryUseCase: getSummaryUseCase,
            listExpensesUseCase: listExpensesUseCase,
          )..loadDashboard(),
        ),
        BlocProvider<ExpenseListCubit>(
          create: (_) => ExpenseListCubit(
            listExpensesUseCase: listExpensesUseCase,
            deleteExpenseUseCase: deleteExpenseUseCase,
          )..loadExpenses(),
        ),
        BlocProvider<ExpenseFormCubit>(
          create: (_) => ExpenseFormCubit(
            addExpenseUseCase: addExpenseUseCase,
            updateExpenseUseCase: updateExpenseUseCase,
            deleteExpenseUseCase: deleteExpenseUseCase,
          ),
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp(
            title: 'MoneyMan',
            debugShowCheckedModeBanner: false,
            themeMode: themeMode,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            builder: (context, child) {
              return Listener(
                behavior: HitTestBehavior.translucent,
                onPointerDown: (_) => ActivityTracker.recordActivity(),
                onPointerMove: (_) => ActivityTracker.recordActivity(),
                onPointerUp: (_) => ActivityTracker.recordActivity(),
                onPointerHover: (_) => ActivityTracker.recordActivity(),
                child: child!,
              );
            },
            home: MainNavigationScreen(
              repository: repository,
            ),
          );
        },
      ),
    );
  }
}
