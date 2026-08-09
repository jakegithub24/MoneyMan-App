import '../../../domain/entities/category_item.dart';

abstract class CategoryState {}

class CategoryInitial extends CategoryState {}

class CategoryLoading extends CategoryState {}

class CategoryLoaded extends CategoryState {
  final List<CategoryItem> categories;
  CategoryLoaded(this.categories);

  List<CategoryItem> get expenseCategories =>
      categories.where((c) => c.type.name == 'expense').toList();

  List<CategoryItem> get incomeCategories =>
      categories.where((c) => c.type.name == 'income').toList();
}

class CategoryError extends CategoryState {
  final String message;
  CategoryError(this.message);
}
