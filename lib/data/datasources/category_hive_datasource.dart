import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/entities/category_item.dart';
import '../../domain/entities/transaction_type.dart';

class CategoryHiveDatasource {
  static const String boxName = 'categories_box';

  Box<Map>? _box;

  Future<Box<Map>> get box async {
    if (_box != null && _box!.isOpen) {
      return _box!;
    }
    _box = await Hive.openBox<Map>(boxName);
    await _seedDefaultCategoriesIfNeeded(_box!);
    return _box!;
  }

  Future<void> _seedDefaultCategoriesIfNeeded(Box<Map> box) async {
    if (box.isNotEmpty) return;

    final defaultCategories = [
      // Expense Categories
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
      // Income Categories
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

    for (final cat in defaultCategories) {
      await box.put(cat.id, cat.toMap());
    }
  }

  Future<List<CategoryItem>> getAllCategories() async {
    final b = await box;
    final list = <CategoryItem>[];
    for (var i = 0; i < b.length; i++) {
      final val = b.getAt(i);
      if (val != null) {
        try {
          final map = Map<String, dynamic>.from(val);
          list.add(CategoryItem.fromMap(map));
        } catch (_) {}
      }
    }
    return list;
  }

  Future<void> addCategory(CategoryItem category) async {
    final b = await box;
    await b.put(category.id, category.toMap());
  }

  Future<void> deleteCategory(String id) async {
    final b = await box;
    await b.delete(id);
  }

  Future<void> resetCategories() async {
    final b = await box;
    await b.clear();
    await _seedDefaultCategoriesIfNeeded(b);
  }
}
