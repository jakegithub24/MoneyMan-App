import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/expense.dart';
import '../../domain/entities/transaction_type.dart';
import '../../domain/models/expense_summary.dart';
import '../../domain/repositories/expense_repository.dart';
import '../datasources/expense_hive_datasource.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  final ExpenseHiveDatasource datasource;

  ExpenseRepositoryImpl([ExpenseHiveDatasource? datasource])
      : datasource = datasource ?? ExpenseHiveDatasource();

  @override
  Future<void> addExpense(Expense expense) => datasource.addExpense(expense);

  @override
  Future<void> updateExpense(Expense expense) => datasource.updateExpense(expense);

  @override
  Future<void> deleteExpense(String id) => datasource.deleteExpense(id);

  @override
  Future<List<Expense>> listExpenses({
    DateTime? from,
    DateTime? to,
    String? category,
    TransactionType? type,
    bool? onlyRecurring,
    String? searchQuery,
  }) async {
    final all = await datasource.getAllExpenses();

    return all.where((e) {
      if (type != null && e.type != type) return false;
      if (onlyRecurring == true && !e.isRecurring) return false;
      if (category != null && category.isNotEmpty && category != 'All') {
        if (e.category.toLowerCase() != category.toLowerCase()) return false;
      }

      if (from != null) {
        if (e.date.isBefore(from)) return false;
      }
      if (to != null) {
        if (e.date.isAfter(to)) return false;
      }

      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final q = searchQuery.toLowerCase().trim();
        final matchNote = (e.note ?? '').toLowerCase().contains(q);
        final matchCategory = e.category.toLowerCase().contains(q);
        final matchMerchant = (e.note ?? '').toLowerCase().contains(q);
        final matchAmount = e.amount.toString().contains(q);
        final matchType = e.type.displayName.toLowerCase().contains(q);
        if (!matchNote && !matchCategory && !matchMerchant && !matchAmount && !matchType) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  @override
  Future<ExpenseSummary> getSummary({
    DateTime? from,
    DateTime? to,
    String? category,
  }) async {
    final filtered = await listExpenses(from: from, to: to, category: category);
    final monthlyBudget = await getMonthlyBudget();
    return ExpenseSummary.fromExpenses(filtered, monthlyBudget: monthlyBudget);
  }

  @override
  Future<double> getMonthlyBudget() => datasource.getMonthlyBudget();

  @override
  Future<void> setMonthlyBudget(double budget) => datasource.setMonthlyBudget(budget);

  @override
  Future<String?> getSecurityPin() => datasource.getSecurityPin();

  @override
  Future<void> setSecurityPin(String? pin) => datasource.setSecurityPin(pin);

  @override
  Future<bool> isSecurityLockEnabled() => datasource.isSecurityLockEnabled();

  @override
  Future<void> setSecurityLockEnabled(bool enabled) => datasource.setSecurityLockEnabled(enabled);

  @override
  Future<bool> isBiometricLockEnabled() => datasource.isBiometricLockEnabled();

  @override
  Future<void> setBiometricLockEnabled(bool enabled) => datasource.setBiometricLockEnabled(enabled);

  @override
  Future<int> getAutoLockIntervalMinutes() => datasource.getAutoLockIntervalMinutes();

  @override
  Future<void> setAutoLockIntervalMinutes(int minutes) => datasource.setAutoLockIntervalMinutes(minutes);

  @override
  Future<int?> getLastActiveTimestamp() => datasource.getLastActiveTimestamp();

  @override
  Future<void> setLastActiveTimestamp(int timestamp) => datasource.setLastActiveTimestamp(timestamp);

  @override
  Future<String> getCurrencyCode() => datasource.getCurrencyCode();

  @override
  Future<String> getCurrencySymbol() => datasource.getCurrencySymbol();

  @override
  Future<void> setCurrency(String code, String symbol) => datasource.setCurrency(code, symbol);

  @override
  Future<String?> getUserName() => datasource.getUserName();

  @override
  Future<void> setUserName(String name) => datasource.setUserName(name);

  @override
  Future<bool> isOnboardingCompleted() => datasource.isOnboardingCompleted();

  @override
  Future<void> setOnboardingCompleted(bool completed) => datasource.setOnboardingCompleted(completed);

  @override
  Future<String> exportToCsv({
    TransactionType? type,
    DateTime? from,
    DateTime? to,
    String? category,
  }) async {
    final filtered = await listExpenses(
      type: type,
      from: from,
      to: to,
      category: category,
    );

    final buffer = StringBuffer();
    buffer.writeln('ID,Type,Category,Amount,Date,Note,PaymentMethod,IsRecurring,RecurringInterval');
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');

    for (final e in filtered) {
      final safeNote = (e.note ?? '').replaceAll('"', '""');
      buffer.writeln(
        '"${e.id}","${e.type.displayName}","${e.category}",${e.amount.toStringAsFixed(2)},"${dateFormat.format(e.date)}","$safeNote","${e.paymentMethod ?? ''}",${e.isRecurring},"${e.recurringInterval.displayName}"',
      );
    }
    return buffer.toString();
  }

  @override
  Future<String> saveCsvToStorage(
    String csvData,
    String fileName, {
    String? targetDirectoryPath,
  }) async {
    String dirPath;

    if (targetDirectoryPath != null && targetDirectoryPath.trim().isNotEmpty) {
      dirPath = targetDirectoryPath.trim();
      final dir = Directory(dirPath);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
    } else {
      Directory? directory;
      try {
        directory = await getDownloadsDirectory();
      } catch (_) {}
      directory ??= await getApplicationDocumentsDirectory();
      dirPath = directory.path;
    }

    final file = File('$dirPath/$fileName');
    await file.writeAsString(csvData);
    return file.path;
  }

  @override
  Future<int> importFromCsv(String csvData) async {
    const invalidMessage = 'Invalid CSV, please upload CSV file Generated by MoneyMan app.';
    final rows = _parseCsvRows(csvData);

    if (rows.isEmpty) {
      throw const FormatException(invalidMessage);
    }

    final header = rows.first;
    if (header.length < 9) {
      throw const FormatException(invalidMessage);
    }

    final h0 = header[0].toLowerCase().replaceAll('"', '');
    final h1 = header[1].toLowerCase().replaceAll('"', '');
    final h2 = header[2].toLowerCase().replaceAll('"', '');
    final h3 = header[3].toLowerCase().replaceAll('"', '');
    final h4 = header[4].toLowerCase().replaceAll('"', '');
    final h5 = header[5].toLowerCase().replaceAll('"', '');
    final h6 = header[6].toLowerCase().replaceAll('"', '');
    final h7 = header[7].toLowerCase().replaceAll('"', '');
    final h8 = header[8].toLowerCase().replaceAll('"', '');

    if (h0 != 'id' ||
        h1 != 'type' ||
        h2 != 'category' ||
        h3 != 'amount' ||
        h4 != 'date' ||
        h5 != 'note' ||
        h6 != 'paymentmethod' ||
        h7 != 'isrecurring' ||
        h8 != 'recurringinterval') {
      throw const FormatException(invalidMessage);
    }

    final dataRows = rows.sublist(1);
    if (dataRows.isEmpty) {
      return 0;
    }

    final dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
    final List<Expense> importedExpenses = [];

    for (final row in dataRows) {
      if (row.length < 9) {
        throw const FormatException(invalidMessage);
      }

      final rawId = row[0].replaceAll('"', '').trim();
      final id = rawId.isNotEmpty ? rawId : const Uuid().v4();

      final rawType = row[1].replaceAll('"', '').trim().toLowerCase();
      TransactionType type;
      if (rawType == 'income') {
        type = TransactionType.income;
      } else if (rawType == 'expense') {
        type = TransactionType.expense;
      } else {
        throw const FormatException(invalidMessage);
      }

      final category = row[2].replaceAll('"', '').trim();
      if (category.isEmpty) {
        throw const FormatException(invalidMessage);
      }

      final amount = double.tryParse(row[3].replaceAll('"', '').trim());
      if (amount == null || amount <= 0) {
        throw const FormatException(invalidMessage);
      }

      final rawDate = row[4].replaceAll('"', '').trim();
      DateTime? date;
      try {
        date = dateFormat.parseStrict(rawDate);
      } catch (_) {
        date = DateTime.tryParse(rawDate);
      }
      if (date == null) {
        throw const FormatException(invalidMessage);
      }
      if (date.isAfter(DateTime.now())) {
        throw const FormatException('CSV Import failed: Future transaction dates are not allowed.');
      }

      final rawNote = row[5].replaceAll('"', '').trim();
      final note = rawNote.isNotEmpty ? rawNote : null;

      final rawPaymentMethod = row[6].replaceAll('"', '').trim();
      final paymentMethod = rawPaymentMethod.isNotEmpty ? rawPaymentMethod : null;

      final rawIsRecurring = row[7].replaceAll('"', '').trim().toLowerCase();
      bool isRecurring;
      if (rawIsRecurring == 'true') {
        isRecurring = true;
      } else if (rawIsRecurring == 'false') {
        isRecurring = false;
      } else {
        throw const FormatException(invalidMessage);
      }

      final rawInterval = row[8].replaceAll('"', '').trim().toLowerCase();
      RecurringInterval interval;
      switch (rawInterval) {
        case 'daily':
          interval = RecurringInterval.daily;
          break;
        case 'weekly':
          interval = RecurringInterval.weekly;
          break;
        case 'monthly':
          interval = RecurringInterval.monthly;
          break;
        case 'yearly':
          interval = RecurringInterval.yearly;
          break;
        case 'none':
        default:
          interval = RecurringInterval.none;
          break;
      }

      final now = DateTime.now();
      importedExpenses.add(
        Expense(
          id: id,
          amount: amount,
          category: category,
          date: date,
          type: type,
          isRecurring: isRecurring,
          recurringInterval: interval,
          note: note,
          paymentMethod: paymentMethod,
          createdAt: now,
          updatedAt: now,
        ),
      );
    }

    // Delete existing app data before importing CSV
    await datasource.deleteAllExpenses();

    for (final exp in importedExpenses) {
      await datasource.addExpense(exp);
    }

    return importedExpenses.length;
  }

  @override
  Future<void> resetDatabase() async {
    await datasource.resetDatabase();
  }

  List<List<String>> _parseCsvRows(String input) {
    final List<List<String>> rows = [];
    final lines = input.split(RegExp(r'\r?\n'));
    for (var line in lines) {
      line = line.trim();
      if (line.isEmpty) continue;
      final List<String> fields = [];
      final StringBuffer currentBuffer = StringBuffer();
      bool inQuotes = false;

      for (int i = 0; i < line.length; i++) {
        final char = line[i];
        if (char == '"') {
          if (inQuotes && i + 1 < line.length && line[i + 1] == '"') {
            currentBuffer.write('"');
            i++;
          } else {
            inQuotes = !inQuotes;
          }
        } else if (char == ',' && !inQuotes) {
          fields.add(currentBuffer.toString().trim());
          currentBuffer.clear();
        } else {
          currentBuffer.write(char);
        }
      }
      fields.add(currentBuffer.toString().trim());
      rows.add(fields);
    }
    return rows;
  }
}
