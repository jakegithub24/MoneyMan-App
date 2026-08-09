import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/transaction_type.dart';
import '../constants/categories.dart';
import '../state/category/category_cubit.dart';
import '../state/category/category_state.dart';
import '../theme/app_theme.dart';
import '../widgets/create_category_dialog.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _openCreateCategoryDialog(BuildContext context) async {
    final activeType = _tabController.index == 0 ? TransactionType.expense : TransactionType.income;
    final categoryCubit = context.read<CategoryCubit>();
    final res = await showDialog<bool>(
      context: context,
      builder: (_) => CreateCategoryDialog(initialType: activeType),
    );
    if (res == true && mounted) {
      categoryCubit.loadCategories();
    }
  }

  void _deleteCategory(BuildContext context, CategoryItem category) async {
    final messenger = ScaffoldMessenger.of(context);
    final categoryCubit = context.read<CategoryCubit>();

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardBackgroundColor,
        title: const Text('Delete Category?', style: TextStyle(color: AppTheme.textColor)),
        content: Text(
          'Are you sure you want to delete "${category.name}"?',
          style: const TextStyle(color: AppTheme.textColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.textColor)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.expenseColor, foregroundColor: AppTheme.textColor),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await categoryCubit.deleteCategory(category.id);
      messenger.showSnackBar(
        SnackBar(
          content: Text('Category "${category.name}" deleted', style: const TextStyle(color: AppTheme.textColor)),
          backgroundColor: AppTheme.expenseColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        title: const Text(
          'Manage Categories',
          style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textColor),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.baseHighlightColor,
          labelColor: AppTheme.baseHighlightColor,
          unselectedLabelColor: AppTheme.textColor,
          tabs: const [
            Tab(text: 'Expense Categories'),
            Tab(text: 'Income Categories'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, color: AppTheme.baseHighlightColor, size: 28),
            tooltip: 'Add Category',
            onPressed: () => _openCreateCategoryDialog(context),
          ),
        ],
      ),
      body: BlocBuilder<CategoryCubit, CategoryState>(
        builder: (context, state) {
          if (state is CategoryLoading) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.baseHighlightColor));
          }

          if (state is CategoryError) {
            return Center(child: Text(state.message, style: const TextStyle(color: AppTheme.expenseColor)));
          }

          if (state is CategoryLoaded) {
            return TabBarView(
              controller: _tabController,
              children: [
                _buildCategoryList(context, state.expenseCategories, TransactionType.expense),
                _buildCategoryList(context, state.incomeCategories, TransactionType.income),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.baseHighlightColor,
        foregroundColor: AppTheme.backgroundColor,
        onPressed: () => _openCreateCategoryDialog(context),
        child: const Icon(Icons.add_rounded, color: AppTheme.backgroundColor, size: 28),
      ),
    );
  }

  Widget _buildCategoryList(
    BuildContext context,
    List<CategoryItem> categories,
    TransactionType type,
  ) {
    if (categories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.category_rounded, size: 48, color: AppTheme.textColor),
            const SizedBox(height: 12),
            Text(
              'No ${type.displayName.toLowerCase()} categories found',
              style: const TextStyle(color: AppTheme.textColor, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final cat = categories[index];

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: AppTheme.cardBackgroundColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.textColor.withValues(alpha: 0.2)),
          ),
          child: ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.baseHighlightColor.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(cat.icon, color: AppTheme.baseHighlightColor, size: 20),
            ),
            title: Text(
              cat.name,
              style: const TextStyle(color: AppTheme.textColor, fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              cat.isCustom ? 'Custom Category' : 'System Default',
              style: TextStyle(
                color: cat.isCustom ? AppTheme.popHighlightColor : AppTheme.textColor.withValues(alpha: 0.7),
                fontSize: 12,
              ),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.expenseColor),
              tooltip: 'Delete Category',
              onPressed: () => _deleteCategory(context, cat),
            ),
          ),
        );
      },
    );
  }
}
