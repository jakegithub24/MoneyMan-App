import 'package:flutter/material.dart';
import '../state/dashboard/dashboard_state.dart';
import '../theme/app_theme.dart';
import '../utils/app_haptics.dart';

class FilterChipBar extends StatelessWidget {
  final DateFilterType selectedFilter;
  final ValueChanged<DateFilterType> onFilterSelected;

  const FilterChipBar({
    super.key,
    required this.selectedFilter,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildChip(DateFilterType.today, 'Today'),
          const SizedBox(width: 8),
          _buildChip(DateFilterType.thisWeek, 'This Week'),
          const SizedBox(width: 8),
          _buildChip(DateFilterType.thisMonth, 'This Month'),
          const SizedBox(width: 8),
          _buildChip(DateFilterType.thisYear, 'This Year'),
          const SizedBox(width: 8),
          _buildChip(DateFilterType.all, 'All Time'),
        ],
      ),
    );
  }

  Widget _buildChip(DateFilterType type, String label) {
    final isSelected = selectedFilter == type;

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        AppHaptics.selectionClick();
        onFilterSelected(type);
      },
      selectedColor: AppTheme.baseHighlightColor,
      backgroundColor: AppTheme.cardBackgroundColor,
      side: BorderSide(
        color: isSelected ? AppTheme.baseHighlightColor : AppTheme.textColor.withValues(alpha: 0.3),
      ),
      labelStyle: TextStyle(
        color: isSelected ? AppTheme.backgroundColor : AppTheme.textColor,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 13,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
    );
  }
}
