import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../domain/entities/category_item.dart';
import '../../../domain/entities/transaction_type.dart';
import '../../../domain/repositories/category_repository.dart';
import 'category_state.dart';

class CategoryCubit extends Cubit<CategoryState> {
  final CategoryRepository categoryRepository;

  CategoryCubit({required this.categoryRepository}) : super(CategoryInitial());

  Future<void> loadCategories() async {
    emit(CategoryLoading());
    try {
      final cats = await categoryRepository.getCategories();
      emit(CategoryLoaded(cats));
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }

  Future<bool> addCategory({
    required String name,
    required int iconCodePoint,
    required int colorValue,
    required TransactionType type,
  }) async {
    if (name.trim().isEmpty) {
      emit(CategoryError('Category name cannot be empty'));
      return false;
    }

    try {
      final newCat = CategoryItem(
        id: const Uuid().v4(),
        name: name.trim(),
        iconCodePoint: iconCodePoint,
        colorValue: colorValue,
        type: type,
        isCustom: true,
      );
      await categoryRepository.addCategory(newCat);
      await loadCategories();
      return true;
    } catch (e) {
      emit(CategoryError(e.toString()));
      return false;
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      await categoryRepository.deleteCategory(id);
      await loadCategories();
    } catch (e) {
      emit(CategoryError('Failed to delete category: ${e.toString()}'));
    }
  }

  CategoryItem getCategoryByName(String name) {
    return categoryRepository.getCategoryByName(name);
  }

  Future<void> resetCategories() async {
    try {
      await categoryRepository.resetCategories();
      await loadCategories();
    } catch (e) {
      emit(CategoryError('Failed to reset categories: ${e.toString()}'));
    }
  }
}
