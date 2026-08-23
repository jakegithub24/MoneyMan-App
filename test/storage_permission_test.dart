import 'package:flutter/material.dart';
import 'package:flutter_application_101/presentation/theme/app_theme.dart';
import 'package:flutter_application_101/presentation/utils/storage_permission_helper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Storage Permission Tests', () {
    test('hasStoragePermission returns true on non-mobile test environment', () async {
      final hasPermission = await StoragePermissionHelper.hasStoragePermission();
      expect(hasPermission, isTrue);
    });

    testWidgets('Storage Permission Rationale Dialog displays title, description and buttons', (tester) async {
      bool? dialogResult;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () async {
                  dialogResult = await StoragePermissionHelper.showRationaleDialog(context);
                },
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Check for title and description
      expect(find.text('Storage Permission Required'), findsOneWidget);
      expect(
        find.text(
          'MoneyMan requires Storage Permission to export your transaction reports to CSV files and import backup data from your device storage.',
        ),
        findsOneWidget,
      );
      expect(find.text('Not Now'), findsOneWidget);
      expect(find.text('Grant Permission'), findsOneWidget);

      // Tap Grant Permission
      await tester.tap(find.text('Grant Permission'));
      await tester.pumpAndSettle();

      expect(dialogResult, isTrue);
    });

    testWidgets('Storage Permission Rationale Dialog returns false on Not Now tap', (tester) async {
      bool? dialogResult;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () async {
                  dialogResult = await StoragePermissionHelper.showRationaleDialog(context);
                },
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Not Now'));
      await tester.pumpAndSettle();

      expect(dialogResult, isFalse);
    });

    testWidgets('Storage Permission Settings Redirect Dialog displays proper instructions', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () async {
                  await StoragePermissionHelper.showSettingsRedirectDialog(context);
                },
                child: const Text('Show Settings Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Settings Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Permission Denied'), findsOneWidget);
      expect(
        find.text(
          'Storage access was denied. Please allow storage or "All files access" permission in device Settings to use CSV import and export features.',
        ),
        findsOneWidget,
      );
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Open Settings'), findsOneWidget);

      // Tap Cancel to dismiss
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('Permission Denied'), findsNothing);
    });
  });
}
