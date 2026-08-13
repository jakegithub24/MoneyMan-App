import 'package:flutter/services.dart';

/// Centralized high-sensitivity multi-level haptic feedback engine for MoneyMan.
/// Interacts with native Android Vibrator API (supporting amplitude control for linear/piezoelectric motors)
/// and falls back gracefully to Flutter HapticFeedback platform services.
class AppHaptics {
  static const MethodChannel _channel = MethodChannel('com.example.flutter_application_101/haptics');

  /// Global toggle reflecting user preference.
  static bool isEnabled = true;

  static Future<void> _trigger(String strength, VoidCallback fallback) async {
    if (!isEnabled) return;
    try {
      await _channel.invokeMethod('triggerHaptic', {'strength': strength});
    } catch (_) {
      fallback();
    }
  }

  /// Light / Weak impact feedback (tactile click for card taps, list item taps, typing).
  static void lightImpact() {
    _trigger('light', () {
      HapticFeedback.lightImpact();
      HapticFeedback.mediumImpact();
    });
  }

  /// Medium impact feedback (defined tactile pulse for action buttons, switch toggles, pull-to-refresh).
  static void mediumImpact() {
    _trigger('medium', () {
      HapticFeedback.mediumImpact();
      HapticFeedback.vibrate();
    });
  }

  /// Hard / Strong impact feedback (high-power motor pulse for adding/deleting records, locking app).
  static void heavyImpact() {
    _trigger('heavy', () {
      HapticFeedback.heavyImpact();
      HapticFeedback.vibrate();
    });
  }

  /// Selection click feedback (crisp tick for PIN numpads, tab switches, filter chips).
  static void selectionClick() {
    _trigger('selection', () {
      HapticFeedback.selectionClick();
      HapticFeedback.mediumImpact();
    });
  }

  /// Strong vibration pulse for alerts, warnings, and validation error states.
  static void vibrate() {
    _trigger('vibrate', () {
      HapticFeedback.vibrate();
      HapticFeedback.heavyImpact();
    });
  }
}
