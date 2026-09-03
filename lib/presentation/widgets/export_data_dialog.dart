import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/transaction_type.dart';
import '../../domain/repositories/expense_repository.dart';
import '../theme/app_theme.dart';
import '../utils/storage_permission_helper.dart';
import 'folder_picker_dialog.dart';

enum ExportPeriod { today, week, month, year, all, custom }

class ExportDataDialog extends StatefulWidget {
  final ExpenseRepository repository;

  const ExportDataDialog({
    super.key,
    required this.repository,
  });

  @override
  State<ExportDataDialog> createState() => _ExportDataDialogState();
}

class _ExportDataDialogState extends State<ExportDataDialog> {
  TransactionType? _selectedType; // null means Both
  ExportPeriod _selectedPeriod = ExportPeriod.month;
  DateTimeRange? _customDateRange;

  String _selectedFolderPath = '/storage/emulated/0';
  final TextEditingController _fileNamePrefixController =
      TextEditingController(text: 'moneyman_export');

  bool _isExporting = false;
  String? _previewCsv;

  @override
  void dispose() {
    _fileNamePrefixController.dispose();
    super.dispose();
  }

  String _getPeriodLabel(ExportPeriod period) {
    switch (period) {
      case ExportPeriod.today:
        return 'Today';
      case ExportPeriod.week:
        return 'This Week';
      case ExportPeriod.month:
        return 'This Month';
      case ExportPeriod.year:
        return 'This Year';
      case ExportPeriod.all:
        return 'All Time';
      case ExportPeriod.custom:
        return 'Custom Range';
    }
  }

  (DateTime?, DateTime?) _calculateDateRange() {
    final now = DateTime.now();
    switch (_selectedPeriod) {
      case ExportPeriod.today:
        final start = DateTime(now.year, now.month, now.day);
        final end = DateTime(now.year, now.month, now.day, 23, 59, 59);
        return (start, end);

      case ExportPeriod.week:
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        final start = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
        final end = DateTime(now.year, now.month, now.day, 23, 59, 59);
        return (start, end);

      case ExportPeriod.month:
        final start = DateTime(now.year, now.month, 1);
        final end = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
        return (start, end);

      case ExportPeriod.year:
        final start = DateTime(now.year, 1, 1);
        final end = DateTime(now.year, 12, 31, 23, 59, 59);
        return (start, end);

      case ExportPeriod.all:
        return (null, null);

      case ExportPeriod.custom:
        if (_customDateRange != null) {
          final start = DateTime(
              _customDateRange!.start.year, _customDateRange!.start.month, _customDateRange!.start.day);
          final end = DateTime(
              _customDateRange!.end.year, _customDateRange!.end.month, _customDateRange!.end.day, 23, 59, 59);
          return (start, end);
        }
        return (null, null);
    }
  }

  Future<void> _pickCustomRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDateRange: _customDateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppTheme.baseHighlightColor,
              onPrimary: AppTheme.backgroundColor,
              surface: AppTheme.cardBackgroundColor,
              onSurface: AppTheme.textColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _customDateRange = picked;
        _selectedPeriod = ExportPeriod.custom;
        _previewCsv = null;
      });
    }
  }

  Future<void> _openFolderPickerUI() async {
    final hasPermission = await StoragePermissionHelper.requestStoragePermission(
      context,
      showRationale: true,
    );
    if (!hasPermission) return;
    if (!mounted) return;

    final selectedFolder = await showDialog<String>(
      context: context,
      builder: (_) => FolderPickerDialog(initialPath: _selectedFolderPath),
    );

    if (selectedFolder != null && selectedFolder.isNotEmpty) {
      setState(() {
        _selectedFolderPath = selectedFolder;
      });
    }
  }

  Future<String> _generateCsvData() async {
    final (from, to) = _calculateDateRange();
    return await widget.repository.exportToCsv(
      type: _selectedType,
      from: from,
      to: to,
    );
  }

  Future<void> _downloadCsvWithLocationPicker() async {
    final hasPermission = await StoragePermissionHelper.requestStoragePermission(
      context,
      showRationale: true,
    );
    if (!hasPermission) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Storage permission is required to save CSV files.', style: TextStyle(color: AppTheme.textColor)),
            backgroundColor: AppTheme.expenseColor,
          ),
        );
      }
      return;
    }

    final rawPrefix = _fileNamePrefixController.text.trim();
    if (rawPrefix.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter a file name prefix'),
            backgroundColor: AppTheme.expenseColor,
          ),
        );
      }
      return;
    }

    final sanitizedPrefix = rawPrefix.endsWith('.csv')
        ? rawPrefix.substring(0, rawPrefix.length - 4)
        : rawPrefix;
    final finalFileName = '$sanitizedPrefix.csv';

    setState(() => _isExporting = true);

    try {
      final csvData = await _generateCsvData();
      final savedPath = await widget.repository.saveCsvToStorage(
        csvData,
        finalFileName,
        targetDirectoryPath: _selectedFolderPath,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('CSV successfully saved to:\n$savedPath', style: TextStyle(color: AppTheme.textColor)),
            backgroundColor: AppTheme.cardBackgroundColor,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export Failed: ${e.toString()}', style: TextStyle(color: AppTheme.textColor)),
            backgroundColor: AppTheme.expenseColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  Future<void> _copyToClipboard() async {
    final csvData = await _generateCsvData();
    await Clipboard.setData(ClipboardData(text: csvData));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('CSV data copied to clipboard'),
          backgroundColor: AppTheme.cardBackgroundColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppTheme.cardBackgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.file_upload_rounded, color: AppTheme.baseHighlightColor, size: 28),
                    SizedBox(width: 10),
                    Text(
                      'Export Transactions',
                      style: TextStyle(
                        color: AppTheme.textColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.close_rounded, color: AppTheme.textColor),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 1. Data Type Filter Choice
            Text(
              'Select Data Type',
              style: TextStyle(color: AppTheme.textColor, fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: const Text('Both'),
                    selected: _selectedType == null,
                    selectedColor: AppTheme.baseHighlightColor,
                    backgroundColor: AppTheme.backgroundColor,
                    labelStyle: TextStyle(
                      color: _selectedType == null ? AppTheme.backgroundColor : AppTheme.textColor,
                    ),
                    onSelected: (_) => setState(() {
                      _selectedType = null;
                      _previewCsv = null;
                    }),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: ChoiceChip(
                    label: const Text('Expenses'),
                    selected: _selectedType == TransactionType.expense,
                    selectedColor: AppTheme.expenseColor,
                    backgroundColor: AppTheme.backgroundColor,
                    labelStyle: TextStyle(
                      color: _selectedType == TransactionType.expense ? AppTheme.textColor : AppTheme.textColor,
                    ),
                    onSelected: (_) => setState(() {
                      _selectedType = TransactionType.expense;
                      _previewCsv = null;
                    }),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: ChoiceChip(
                    label: const Text('Income'),
                    selected: _selectedType == TransactionType.income,
                    selectedColor: AppTheme.incomeColor,
                    backgroundColor: AppTheme.backgroundColor,
                    labelStyle: TextStyle(
                      color: _selectedType == TransactionType.income ? AppTheme.textColor : AppTheme.textColor,
                    ),
                    onSelected: (_) => setState(() {
                      _selectedType = TransactionType.income;
                      _previewCsv = null;
                    }),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 2. Period Filter Choice
            Text(
              'Select Period',
              style: TextStyle(color: AppTheme.textColor, fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ExportPeriod.today,
                ExportPeriod.week,
                ExportPeriod.month,
                ExportPeriod.year,
                ExportPeriod.all,
              ].map((period) {
                final isSelected = _selectedPeriod == period;
                return ChoiceChip(
                  label: Text(_getPeriodLabel(period)),
                  selected: isSelected,
                  selectedColor: AppTheme.baseHighlightColor,
                  backgroundColor: AppTheme.backgroundColor,
                  labelStyle: TextStyle(
                    color: isSelected ? AppTheme.backgroundColor : AppTheme.textColor,
                  ),
                  onSelected: (_) => setState(() {
                    _selectedPeriod = period;
                    _previewCsv = null;
                  }),
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: _selectedPeriod == ExportPeriod.custom ? AppTheme.baseHighlightColor : AppTheme.textColor,
                side: BorderSide(
                  color: _selectedPeriod == ExportPeriod.custom ? AppTheme.baseHighlightColor : AppTheme.textColor.withValues(alpha: 0.3),
                ),
              ),
              icon: const Icon(Icons.calendar_month_rounded, size: 18),
              label: Text(_customDateRange == null
                  ? 'Custom Date Range...'
                  : '${DateFormat.MMMd().format(_customDateRange!.start)} - ${DateFormat.MMMd().format(_customDateRange!.end)}'),
              onPressed: _pickCustomRange,
            ),
            const SizedBox(height: 20),

            // Download Path Target Preview Card
            Text(
              'Selected Download Location',
              style: TextStyle(color: AppTheme.textColor, fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.backgroundColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.textColor.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.folder_open_rounded, color: AppTheme.baseHighlightColor, size: 24),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Save Location',
                          style: TextStyle(color: AppTheme.textColor, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          _selectedFolderPath,
                          style: const TextStyle(color: AppTheme.baseHighlightColor, fontSize: 11, fontFamily: 'monospace'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.folder_special_rounded, size: 16, color: AppTheme.baseHighlightColor),
                    label: const Text('Change', style: TextStyle(fontSize: 12, color: AppTheme.baseHighlightColor)),
                    onPressed: _openFolderPickerUI,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // File Name Input
            Text(
              'File Name String (before .csv)',
              style: TextStyle(color: AppTheme.textColor, fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _fileNamePrefixController,
              style: TextStyle(color: AppTheme.textColor, fontWeight: FontWeight.bold, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'moneyman_export',
                prefixIcon: const Icon(Icons.description_rounded, color: AppTheme.baseHighlightColor),
                suffixIcon: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  margin: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppTheme.baseHighlightColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.baseHighlightColor.withValues(alpha: 0.5)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '.csv',
                        style: TextStyle(
                          color: AppTheme.baseHighlightColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.lock_outline_rounded, size: 14, color: AppTheme.baseHighlightColor),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // CSV Preview Expansion
            ExpansionTile(
              tilePadding: EdgeInsets.zero,
              collapsedIconColor: AppTheme.textColor,
              iconColor: AppTheme.baseHighlightColor,
              title: Text(
                'Preview CSV Data',
                style: TextStyle(color: AppTheme.textColor, fontSize: 14, fontWeight: FontWeight.w600),
              ),
              onExpansionChanged: (expanded) async {
                if (expanded && _previewCsv == null) {
                  final data = await _generateCsvData();
                  setState(() => _previewCsv = data);
                }
              },
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 140),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.backgroundColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: SingleChildScrollView(
                      child: Text(
                        _previewCsv ?? 'Loading preview...',
                        style: TextStyle(fontFamily: 'monospace', fontSize: 11, color: AppTheme.textColor),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Primary Download Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.baseHighlightColor,
                  foregroundColor: AppTheme.backgroundColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                icon: Icon(Icons.file_download_rounded, color: AppTheme.backgroundColor),
                label: _isExporting
                    ? CircularProgressIndicator(color: AppTheme.backgroundColor)
                    : const Text(
                        'Download CSV',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                onPressed: _isExporting ? null : _downloadCsvWithLocationPicker,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.textColor,
                  side: BorderSide(color: AppTheme.textColor.withValues(alpha: 0.3)),
                ),
                icon: const Icon(Icons.copy_rounded, size: 18),
                label: const Text('Copy to Clipboard'),
                onPressed: _copyToClipboard,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
