import '../entities/expense.dart';
import '../entities/transaction_type.dart';
import '../models/expense_summary.dart';

abstract class ExpenseRepository {
  Future<void> addExpense(Expense expense);
  Future<void> updateExpense(Expense expense);
  Future<void> deleteExpense(String id);

  Future<List<Expense>> listExpenses({
    DateTime? from,
    DateTime? to,
    String? category,
    TransactionType? type,
    bool? onlyRecurring,
    String? searchQuery,
  });

  Future<ExpenseSummary> getSummary({
    DateTime? from,
    DateTime? to,
    String? category,
  });

  // Budget Management
  Future<double> getMonthlyBudget();
  Future<void> setMonthlyBudget(double budget);

  // Security Lock PIN Management
  Future<String?> getSecurityPin();
  Future<void> setSecurityPin(String? pin);
  Future<bool> isSecurityLockEnabled();
  Future<void> setSecurityLockEnabled(bool enabled);

  // Currency Management
  Future<String> getCurrencyCode();
  Future<String> getCurrencySymbol();
  Future<void> setCurrency(String code, String symbol);

  // User Profile & Onboarding Management
  Future<String?> getUserName();
  Future<void> setUserName(String name);
  Future<bool> isOnboardingCompleted();
  Future<void> setOnboardingCompleted(bool completed);

  // CSV Export Utilities
  Future<String> exportToCsv({
    TransactionType? type,
    DateTime? from,
    DateTime? to,
    String? category,
  });

  Future<String> saveCsvToStorage(
    String csvData,
    String fileName, {
    String? targetDirectoryPath,
  });

  // CSV Import Utility
  Future<int> importFromCsv(String csvData);

  // Reset Database & Start from Scratch
  Future<void> resetDatabase();
}
