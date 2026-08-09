import 'package:flutter/material.dart';
import '../../domain/entities/category_item.dart';
import '../../domain/entities/transaction_type.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/category_hive_datasource.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryHiveDatasource datasource;
  List<CategoryItem> _cache = [];

  CategoryRepositoryImpl({CategoryHiveDatasource? datasource})
      : datasource = datasource ?? CategoryHiveDatasource();

  @override
  Future<List<CategoryItem>> getCategories({TransactionType? type}) async {
    _cache = await datasource.getAllCategories();
    if (type != null) {
      return _cache.where((c) => c.type == type).toList();
    }
    return _cache;
  }

  @override
  Future<void> addCategory(CategoryItem category) async {
    await datasource.addCategory(category);
    _cache = await datasource.getAllCategories();
  }

  @override
  Future<void> deleteCategory(String id) async {
    await datasource.deleteCategory(id);
    _cache = await datasource.getAllCategories();
  }

  @override
  CategoryItem getCategoryByName(String name) {
    if (_cache.isEmpty) {
      return CategoryItem(
        id: name.toLowerCase(),
        name: name,
        iconCodePoint: Icons.receipt_long_rounded.codePoint,
        colorValue: 0xFF64748B,
      );
    }
    return _cache.firstWhere(
      (cat) => cat.name.toLowerCase() == name.toLowerCase(),
      orElse: () => CategoryItem(
        id: name.toLowerCase(),
        name: name,
        iconCodePoint: Icons.receipt_long_rounded.codePoint,
        colorValue: 0xFF64748B,
      ),
    );
  }

  @override
  Future<void> resetCategories() async {
    await datasource.resetCategories();
    _cache = await datasource.getAllCategories();
  }
}
