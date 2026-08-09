import 'package:flutter/material.dart';
import '../../domain/entities/category_item.dart';
import '../../domain/entities/transaction_type.dart';

export '../../domain/entities/category_item.dart';

class AppCategories {
  static List<CategoryItem> expenseCategories = [
    CategoryItem(
      id: 'cat_food',
      name: 'Food',
      iconCodePoint: Icons.restaurant_rounded.codePoint,
      colorValue: 0xFFE7C14D,
      type: TransactionType.expense,
      isCustom: false,
    ),
    CategoryItem(
      id: 'cat_transport',
      name: 'Transport',
      iconCodePoint: Icons.directions_car_rounded.codePoint,
      colorValue: 0xFFE67E22,
      type: TransactionType.expense,
      isCustom: false,
    ),
    CategoryItem(
      id: 'cat_shopping',
      name: 'Shopping',
      iconCodePoint: Icons.shopping_bag_rounded.codePoint,
      colorValue: 0xFFE7C14D,
      type: TransactionType.expense,
      isCustom: false,
    ),
    CategoryItem(
      id: 'cat_entertainment',
      name: 'Entertainment',
      iconCodePoint: Icons.movie_rounded.codePoint,
      colorValue: 0xFFE67E22,
      type: TransactionType.expense,
      isCustom: false,
    ),
    CategoryItem(
      id: 'cat_utilities',
      name: 'Utilities',
      iconCodePoint: Icons.bolt_rounded.codePoint,
      colorValue: 0xFFE7C14D,
      type: TransactionType.expense,
      isCustom: false,
    ),
    CategoryItem(
      id: 'cat_health',
      name: 'Health',
      iconCodePoint: Icons.health_and_safety_rounded.codePoint,
      colorValue: 0xFF6C9C3A,
      type: TransactionType.expense,
      isCustom: false,
    ),
    CategoryItem(
      id: 'cat_education',
      name: 'Education',
      iconCodePoint: Icons.school_rounded.codePoint,
      colorValue: 0xFFE7C14D,
      type: TransactionType.expense,
      isCustom: false,
    ),
    CategoryItem(
      id: 'cat_travel',
      name: 'Travel',
      iconCodePoint: Icons.flight_takeoff_rounded.codePoint,
      colorValue: 0xFFE67E22,
      type: TransactionType.expense,
      isCustom: false,
    ),
    CategoryItem(
      id: 'cat_other_expense',
      name: 'Other',
      iconCodePoint: Icons.grid_view_rounded.codePoint,
      colorValue: 0xFFEEE9D9,
      type: TransactionType.expense,
      isCustom: false,
    ),
  ];

  static List<CategoryItem> incomeCategories = [
    CategoryItem(
      id: 'cat_salary',
      name: 'Salary',
      iconCodePoint: Icons.work_rounded.codePoint,
      colorValue: 0xFF6C9C3A,
      type: TransactionType.income,
      isCustom: false,
    ),
    CategoryItem(
      id: 'cat_freelance',
      name: 'Freelance',
      iconCodePoint: Icons.laptop_mac_rounded.codePoint,
      colorValue: 0xFFE7C14D,
      type: TransactionType.income,
      isCustom: false,
    ),
    CategoryItem(
      id: 'cat_investment',
      name: 'Investment',
      iconCodePoint: Icons.trending_up_rounded.codePoint,
      colorValue: 0xFFE67E22,
      type: TransactionType.income,
      isCustom: false,
    ),
    CategoryItem(
      id: 'cat_bonus',
      name: 'Bonus',
      iconCodePoint: Icons.card_giftcard_rounded.codePoint,
      colorValue: 0xFFE7C14D,
      type: TransactionType.income,
      isCustom: false,
    ),
    CategoryItem(
      id: 'cat_gift',
      name: 'Gift',
      iconCodePoint: Icons.redeem_rounded.codePoint,
      colorValue: 0xFFE67E22,
      type: TransactionType.income,
      isCustom: false,
    ),
    CategoryItem(
      id: 'cat_other_income',
      name: 'Other Income',
      iconCodePoint: Icons.account_balance_wallet_rounded.codePoint,
      colorValue: 0xFF6C9C3A,
      type: TransactionType.income,
      isCustom: false,
    ),
  ];

  static List<CategoryItem> get allCategories => [
        ...expenseCategories,
        ...incomeCategories,
      ];

  static List<CategoryItem> getCategoriesByType(TransactionType type) {
    return type == TransactionType.income
        ? incomeCategories
        : expenseCategories;
  }

  static CategoryItem getCategoryByName(String name) {
    return allCategories.firstWhere(
      (cat) => cat.name.toLowerCase() == name.toLowerCase(),
      orElse: () => CategoryItem(
        id: name.toLowerCase(),
        name: name,
        iconCodePoint: Icons.receipt_long_rounded.codePoint,
        colorValue: 0xFFEEE9D9,
      ),
    );
  }

  static const List<String> paymentMethods = [
    'Cash',
    'Credit Card',
    'Debit Card',
    'UPI / Digital Wallet',
    'Bank Transfer',
  ];
}
