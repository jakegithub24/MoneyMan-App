import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/expense_repository.dart';
import '../../theme/app_theme.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  final ExpenseRepository repository;

  ThemeCubit(this.repository) : super(ThemeMode.system);

  Future<void> loadTheme() async {
    final modeStr = await repository.getAppearanceMode();
    final mode = parseThemeMode(modeStr);
    AppTheme.currentThemeMode = mode;
    emit(mode);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    AppTheme.currentThemeMode = mode;
    emit(mode);
    final modeStr = themeModeToString(mode);
    await repository.setAppearanceMode(modeStr);
  }

  static ThemeMode parseThemeMode(String str) {
    switch (str.toLowerCase()) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'device':
      default:
        return ThemeMode.system;
    }
  }

  static String themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'device';
    }
  }
}
