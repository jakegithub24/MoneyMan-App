import 'transaction_type.dart';

class Expense {
  final String id;
  final double amount;
  final String category;
  final DateTime date;
  final String? note;
  final String? paymentMethod;
  final TransactionType type;
  final bool isRecurring;
  final RecurringInterval recurringInterval;
  final DateTime createdAt;
  final DateTime updatedAt;

  Expense({
    required this.id,
    required this.amount,
    required this.category,
    required this.date,
    this.note,
    this.paymentMethod,
    this.type = TransactionType.expense,
    this.isRecurring = false,
    this.recurringInterval = RecurringInterval.none,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isIncome => type == TransactionType.income;
  bool get isExpense => type == TransactionType.expense;

  Expense copyWith({
    String? id,
    double? amount,
    String? category,
    DateTime? date,
    String? note,
    String? paymentMethod,
    TransactionType? type,
    bool? isRecurring,
    RecurringInterval? recurringInterval,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Expense(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      note: note ?? this.note,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      type: type ?? this.type,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringInterval: recurringInterval ?? this.recurringInterval,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'category': category,
      'date': date.toIso8601String(),
      'note': note,
      'paymentMethod': paymentMethod,
      'type': type.name,
      'isRecurring': isRecurring,
      'recurringInterval': recurringInterval.name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    TransactionType parsedType = TransactionType.expense;
    if (map['type'] != null) {
      parsedType = TransactionType.values.firstWhere(
        (t) => t.name == map['type'],
        orElse: () => TransactionType.expense,
      );
    }

    RecurringInterval parsedInterval = RecurringInterval.none;
    if (map['recurringInterval'] != null) {
      parsedInterval = RecurringInterval.values.firstWhere(
        (i) => i.name == map['recurringInterval'],
        orElse: () => RecurringInterval.none,
      );
    }

    return Expense(
      id: map['id'] as String,
      amount: (map['amount'] as num).toDouble(),
      category: map['category'] as String,
      date: DateTime.parse(map['date'] as String),
      note: map['note'] as String?,
      paymentMethod: map['paymentMethod'] as String?,
      type: parsedType,
      isRecurring: map['isRecurring'] as bool? ?? false,
      recurringInterval: parsedInterval,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Expense && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
