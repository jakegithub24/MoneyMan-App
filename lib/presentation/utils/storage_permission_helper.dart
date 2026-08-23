import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../theme/app_theme.dart';

class StoragePermissionHelper {
  /// Checks if storage permission is already granted.
  static Future<bool> hasStoragePermission() async {
    // Non-mobile platforms (e.g. desktop/unit tests) do not require runtime permission.
    if (!Platform.isAndroid && !Platform.isIOS) {
      return true;
    }

    if (Platform.isAndroid) {
      // Check manageExternalStorage (Android 11+ / API 30+)
      final manageGranted = await Permission.manageExternalStorage.isGranted;
      if (manageGranted) return true;

      // Check standard storage permission (Android 10 and below)
      final storageGranted = await Permission.storage.isGranted;
      if (storageGranted) return true;

      return false;
    }

    // iOS / other
    return await Permission.storage.isGranted;
  }

  /// Displays a rationale dialog explaining why MoneyMan needs storage permission.
  static Future<bool> showRationaleDialog(
    BuildContext context, {
    String title = 'Storage Permission Required',
    String message =
        'MoneyMan requires Storage Permission to export your transaction reports to CSV files and import backup data from your device storage.',
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardBackgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.baseHighlightColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.folder_shared_rounded,
                color: AppTheme.baseHighlightColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: AppTheme.textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: TextStyle(
            color: AppTheme.textColor.withValues(alpha: 0.9),
            fontSize: 14,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Not Now',
              style: TextStyle(
                color: AppTheme.textColor.withValues(alpha: 0.7),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.baseHighlightColor,
              foregroundColor: AppTheme.backgroundColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Grant Permission',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  /// Displays a dialog guiding the user to app settings if permission is permanently denied.
  static Future<void> showSettingsRedirectDialog(
    BuildContext context, {
    String title = 'Permission Denied',
    String message =
        'Storage access was denied. Please allow storage or "All files access" permission in device Settings to use CSV import and export features.',
  }) async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardBackgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.expenseColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.settings_suggest_rounded,
                color: AppTheme.expenseColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: AppTheme.textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: TextStyle(
            color: AppTheme.textColor.withValues(alpha: 0.9),
            fontSize: 14,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppTheme.textColor),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.baseHighlightColor,
              foregroundColor: AppTheme.backgroundColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              openAppSettings();
            },
            child: const Text(
              'Open Settings',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  /// Requests storage permission with rationale if needed.
  /// Returns `true` if permission is granted, `false` otherwise.
  static Future<bool> requestStoragePermission(
    BuildContext context, {
    bool showRationale = false,
  }) async {
    if (!Platform.isAndroid && !Platform.isIOS) {
      return true;
    }

    // Check if already granted
    if (await hasStoragePermission()) {
      return true;
    }

    if (!context.mounted) {
      return false;
    }

    // Show rationale if requested
    if (showRationale) {
      final proceed = await showRationaleDialog(context);
      if (!proceed) {
        return false;
      }
    }

    // Request permissions
    if (Platform.isAndroid) {
      // 1. Try standard storage permission
      final storageStatus = await Permission.storage.request();
      if (storageStatus.isGranted) {
        return true;
      }

      // 2. On Android 11+ (API 30+), try manageExternalStorage
      final manageStatus = await Permission.manageExternalStorage.request();
      if (manageStatus.isGranted) {
        return true;
      }

      // If permanently denied, offer settings redirect dialog
      if (storageStatus.isPermanentlyDenied || manageStatus.isPermanentlyDenied) {
        if (context.mounted) {
          await showSettingsRedirectDialog(context);
        }
      }
    } else {
      final status = await Permission.storage.request();
      if (status.isGranted) {
        return true;
      }
      if (status.isPermanentlyDenied && context.mounted) {
        await showSettingsRedirectDialog(context);
      }
    }

    return await hasStoragePermission();
  }

  /// Helper specifically for first app launch / onboarding flow.
  static Future<bool> requestOnFirstStart(BuildContext context) async {
    if (!Platform.isAndroid && !Platform.isIOS) {
      return true;
    }

    if (await hasStoragePermission()) {
      return true;
    }

    if (!context.mounted) {
      return false;
    }

    return await requestStoragePermission(
      context,
      showRationale: true,
    );
  }
}
