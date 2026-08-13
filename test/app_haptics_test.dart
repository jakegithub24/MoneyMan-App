import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_101/presentation/utils/app_haptics.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppHaptics Multi-Level Engine Tests', () {
    final List<MethodCall> methodCalls = [];

    setUp(() {
      methodCalls.clear();
      AppHaptics.isEnabled = true;

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('com.example.flutter_application_101/haptics'),
        (MethodCall methodCall) async {
          methodCalls.add(methodCall);
          return true;
        },
      );
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('com.example.flutter_application_101/haptics'),
        null,
      );
    });

    test('Triggers light haptic level when enabled', () async {
      AppHaptics.lightImpact();
      await Future.delayed(Duration.zero);

      expect(methodCalls.length, equals(1));
      expect(methodCalls.first.method, equals('triggerHaptic'));
      expect(methodCalls.first.arguments, equals({'strength': 'light'}));
    });

    test('Triggers medium haptic level when enabled', () async {
      AppHaptics.mediumImpact();
      await Future.delayed(Duration.zero);

      expect(methodCalls.length, equals(1));
      expect(methodCalls.first.arguments, equals({'strength': 'medium'}));
    });

    test('Triggers heavy/strong haptic level when enabled', () async {
      AppHaptics.heavyImpact();
      await Future.delayed(Duration.zero);

      expect(methodCalls.length, equals(1));
      expect(methodCalls.first.arguments, equals({'strength': 'heavy'}));
    });

    test('Triggers selection haptic level when enabled', () async {
      AppHaptics.selectionClick();
      await Future.delayed(Duration.zero);

      expect(methodCalls.length, equals(1));
      expect(methodCalls.first.arguments, equals({'strength': 'selection'}));
    });

    test('Triggers vibrate/error haptic level when enabled', () async {
      AppHaptics.vibrate();
      await Future.delayed(Duration.zero);

      expect(methodCalls.length, equals(1));
      expect(methodCalls.first.arguments, equals({'strength': 'vibrate'}));
    });

    test('Suppresses all haptics when disabled by user toggle', () async {
      AppHaptics.isEnabled = false;
      AppHaptics.lightImpact();
      AppHaptics.mediumImpact();
      AppHaptics.heavyImpact();
      await Future.delayed(Duration.zero);

      expect(methodCalls, isEmpty);
    });
  });
}
