import 'package:flutter/services.dart';

class DrmProtectionHelper {
  static const MethodChannel _channel = MethodChannel('com.example.flutter_application_101/security');

  /// Configures Android WindowManager FLAG_SECURE to prevent screenshot / screen recording.
  static Future<void> setDrmProtection(bool enabled) async {
    try {
      await _channel.invokeMethod('setDrmProtection', {'enabled': enabled});
    } catch (_) {
      // Ignored gracefully on unsupported platforms or unit test environments
    }
  }

  /// Queries if FLAG_SECURE is currently active on window.
  static Future<bool> isDrmProtectionActive() async {
    try {
      final res = await _channel.invokeMethod<bool>('isDrmProtectionEnabled');
      return res ?? false;
    } catch (_) {
      return false;
    }
  }
}
