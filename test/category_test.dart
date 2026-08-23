import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_101/domain/entities/category_item.dart';
import 'package:flutter_application_101/domain/entities/transaction_type.dart';
import 'package:flutter_application_101/domain/repositories/category_repository.dart';
import 'package:flutter_application_101/presentation/state/category/category_cubit.dart';
import 'package:flutter_application_101/presentation/screens/categories_screen.dart';

class InMemoryCategoryRepository implements CategoryRepository {
  final List<CategoryItem> _storage = [
    CategoryItem(
      id: '1',
      name: 'Food',
      iconCodePoint: Icons.restaurant.codePoint,
      colorValue: 0xFFFF7D54,
      type: TransactionType.expense,
      isCustom: false,
    ),
  ];

  @override
  Future<List<CategoryItem>> getCategories({TransactionType? type}) async {
    if (type != null) {
      return _storage.where((c) => c.type == type).toList();
    }
    return List.from(_storage);
  }

  @override
  Future<void> addCategory(CategoryItem category) async {
    _storage.add(category);
  }

  @override
  Future<void> deleteCategory(String id) async {
    _storage.removeWhere((c) => c.id == id);
  }

  @override
  CategoryItem getCategoryByName(String name) {
    return _storage.firstWhere(
      (c) => c.name.toLowerCase() == name.toLowerCase(),
      orElse: () => CategoryItem(
        id: name.toLowerCase(),
        name: name,
        iconCodePoint: Icons.category.codePoint,
        colorValue: 0xFF64748B,
      ),
    );
  }

  @override
  Future<void> resetCategories() async {
    _storage.clear();
    _storage.add(CategoryItem(
      id: '1',
      name: 'Food',
      iconCodePoint: Icons.restaurant.codePoint,
      colorValue: 0xFFFF7D54,
      type: TransactionType.expense,
      isCustom: false,
    ));
  }
}

void main() {
  group('Category Creation and Deletion Tests', () {
    late InMemoryCategoryRepository repository;

    setUp(() {
      repository = InMemoryCategoryRepository();
    });

    test('User can fetch default categories', () async {
      final categories = await repository.getCategories();
      expect(categories.length, equals(1));
      expect(categories.first.name, equals('Food'));
    });

    test('User can create custom category', () async {
      final customCategory = CategoryItem(
        id: 'cat_custom_1',
        name: 'Gaming',
        iconCodePoint: Icons.sports_esports.codePoint,
        colorValue: 0xFF8B5CF6,
        type: TransactionType.expense,
        isCustom: true,
      );

      await repository.addCategory(customCategory);
      final categories = await repository.getCategories();
      expect(categories.length, equals(2));
      expect(categories.any((c) => c.name == 'Gaming'), isTrue);
    });

    test('User can delete custom category', () async {
      final customCategory = CategoryItem(
        id: 'cat_custom_2',
        name: 'Crypto',
        iconCodePoint: Icons.currency_bitcoin.codePoint,
        colorValue: 0xFFF59E0B,
        type: TransactionType.income,
        isCustom: true,
      );

      await repository.addCategory(customCategory);
      expect((await repository.getCategories()).length, equals(2));

      await repository.deleteCategory('cat_custom_2');
      final remaining = await repository.getCategories();
      expect(remaining.length, equals(1));
      expect(remaining.any((c) => c.id == 'cat_custom_2'), isFalse);
    });

    test('User can delete system default category', () async {
      final initial = await repository.getCategories();
      expect(initial.any((c) => c.id == '1'), isTrue);

      await repository.deleteCategory('1');
      final remaining = await repository.getCategories();
      expect(remaining.isEmpty, isTrue);
    });

    testWidgets('CategoriesScreen renders invisible card at the end of category list to avoid FAB underlap', (tester) async {
      final categoryCubit = CategoryCubit(categoryRepository: repository);

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<CategoryCubit>.value(
            value: categoryCubit..loadCategories(),
            child: const CategoriesScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify category list is shown
      expect(find.text('Food'), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);

      // Verify ListView itemCount includes the +1 invisible card spacer
      final listViewFinder = find.byType(ListView);
      expect(listViewFinder, findsOneWidget);
      final ListView listView = tester.widget(listViewFinder);
      expect(listView.semanticChildCount, equals(2)); // 1 category item + 1 invisible card spacer
    });
  });
}
