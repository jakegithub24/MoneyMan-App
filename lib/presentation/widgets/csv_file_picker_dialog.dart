import 'dart:io';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/storage_permission_helper.dart';

class CsvFilePickerDialog extends StatefulWidget {
  final String initialPath;

  const CsvFilePickerDialog({
    super.key,
    this.initialPath = '/storage/emulated/0',
  });

  @override
  State<CsvFilePickerDialog> createState() => _CsvFilePickerDialogState();
}

class _CsvFilePickerDialogState extends State<CsvFilePickerDialog> {
  static const String rootBoundary = '/storage/emulated/0';
  late Directory _currentDir;
  List<FileSystemEntity> _subDirectories = [];
  List<File> _csvFiles = [];
  File? _selectedFile;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _currentDir = Directory(widget.initialPath);
    _loadDirectoryContents(_currentDir);
  }

  bool get _isAtRootBoundary {
    final cur = _currentDir.absolute.path.replaceAll(RegExp(r'/+$'), '');
    final root = Directory(rootBoundary).absolute.path.replaceAll(RegExp(r'/+$'), '');
    return cur == root;
  }

  Future<void> _loadDirectoryContents(Directory dir) async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _selectedFile = null; // All files un-selected on load/navigation
    });

    final hasPerm = await StoragePermissionHelper.hasStoragePermission();
    if (!hasPerm) {
      if (!mounted) return;
      final granted = await StoragePermissionHelper.requestStoragePermission(
        context,
        showRationale: true,
      );
      if (!granted) {
        if (mounted) {
          setState(() {
            _errorMessage = 'Storage permission is required to browse CSV files.';
            _isLoading = false;
          });
        }
        return;
      }
    }

    try {
      if (!await dir.exists()) {
        final root = Directory(rootBoundary);
        if (await root.exists()) {
          dir = root;
        } else {
          await dir.create(recursive: true);
        }
      }

      final entities = await dir.list().toList();
      final dirsOnly = entities.whereType<Directory>().toList();
      dirsOnly.sort((a, b) => a.path.toLowerCase().compareTo(b.path.toLowerCase()));

      // Show ONLY *.csv files
      final csvsOnly = entities
          .whereType<File>()
          .where((f) => f.path.toLowerCase().endsWith('.csv'))
          .toList();
      csvsOnly.sort((a, b) => a.path.toLowerCase().compareTo(b.path.toLowerCase()));

      if (mounted) {
        setState(() {
          _currentDir = dir;
          _subDirectories = dirsOnly;
          _csvFiles = csvsOnly;
          _isLoading = false;
          _selectedFile = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Cannot access folder: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  void _navigateToDir(Directory targetDir) {
    _loadDirectoryContents(targetDir);
  }

  void _navigateUp() {
    if (_isAtRootBoundary) return;
    final parent = _currentDir.parent;
    if (parent.path.length >= rootBoundary.length) {
      _loadDirectoryContents(parent);
    }
  }

  void _toggleSelectFile(File file) {
    setState(() {
      if (_selectedFile?.path == file.path) {
        _selectedFile = null; // Deselect if tapped again
      } else {
        _selectedFile = file; // Select single file
      }
    });
  }

  void _confirmSelection() {
    if (_selectedFile != null) {
      Navigator.pop(context, _selectedFile!.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppTheme.cardBackgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(20),
        constraints: const BoxConstraints(maxHeight: 560, maxWidth: 440),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.description_rounded, color: AppTheme.baseHighlightColor, size: 28),
                    SizedBox(width: 10),
                    Text(
                      'Select .csv File',
                      style: TextStyle(color: AppTheme.textColor, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.close_rounded, color: AppTheme.textColor),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Path Navigation Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.backgroundColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.textColor.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.arrow_upward_rounded,
                      color: _isAtRootBoundary ? AppTheme.textColor.withValues(alpha: 0.3) : AppTheme.baseHighlightColor,
                      size: 20,
                    ),
                    tooltip: _isAtRootBoundary ? 'Root boundary reached (/storage/emulated/0)' : 'Parent Folder',
                    onPressed: _isAtRootBoundary ? null : _navigateUp,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Text(
                        _currentDir.path,
                        style: TextStyle(
                          color: AppTheme.textColor,
                          fontSize: 12,
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Directory & CSV File List View (Only *.csv files shown)
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppTheme.baseHighlightColor))
                  : _errorMessage.isNotEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.error_outline_rounded, color: AppTheme.expenseColor, size: 36),
                                const SizedBox(height: 8),
                                Text(
                                  _errorMessage,
                                  style: const TextStyle(color: AppTheme.expenseColor, fontSize: 13),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 12),
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.baseHighlightColor,
                                    foregroundColor: AppTheme.backgroundColor,
                                  ),
                                  icon: const Icon(Icons.refresh_rounded, size: 16),
                                  label: const Text('Grant Permission / Retry'),
                                  onPressed: () => _loadDirectoryContents(_currentDir),
                                ),
                              ],
                            ),
                          ),
                        )
                      : (_subDirectories.isEmpty && _csvFiles.isEmpty)
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.folder_off_rounded, color: AppTheme.textColor, size: 40),
                                  SizedBox(height: 8),
                                  Text(
                                    'No subfolders or *.csv files in this directory',
                                    style: TextStyle(color: AppTheme.textColor, fontSize: 13),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            )
                          : ListView(
                              children: [
                                // Subdirectories for navigation
                                ..._subDirectories.map((subDir) {
                                  final folderName = subDir.path.split('/').last;
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 6),
                                    decoration: BoxDecoration(
                                      color: AppTheme.backgroundColor,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: ListTile(
                                      dense: true,
                                      leading: const Icon(Icons.folder_rounded, color: AppTheme.popHighlightColor, size: 22),
                                      title: Text(
                                        folderName,
                                        style: TextStyle(color: AppTheme.textColor, fontWeight: FontWeight.w600, fontSize: 13),
                                      ),
                                      trailing: Icon(Icons.chevron_right_rounded, color: AppTheme.textColor, size: 18),
                                      onTap: () => _navigateToDir(subDir as Directory),
                                    ),
                                  );
                                }),

                                // Only *.csv Files Section
                                ..._csvFiles.map((file) {
                                  final fileName = file.path.split('/').last;
                                  final isSelected = _selectedFile?.path == file.path;

                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 6),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppTheme.baseHighlightColor.withValues(alpha: 0.25)
                                          : AppTheme.backgroundColor,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: isSelected
                                            ? AppTheme.baseHighlightColor
                                            : AppTheme.textColor.withValues(alpha: 0.2),
                                        width: isSelected ? 2 : 1,
                                      ),
                                    ),
                                    child: ListTile(
                                      dense: true,
                                      leading: Icon(
                                        Icons.description_rounded,
                                        color: isSelected ? AppTheme.baseHighlightColor : AppTheme.textColor,
                                        size: 22,
                                      ),
                                      title: Text(
                                        fileName,
                                        style: TextStyle(
                                          color: isSelected ? AppTheme.baseHighlightColor : AppTheme.textColor,
                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                          fontSize: 13,
                                        ),
                                      ),
                                      trailing: Icon(
                                        isSelected
                                            ? Icons.radio_button_checked_rounded
                                            : Icons.radio_button_unchecked_rounded,
                                        color: isSelected
                                            ? AppTheme.baseHighlightColor
                                            : AppTheme.textColor.withValues(alpha: 0.5),
                                        size: 20,
                                      ),
                                      onTap: () => _toggleSelectFile(file),
                                    ),
                                  );
                                }),
                              ],
                            ),
            ),
            const SizedBox(height: 16),

            // Confirm Selection Button (Single File Selection)
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedFile != null
                      ? AppTheme.baseHighlightColor
                      : AppTheme.backgroundColor,
                  foregroundColor: _selectedFile != null
                      ? AppTheme.backgroundColor
                      : AppTheme.textColor.withValues(alpha: 0.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                icon: const Icon(Icons.check_circle_rounded),
                label: Text(
                  _selectedFile != null
                      ? 'Select ${_selectedFile!.path.split('/').last}'
                      : 'Select a *.csv File',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
                onPressed: _selectedFile != null ? _confirmSelection : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
