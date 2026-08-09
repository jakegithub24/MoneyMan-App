import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/transaction_type.dart';
import '../state/category/category_cubit.dart';
import '../theme/app_theme.dart';
import '../utils/icon_helper.dart';

class CreateCategoryDialog extends StatefulWidget {
  final TransactionType initialType;

  const CreateCategoryDialog({
    super.key,
    this.initialType = TransactionType.expense,
  });

  @override
  State<CreateCategoryDialog> createState() => _CreateCategoryDialogState();
}

class _CreateCategoryDialogState extends State<CreateCategoryDialog> {
  final TextEditingController _nameController = TextEditingController();
  late TransactionType _selectedType;
  late int _selectedIconCodePoint;
  late int _selectedColorValue;

  static const List<IconData> availableIcons = [
    Icons.restaurant_rounded,
    Icons.shopping_bag_rounded,
    Icons.directions_car_rounded,
    Icons.movie_rounded,
    Icons.bolt_rounded,
    Icons.health_and_safety_rounded,
    Icons.school_rounded,
    Icons.flight_takeoff_rounded,
    Icons.home_rounded,
    Icons.pets_rounded,
    Icons.fitness_center_rounded,
    Icons.local_cafe_rounded,
    Icons.work_rounded,
    Icons.laptop_mac_rounded,
    Icons.trending_up_rounded,
    Icons.card_giftcard_rounded,
    Icons.redeem_rounded,
    Icons.account_balance_wallet_rounded,
    Icons.local_grocery_store_rounded,
    Icons.wifi_rounded,
    Icons.build_rounded,
    Icons.child_care_rounded,
    Icons.local_hospital_rounded,
    Icons.savings_rounded,
  ];

  static const List<Color> availableColors = [
    AppTheme.baseHighlightColor,
    AppTheme.popHighlightColor,
    AppTheme.incomeColor,
    AppTheme.expenseColor,
    AppTheme.textColor,
  ];

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType;
    _selectedIconCodePoint = availableIcons.first.codePoint;
    _selectedColorValue = availableColors.first.toARGB32();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a category name'),
          backgroundColor: AppTheme.expenseColor,
        ),
      );
      return;
    }

    final success = await context.read<CategoryCubit>().addCategory(
          name: name,
          iconCodePoint: _selectedIconCodePoint,
          colorValue: _selectedColorValue,
          type: _selectedType,
        );

    if (success && mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppTheme.cardBackgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Create Category',
                  style: TextStyle(
                    color: AppTheme.textColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppTheme.textColor),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Type Toggle
            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: const Text('Expense'),
                    selected: _selectedType == TransactionType.expense,
                    selectedColor: AppTheme.expenseColor,
                    backgroundColor: AppTheme.backgroundColor,
                    labelStyle: TextStyle(
                      color: _selectedType == TransactionType.expense ? AppTheme.textColor : AppTheme.textColor,
                    ),
                    onSelected: (_) => setState(() => _selectedType = TransactionType.expense),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ChoiceChip(
                    label: const Text('Income'),
                    selected: _selectedType == TransactionType.income,
                    selectedColor: AppTheme.incomeColor,
                    backgroundColor: AppTheme.backgroundColor,
                    labelStyle: TextStyle(
                      color: _selectedType == TransactionType.income ? AppTheme.textColor : AppTheme.textColor,
                    ),
                    onSelected: (_) => setState(() => _selectedType = TransactionType.income),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Category Name Input
            const Text(
              'Category Name',
              style: TextStyle(color: AppTheme.textColor, fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              style: const TextStyle(color: AppTheme.textColor, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                hintText: 'e.g., Subscriptions, Coffee, Gym',
                prefixIcon: Icon(
                  AppIconHelper.getIcon(_selectedIconCodePoint),
                  color: Color(_selectedColorValue),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Color Selector
            const Text(
              'Select Color',
              style: TextStyle(color: AppTheme.textColor, fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: availableColors.map((color) {
                final isSelected = _selectedColorValue == color.toARGB32();
                return GestureDetector(
                  onTap: () => setState(() => _selectedColorValue = color.toARGB32()),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? AppTheme.textColor : Colors.transparent,
                        width: 3,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(Icons.check_rounded, color: AppTheme.backgroundColor, size: 18)
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Icon Selector Grid
            const Text(
              'Select Icon',
              style: TextStyle(color: AppTheme.textColor, fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 140,
              child: GridView.builder(
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: availableIcons.length,
                itemBuilder: (context, index) {
                  final icon = availableIcons[index];
                  final isSelected = _selectedIconCodePoint == icon.codePoint;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedIconCodePoint = icon.codePoint),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Color(_selectedColorValue).withValues(alpha: 0.25)
                            : AppTheme.backgroundColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? Color(_selectedColorValue)
                              : AppTheme.textColor.withValues(alpha: 0.3),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Icon(
                        icon,
                        color: isSelected
                            ? Color(_selectedColorValue)
                            : AppTheme.textColor,
                        size: 20,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.baseHighlightColor,
                  foregroundColor: AppTheme.backgroundColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: _submit,
                child: const Text(
                  'Create Category',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
