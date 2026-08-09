import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/currency_item.dart';
import '../state/currency/currency_cubit.dart';
import '../state/dashboard/dashboard_cubit.dart';
import '../theme/app_theme.dart';

class CurrencySelectorDialog extends StatefulWidget {
  final CurrencyItem? initialCurrency;
  final ValueChanged<CurrencyItem>? onSelected;

  const CurrencySelectorDialog({
    super.key,
    this.initialCurrency,
    this.onSelected,
  });

  @override
  State<CurrencySelectorDialog> createState() => _CurrencySelectorDialogState();
}

class _CurrencySelectorDialogState extends State<CurrencySelectorDialog> {
  final TextEditingController _searchController = TextEditingController();
  String _filter = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String activeCode = widget.initialCurrency?.code ?? '';
    if (activeCode.isEmpty) {
      try {
        activeCode = context.read<CurrencyCubit>().state.currency.code;
      } catch (_) {
        activeCode = 'INR';
      }
    }

    return Dialog(
      backgroundColor: AppTheme.cardBackgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(20),
        constraints: const BoxConstraints(maxHeight: 520, maxWidth: 420),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.currency_exchange_rounded, color: AppTheme.baseHighlightColor, size: 28),
                    SizedBox(width: 10),
                    Text(
                      'Select Currency',
                      style: TextStyle(
                        color: AppTheme.textColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppTheme.textColor),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Search Bar
            TextField(
              controller: _searchController,
              style: const TextStyle(color: AppTheme.textColor),
              onChanged: (val) => setState(() => _filter = val.trim().toLowerCase()),
              decoration: const InputDecoration(
                hintText: 'Search INR, USD, Euro, Yen...',
                prefixIcon: Icon(Icons.search_rounded, color: AppTheme.textColor),
              ),
            ),
            const SizedBox(height: 16),

            // Currencies List
            Expanded(
              child: Builder(
                builder: (context) {
                  final filtered = CurrencyItem.availableCurrencies.where((c) {
                    if (_filter.isEmpty) return true;
                    return c.code.toLowerCase().contains(_filter) ||
                        c.name.toLowerCase().contains(_filter) ||
                        c.symbol.toLowerCase().contains(_filter);
                  }).toList();

                  if (filtered.isEmpty) {
                    return const Center(
                      child: Text(
                        'No currencies found',
                        style: TextStyle(color: AppTheme.textColor),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final item = filtered[index];
                      final isSelected = activeCode.toUpperCase() == item.code.toUpperCase();

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppTheme.baseHighlightColor.withValues(alpha: 0.25)
                              : AppTheme.backgroundColor,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected
                                ? AppTheme.baseHighlightColor
                                : AppTheme.textColor.withValues(alpha: 0.2),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: ListTile(
                          onTap: () async {
                            if (widget.onSelected != null) {
                              widget.onSelected!(item);
                              Navigator.pop(context, item);
                            } else {
                              try {
                                final currencyCubit = context.read<CurrencyCubit>();
                                final dashboardCubit = context.read<DashboardCubit>();
                                await currencyCubit.changeCurrency(item);
                                dashboardCubit.loadDashboard();
                              } catch (_) {}
                              if (context.mounted) {
                                Navigator.pop(context, item);
                              }
                            }
                          },
                          leading: Text(
                            item.flag,
                            style: const TextStyle(fontSize: 24),
                          ),
                          title: Row(
                            children: [
                              Text(
                                item.code,
                                style: const TextStyle(
                                  color: AppTheme.textColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppTheme.cardBackgroundColor,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  item.symbol,
                                  style: const TextStyle(
                                    color: AppTheme.textColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          subtitle: Text(
                            item.name,
                            style: const TextStyle(color: AppTheme.textColor, fontSize: 12),
                          ),
                          trailing: isSelected
                              ? const Icon(Icons.check_circle_rounded, color: AppTheme.baseHighlightColor, size: 22)
                              : null,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
