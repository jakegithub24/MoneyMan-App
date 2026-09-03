import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/expense.dart';
import '../../domain/entities/transaction_type.dart';
import '../../domain/models/expense_summary.dart';
import '../constants/categories.dart';
import '../state/category/category_cubit.dart';
import '../state/currency/currency_cubit.dart';
import '../state/currency/currency_state.dart';
import '../state/dashboard/dashboard_state.dart';
import '../theme/app_theme.dart';
import '../utils/app_haptics.dart';
import '../utils/currency_formatter.dart';

enum ChartViewType { pie, line }
enum PieCategoryMode { expense, income }

class CategoryPieChart extends StatefulWidget {
  final Map<String, double>? totalsByCategory;
  final double? totalAmount;
  final ExpenseSummary? summary;
  final List<Expense>? allPeriodExpenses;
  final DateFilterType filterType;
  final Function? onCategoryTap;

  const CategoryPieChart({
    super.key,
    this.totalsByCategory,
    this.totalAmount,
    this.summary,
    this.allPeriodExpenses,
    this.filterType = DateFilterType.thisMonth,
    this.onCategoryTap,
  });

  @override
  State<CategoryPieChart> createState() => _CategoryPieChartState();
}

class _CategoryPieChartState extends State<CategoryPieChart> {
  ChartViewType _chartViewType = ChartViewType.pie;
  PieCategoryMode _pieCategoryMode = PieCategoryMode.expense;
  int touchedIndex = -1;
  int _selected10YearSetIndex = 0;

  List<Expense> get _allPeriodExpenses => widget.allPeriodExpenses ?? const <Expense>[];

  static const List<Color> _chartPalette = [
    AppTheme.baseHighlightColor,
    AppTheme.popHighlightColor,
    AppTheme.incomeColor,
    AppTheme.expenseColor,
    AppTheme.subtleWhite,
  ];

  CategoryItem _getCategoryInfo(String categoryName) {
    try {
      return context.read<CategoryCubit>().getCategoryByName(categoryName);
    } catch (_) {
      return AppCategories.getCategoryByName(categoryName);
    }
  }

  void _triggerCategoryTap(String category, TransactionType type) {
    if (widget.onCategoryTap == null) return;
    try {
      (widget.onCategoryTap as dynamic)(category, type);
    } catch (_) {
      try {
        (widget.onCategoryTap as dynamic)(category);
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
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
              // Header with Title & (Pie / Line) Toggle
              _buildHeader(),
              const SizedBox(height: 12),

              // Content based on selected ChartViewType
              if (_chartViewType == ChartViewType.pie) ...[
                _buildPieTypeToggle(),
                const SizedBox(height: 12),
                _buildPieChartSection(code, symbol),
              ] else ...[
                _buildLineChartSection(code, symbol),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    String title;
    if (_chartViewType == ChartViewType.pie) {
      title = _pieCategoryMode == PieCategoryMode.expense
          ? 'Spending Breakdown'
          : 'Income Breakdown';
    } else {
      title = 'Income & Expense Trends';
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: AppTheme.textColor,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),

        // Pie / Line Graph Toggle
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: AppTheme.backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.textColor.withValues(alpha: 0.15),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildGraphTypeTab(
                type: ChartViewType.pie,
                icon: Icons.pie_chart_rounded,
                label: 'Pie',
              ),
              const SizedBox(width: 2),
              _buildGraphTypeTab(
                type: ChartViewType.line,
                icon: Icons.show_chart_rounded,
                label: 'Line',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGraphTypeTab({
    required ChartViewType type,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _chartViewType == type;

    return InkWell(
      borderRadius: BorderRadius.circular(9),
      onTap: () {
        if (_chartViewType != type) {
          AppHaptics.selectionClick();
          setState(() {
            _chartViewType = type;
            touchedIndex = -1;
          });
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.baseHighlightColor.withValues(alpha: 0.25)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
          border: isSelected
              ? Border.all(color: AppTheme.baseHighlightColor.withValues(alpha: 0.6))
              : Border.all(color: Colors.transparent),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15,
              color: isSelected ? AppTheme.baseHighlightColor : AppTheme.textColor.withValues(alpha: 0.6),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? AppTheme.baseHighlightColor : AppTheme.textColor.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Segmented Pill switch for Pie chart (Expense / Income)
  Widget _buildPieTypeToggle() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.textColor.withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildPieTypeOption(
              mode: PieCategoryMode.expense,
              label: 'Expense',
              activeColor: AppTheme.expenseColor,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _buildPieTypeOption(
              mode: PieCategoryMode.income,
              label: 'Income',
              activeColor: AppTheme.incomeColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPieTypeOption({
    required PieCategoryMode mode,
    required String label,
    required Color activeColor,
  }) {
    final isSelected = _pieCategoryMode == mode;

    return InkWell(
      borderRadius: BorderRadius.circular(9),
      onTap: () {
        if (_pieCategoryMode != mode) {
          AppHaptics.selectionClick();
          setState(() {
            _pieCategoryMode = mode;
            touchedIndex = -1;
          });
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withValues(alpha: 0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
          border: isSelected
              ? Border.all(color: activeColor.withValues(alpha: 0.8), width: 1.2)
              : Border.all(color: Colors.transparent),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? activeColor : AppTheme.textColor.withValues(alpha: 0.7),
          ),
        ),
      ),
    );
  }

  Widget _buildPieChartSection(String code, String symbol) {
    final Map<String, double> categoryMap;
    final double totalAmount;
    final TransactionType targetType;

    if (_pieCategoryMode == PieCategoryMode.expense) {
      targetType = TransactionType.expense;
      if (widget.summary != null) {
        categoryMap = widget.summary!.expenseTotalsByCategory;
        totalAmount = widget.summary!.totalExpense;
      } else {
        categoryMap = widget.totalsByCategory ?? {};
        totalAmount = widget.totalAmount ?? 0.0;
      }
    } else {
      targetType = TransactionType.income;
      if (widget.summary != null) {
        categoryMap = widget.summary!.incomeTotalsByCategory;
        totalAmount = widget.summary!.totalIncome;
      } else {
        categoryMap = {};
        totalAmount = 0.0;
      }
    }

    if (categoryMap.isEmpty || totalAmount <= 0) {
      final typeLabel = _pieCategoryMode == PieCategoryMode.expense ? 'spending' : 'income';
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(
            'No $typeLabel data for this period',
            style: TextStyle(color: AppTheme.textColor.withValues(alpha: 0.7), fontSize: 13),
          ),
        ),
      );
    }

    final entries = categoryMap.entries.toList();
    entries.sort((a, b) => b.value.compareTo(a.value));

    return LayoutBuilder(
      builder: (context, constraints) {
        final isVeryNarrow = constraints.maxWidth < 330;

        if (isVeryNarrow) {
          return Column(
            children: [
              SizedBox(
                height: 160,
                child: _buildPieChart(entries, totalAmount, targetType, centerRadius: 30, sliceRadius: 35),
              ),
              const SizedBox(height: 16),
              _buildLegendList(entries, totalAmount, targetType, symbol, code, maxItems: 3),
            ],
          );
        }

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
                  totalAmount,
                  targetType,
                  centerRadius: centerRadius,
                  sliceRadius: sliceRadius,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 6,
              child: _buildLegendList(entries, totalAmount, targetType, symbol, code, maxItems: 5),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPieChart(
    List<MapEntry<String, double>> entries,
    double totalAmount,
    TransactionType targetType, {
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
            if ((event is FlTapUpEvent || event is FlPanEndEvent) &&
                pieTouchResponse != null &&
                pieTouchResponse.touchedSection != null) {
              final sectionIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
              if (sectionIndex >= 0 && sectionIndex < entries.length) {
                final categoryName = entries[sectionIndex].key;
                _triggerCategoryTap(categoryName, targetType);
              }
            }
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
          final percentage = (entry.value / totalAmount) * 100;
          final color = _chartPalette[i % _chartPalette.length];

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
    double totalAmount,
    TransactionType targetType,
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
        final percentage = (entry.value / totalAmount) * 100;
        final color = _chartPalette[index % _chartPalette.length];

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => _triggerCategoryTap(entry.key, targetType),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 4),
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
                      style: TextStyle(
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
            ),
          ),
        );
      }).toList(),
    );
  }

  // ==========================================
  // Line Chart Section (Income & Expense Trends)
  // ==========================================

  Widget _buildLineChartSection(String code, String symbol) {
    final points = _computeCashflowPoints();

    // Check if total income and expense are both zero
    final hasData = points.any((p) => p.income > 0 || p.expense > 0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Line chart legend: Green line = Income, Red line = Expense
        Row(
          children: [
            _buildLegendItem('Income', AppTheme.incomeColor),
            const SizedBox(width: 16),
            _buildLegendItem('Expense', AppTheme.expenseColor),
          ],
        ),
        const SizedBox(height: 14),

        if (!hasData)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 36),
            child: Center(
              child: Text(
                'No income or expense data for this period',
                style: TextStyle(
                  color: AppTheme.textColor.withValues(alpha: 0.7),
                  fontSize: 13,
                ),
              ),
            ),
          )
        else
          SizedBox(
            height: 180,
            child: _buildLineChartWidget(points, code, symbol),
          ),

        // If All Time is selected, display scrollable 10-year set buttons
        if (widget.filterType == DateFilterType.all) ...[
          const SizedBox(height: 12),
          _build10YearSetSelector(),
        ],
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 3,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: AppTheme.textColor.withValues(alpha: 0.9),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildLineChartWidget(List<_CashflowPoint> points, String code, String symbol) {
    double maxVal = 0.0;
    for (final p in points) {
      if (p.income > maxVal) maxVal = p.income;
      if (p.expense > maxVal) maxVal = p.expense;
    }
    final maxY = math.max(maxVal * 1.15, 10.0);

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: (points.length - 1).toDouble(),
        minY: 0,
        maxY: maxY,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => FlLine(
            color: AppTheme.textColor.withValues(alpha: 0.08),
            strokeWidth: 1,
            dashArray: [4, 4],
          ),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 24,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx >= 0 && idx < points.length) {
                  final label = points[idx].label;
                  if (label.isNotEmpty) {
                    return SideTitleWidget(
                      meta: meta,
                      space: 6,
                      child: Text(
                        label,
                        style: TextStyle(
                          color: AppTheme.textColor.withValues(alpha: 0.7),
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
        lineTouchData: LineTouchData(
          handleBuiltInTouches: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => AppTheme.backgroundColor,
            tooltipBorder: BorderSide(
              color: AppTheme.textColor.withValues(alpha: 0.25),
              width: 1,
            ),
            tooltipPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            getTooltipItems: (touchedSpots) {
              if (touchedSpots.isEmpty) return [];
              final idx = touchedSpots.first.spotIndex;
              final pt = (idx >= 0 && idx < points.length) ? points[idx] : null;
              final title = pt?.tooltipTitle ?? '';

              return touchedSpots.map((spot) {
                final isIncome = spot.barIndex == 0;
                final color = isIncome ? AppTheme.incomeColor : AppTheme.expenseColor;
                final prefix = isIncome ? 'Income' : 'Expense';
                final formatted = CurrencyFormatter.formatAmount(
                  spot.y,
                  currencyCode: code,
                  symbolOverride: symbol,
                  decimalDigits: 0,
                );

                final isFirst = spot == touchedSpots.first;
                final text = isFirst
                    ? '$title\n$prefix: $formatted'
                    : '$prefix: $formatted';

                return LineTooltipItem(
                  text,
                  TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                );
              }).toList();
            },
          ),
        ),
        lineBarsData: [
          // 0: Income (Green Line & Dots)
          LineChartBarData(
            spots: points.map((p) => FlSpot(p.x, p.income)).toList(),
            isCurved: true,
            curveSmoothness: 0.2,
            color: AppTheme.incomeColor,
            barWidth: 2.5,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                radius: 3.5,
                color: AppTheme.incomeColor,
                strokeWidth: 1.5,
                strokeColor: AppTheme.cardBackgroundColor,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              color: AppTheme.incomeColor.withValues(alpha: 0.08),
            ),
          ),

          // 1: Expense (Red Line & Dots)
          LineChartBarData(
            spots: points.map((p) => FlSpot(p.x, p.expense)).toList(),
            isCurved: true,
            curveSmoothness: 0.2,
            color: AppTheme.expenseColor,
            barWidth: 2.5,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                radius: 3.5,
                color: AppTheme.expenseColor,
                strokeWidth: 1.5,
                strokeColor: AppTheme.cardBackgroundColor,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              color: AppTheme.expenseColor.withValues(alpha: 0.08),
            ),
          ),
        ],
      ),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOutCubic,
    );
  }

  // 10-Year Set Selector for All Time View
  Widget _build10YearSetSelector() {
    final currentYear = DateTime.now().year;
    int minYear = currentYear;
    for (final e in _allPeriodExpenses) {
      if (e.date.year < minYear) {
        minYear = e.date.year;
      }
    }

    final totalSets = (((currentYear - minYear) ~/ 10) + 1).clamp(1, 10);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '10-Year Intervals',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppTheme.textColor.withValues(alpha: 0.8),
          ),
        ),
        const SizedBox(height: 6),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(totalSets, (index) {
              final endYear = currentYear - (index * 10);
              final startYear = endYear - 9;
              final isSelected = _selected10YearSetIndex == index;
              final setLabel = 'Set ${index + 1} ($startYear–$endYear)';

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () {
                    if (_selected10YearSetIndex != index) {
                      AppHaptics.selectionClick();
                      setState(() {
                        _selected10YearSetIndex = index;
                      });
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.baseHighlightColor.withValues(alpha: 0.2)
                          : AppTheme.backgroundColor,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.baseHighlightColor
                            : AppTheme.textColor.withValues(alpha: 0.15),
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Text(
                      setLabel,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected
                            ? AppTheme.baseHighlightColor
                            : AppTheme.textColor.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // Cashflow Data Aggregation Algorithm
  // ==========================================

  List<_CashflowPoint> _computeCashflowPoints() {
    final now = DateTime.now();

    switch (widget.filterType) {
      case DateFilterType.today:
        // 6 Buckets of 4 hours
        final slotLabels = ['12 AM', '4 AM', '8 AM', '12 PM', '4 PM', '8 PM'];
        final slotTooltips = [
          '12:00 AM - 04:00 AM',
          '04:00 AM - 08:00 AM',
          '08:00 AM - 12:00 PM',
          '12:00 PM - 04:00 PM',
          '04:00 PM - 08:00 PM',
          '08:00 PM - 12:00 AM',
        ];
        final incomes = List<double>.filled(6, 0.0);
        final expenses = List<double>.filled(6, 0.0);

        for (final e in _allPeriodExpenses) {
          final slot = (e.date.hour ~/ 4).clamp(0, 5);
          if (e.isIncome) {
            incomes[slot] += e.amount;
          } else {
            expenses[slot] += e.amount;
          }
        }

        return List.generate(6, (i) => _CashflowPoint(
          x: i.toDouble(),
          label: slotLabels[i],
          income: incomes[i],
          expense: expenses[i],
          tooltipTitle: slotTooltips[i],
        ));

      case DateFilterType.thisWeek:
        // 7 Days of current week (Mon-Sun)
        final dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        final startOfWeek = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
        final incomes = List<double>.filled(7, 0.0);
        final expenses = List<double>.filled(7, 0.0);

        for (final e in _allPeriodExpenses) {
          final dayIdx = (e.date.weekday - 1).clamp(0, 6);
          if (e.isIncome) {
            incomes[dayIdx] += e.amount;
          } else {
            expenses[dayIdx] += e.amount;
          }
        }

        return List.generate(7, (i) {
          final dayDate = startOfWeek.add(Duration(days: i));
          return _CashflowPoint(
            x: i.toDouble(),
            label: dayLabels[i],
            income: incomes[i],
            expense: expenses[i],
            tooltipTitle: '${dayLabels[i]}, ${DateFormat('MMM d').format(dayDate)}',
          );
        });

      case DateFilterType.thisMonth:
        // Days in current month
        final daysCount = DateTime(now.year, now.month + 1, 0).day;
        final incomes = List<double>.filled(daysCount, 0.0);
        final expenses = List<double>.filled(daysCount, 0.0);

        for (final e in _allPeriodExpenses) {
          final dayIdx = (e.date.day - 1).clamp(0, daysCount - 1);
          if (e.isIncome) {
            incomes[dayIdx] += e.amount;
          } else {
            expenses[dayIdx] += e.amount;
          }
        }

        return List.generate(daysCount, (i) {
          final dayNum = i + 1;
          final showLabel = dayNum == 1 ||
              dayNum == 5 ||
              dayNum == 10 ||
              dayNum == 15 ||
              dayNum == 20 ||
              dayNum == 25 ||
              dayNum == daysCount;

          return _CashflowPoint(
            x: i.toDouble(),
            label: showLabel ? '$dayNum' : '',
            income: incomes[i],
            expense: expenses[i],
            tooltipTitle: DateFormat('MMM d, yyyy').format(DateTime(now.year, now.month, dayNum)),
          );
        });

      case DateFilterType.thisYear:
        // 12 Months (Jan-Dec)
        final monthLabels = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        final incomes = List<double>.filled(12, 0.0);
        final expenses = List<double>.filled(12, 0.0);

        for (final e in _allPeriodExpenses) {
          final monthIdx = (e.date.month - 1).clamp(0, 11);
          if (e.isIncome) {
            incomes[monthIdx] += e.amount;
          } else {
            expenses[monthIdx] += e.amount;
          }
        }

        return List.generate(12, (i) => _CashflowPoint(
          x: i.toDouble(),
          label: monthLabels[i],
          income: incomes[i],
          expense: expenses[i],
          tooltipTitle: '${monthLabels[i]} ${now.year}',
        ));

      case DateFilterType.all:
        // 10-Year Set
        final currentYear = DateTime.now().year;
        final endYear = currentYear - (_selected10YearSetIndex * 10);
        final startYear = endYear - 9;
        final incomes = List<double>.filled(10, 0.0);
        final expenses = List<double>.filled(10, 0.0);

        for (final e in _allPeriodExpenses) {
          if (e.date.year >= startYear && e.date.year <= endYear) {
            final yIdx = (e.date.year - startYear).clamp(0, 9);
            if (e.isIncome) {
              incomes[yIdx] += e.amount;
            } else {
              expenses[yIdx] += e.amount;
            }
          }
        }

        return List.generate(10, (i) {
          final year = startYear + i;
          return _CashflowPoint(
            x: i.toDouble(),
            label: "'${year % 100}",
            income: incomes[i],
            expense: expenses[i],
            tooltipTitle: 'Year $year',
          );
        });
    }
  }
}

class _CashflowPoint {
  final double x;
  final String label;
  final double income;
  final double expense;
  final String tooltipTitle;

  const _CashflowPoint({
    required this.x,
    required this.label,
    required this.income,
    required this.expense,
    required this.tooltipTitle,
  });
}
