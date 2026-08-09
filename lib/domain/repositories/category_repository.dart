import '../entities/category_item.dart';
import '../entities/transaction_type.dart';

abstract class CategoryRepository {
  Future<List<CategoryItem>> getCategories({TransactionType? type});
  Future<void> addCategory(CategoryItem category);
  Future<void> deleteCategory(String id);
  CategoryItem getCategoryByName(String name);
  Future<void> resetCategories();
}
