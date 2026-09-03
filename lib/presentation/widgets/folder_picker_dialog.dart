import 'dart:io';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/storage_permission_helper.dart';

class FolderPickerDialog extends StatefulWidget {
  final String initialPath;

  const FolderPickerDialog({
    super.key,
    this.initialPath = '/storage/emulated/0',
  });

  @override
  State<FolderPickerDialog> createState() => _FolderPickerDialogState();
}

class _FolderPickerDialogState extends State<FolderPickerDialog> {
  static const String rootBoundary = '/storage/emulated/0';
  late Directory _currentDir;
  List<FileSystemEntity> _subDirectories = [];
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
            _errorMessage = 'Storage permission is required to access folders for CSV export.';
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

      if (mounted) {
        setState(() {
          _currentDir = dir;
          _subDirectories = dirsOnly;
          _isLoading = false;
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

  Future<void> _createNewFolder() async {
    final controller = TextEditingController();
    final folderName = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardBackgroundColor,
        title: Text('New Folder', style: TextStyle(color: AppTheme.textColor)),
        content: TextField(
          controller: controller,
          style: TextStyle(color: AppTheme.textColor),
          decoration: const InputDecoration(
            hintText: 'Folder name (e.g. Exported_CSVs)',
            prefixIcon: Icon(Icons.create_new_folder_rounded, color: AppTheme.baseHighlightColor),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel', style: TextStyle(color: AppTheme.textColor))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.baseHighlightColor,
              foregroundColor: AppTheme.backgroundColor,
            ),
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                Navigator.pop(ctx, controller.text.trim());
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );

    if (folderName != null && folderName.isNotEmpty) {
      final newDir = Directory('${_currentDir.path}/$folderName');
      try {
        await newDir.create();
        _loadDirectoryContents(_currentDir);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to create folder: $e'), backgroundColor: AppTheme.expenseColor),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                Row(
                  children: [
                    Icon(Icons.folder_open_rounded, color: AppTheme.baseHighlightColor, size: 28),
                    SizedBox(width: 10),
                    Text(
                      'Select Download Folder',
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

            // Path Breadcrumbs & Navigation Bar
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
                  IconButton(
                    icon: const Icon(Icons.create_new_folder_rounded, color: AppTheme.baseHighlightColor, size: 20),
                    tooltip: 'New Folder',
                    onPressed: _createNewFolder,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Subdirectories List View
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
                      : _subDirectories.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.folder_off_rounded, color: AppTheme.textColor, size: 40),
                                  SizedBox(height: 8),
                                  Text(
                                    'No subfolders inside this directory',
                                    style: TextStyle(color: AppTheme.textColor, fontSize: 13),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              itemCount: _subDirectories.length,
                              itemBuilder: (context, index) {
                                final subDir = _subDirectories[index] as Directory;
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
                                    onTap: () => _navigateToDir(subDir),
                                  ),
                                );
                              },
                            ),
            ),
            const SizedBox(height: 16),

            // Select Folder Action Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.baseHighlightColor,
                  foregroundColor: AppTheme.backgroundColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                icon: Icon(Icons.check_circle_outline_rounded, color: AppTheme.backgroundColor),
                label: const Text(
                  'Download to This Folder',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  Navigator.pop(context, _currentDir.path);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
