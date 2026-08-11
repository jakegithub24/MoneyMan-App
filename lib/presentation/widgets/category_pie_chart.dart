import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../constants/categories.dart';
import '../state/category/category_cubit.dart';
import '../state/currency/currency_cubit.dart';
import '../state/currency/currency_state.dart';
import '../theme/app_theme.dart';
import '../utils/currency_formatter.dart';

class CategoryPieChart extends StatefulWidget {
  final Map<String, double> totalsByCategory;
  final double totalAmount;

  const CategoryPieChart({
    super.key,
    required this.totalsByCategory,
    required this.totalAmount,
  });

  @override
  State<CategoryPieChart> createState() => _CategoryPieChartState();
}

class _CategoryPieChartState extends State<CategoryPieChart> {
  int touchedIndex = -1;

  static const List<Color> _chartPalette = [
    AppTheme.baseHighlightColor,
    AppTheme.popHighlightColor,
    AppTheme.incomeColor,
    AppTheme.expenseColor,
    AppTheme.textColor,
  ];

  CategoryItem _getCategoryInfo(String categoryName) {
    try {
      return context.read<CategoryCubit>().getCategoryByName(categoryName);
    } catch (_) {
      return AppCategories.getCategoryByName(categoryName);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.totalsByCategory.isEmpty || widget.totalAmount <= 0) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.cardBackgroundColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.textColor.withValues(alpha: 0.2),
          ),
        ),
        child: const Center(
          child: Text(
            'No spending data for this period',
            style: TextStyle(color: AppTheme.textColor, fontSize: 14),
          ),
        ),
      );
    }

    final entries = widget.totalsByCategory.entries.toList();
    entries.sort((a, b) => b.value.compareTo(a.value));

    return BlocBuilder<CurrencyCubit, CurrencyState>(
      builder: (context, currState) {
        final code = currState.currency.code;
        final symbol = currState.currency.symbol;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.cardBackgroundColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppTheme.textColor.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Spending Breakdown',
                style: TextStyle(
                  color: AppTheme.textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isVeryNarrow = constraints.maxWidth < 330;

                  if (isVeryNarrow) {
                    // Vertical Stack Layout for Very Narrow Screens
                    return Column(
                      children: [
                        SizedBox(
                          height: 160,
                          child: _buildPieChart(entries, centerRadius: 30, sliceRadius: 35),
                        ),
                        const SizedBox(height: 16),
                        _buildLegendList(entries, symbol, code, maxItems: 3),
                      ],
                    );
                  }

                  // Responsive Side-by-Side Layout for Standard Phones
                  final centerRadius = constraints.maxWidth < 380 ? 30.0 : 36.0;
                  final sliceRadius = constraints.maxWidth < 380 ? 36.0 : 42.0;

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 5,
                        child: SizedBox(
                          height: 180,
                          child: _buildPieChart(
                            entries,
                            centerRadius: centerRadius,
                            sliceRadius: sliceRadius,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 6,
                        child: _buildLegendList(entries, symbol, code, maxItems: 5),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPieChart(
    List<MapEntry<String, double>> entries, {
    required double centerRadius,
    required double sliceRadius,
  }) {
    return PieChart(
      PieChartData(
        pieTouchData: PieTouchData(
          touchCallback: (FlTouchEvent event, pieTouchResponse) {
            setState(() {
              if (!event.isInterestedForInteractions ||
                  pieTouchResponse == null ||
                  pieTouchResponse.touchedSection == null) {
                touchedIndex = -1;
                return;
              }
              touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
            });
          },
        ),
        borderData: FlBorderData(show: false),
        sectionsSpace: 2,
        centerSpaceRadius: centerRadius,
        sections: List.generate(entries.length, (i) {
          final isTouched = i == touchedIndex;
          final fontSize = isTouched ? 14.0 : 11.0;
          final radius = isTouched ? (sliceRadius + 8) : sliceRadius;
          final entry = entries[i];
          final percentage = (entry.value / widget.totalAmount) * 100;
          final color = _chartPalette[i % _chartPalette.length];

          // Hide percentage title on slice if slice is smaller than 6% to avoid overlapping
          final showTitle = percentage >= 6 || isTouched;

          return PieChartSectionData(
            color: color,
            value: entry.value,
            title: showTitle ? '${percentage.toStringAsFixed(0)}%' : '',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: AppTheme.backgroundColor,
            ),
          );
        }),
      ),
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOutCubic,
    );
  }

  Widget _buildLegendList(
    List<MapEntry<String, double>> entries,
    String symbol,
    String currencyCode, {
    required int maxItems,
  }) {
    final displayEntries = entries.take(maxItems).toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: displayEntries.asMap().entries.map((item) {
        final index = item.key;
        final entry = item.value;
        final catInfo = _getCategoryInfo(entry.key);
        final percentage = (entry.value / widget.totalAmount) * 100;
        final color = _chartPalette[index % _chartPalette.length];

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  catInfo.name,
                  style: const TextStyle(
                    color: AppTheme.textColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  '${CurrencyFormatter.formatAmount(entry.value, currencyCode: currencyCode, symbolOverride: symbol, decimalDigits: 0)} (${percentage.toStringAsFixed(0)}%)',
                  style: TextStyle(
                    color: AppTheme.textColor.withValues(alpha: 0.8),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
