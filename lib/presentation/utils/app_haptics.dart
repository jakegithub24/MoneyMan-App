import 'package:flutter/services.dart';

/// Centralized helper for managing and triggering haptic feedback across MoneyMan.
class AppHaptics {
  /// Global toggle reflecting user preference.
  static bool isEnabled = true;

  /// Light impact feedback (e.g., button taps, selection clicks).
  static void lightImpact() {
    if (isEnabled) {
      HapticFeedback.lightImpact();
    }
  }

  /// Medium impact feedback (e.g., submitting transaction, toggling settings).
  static void mediumImpact() {
    if (isEnabled) {
      HapticFeedback.mediumImpact();
    }
  }

  /// Heavy impact feedback (e.g., delete actions, database resets).
  static void heavyImpact() {
    if (isEnabled) {
      HapticFeedback.heavyImpact();
    }
  }

  /// Selection click feedback (e.g., PIN keypad press, tab selection).
  static void selectionClick() {
    if (isEnabled) {
      HapticFeedback.selectionClick();
    }
  }

  /// Vibration feedback for alerts/errors.
  static void vibrate() {
    if (isEnabled) {
      HapticFeedback.vibrate();
    }
  }
}
